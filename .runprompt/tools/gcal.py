import sqlite3
from datetime import datetime, date, timedelta
from zoneinfo import ZoneInfo
from pathlib import Path

import icalendar
from dateutil.rrule import rrulestr

EDS_CACHE_DIR = Path.home() / ".cache" / "evolution" / "calendar"
LOCAL_TZ = datetime.now().astimezone().tzinfo
UTC = ZoneInfo("UTC")


def _utc_bounds(start_date: date, end_date: date) -> tuple[str, str]:
    """Convert local date range to UTC timestamp strings for DB queries."""
    start_utc = datetime.combine(start_date, datetime.min.time(), tzinfo=LOCAL_TZ).astimezone(UTC)
    end_utc = datetime.combine(end_date, datetime.min.time(), tzinfo=LOCAL_TZ).astimezone(UTC)
    return start_utc.strftime("%Y%m%d%H%M%S"), end_utc.strftime("%Y%m%d%H%M%S")


def _parse_vevent(ics_text: str) -> icalendar.cal.Event | None:
    """Parse ICS text into an icalendar VEVENT component."""
    try:
        cal = icalendar.Calendar.from_ical(
            "BEGIN:VCALENDAR\r\n" + ics_text + "\r\nEND:VCALENDAR"
        )
    except Exception:
        return None
    for comp in cal.walk("VEVENT"):
        return comp
    return None


def _vevent_to_dict(comp: icalendar.cal.Event, override_start: datetime | None = None) -> dict | None:
    """Convert a VEVENT component to an event dict with local time."""
    dtstart = comp.get("dtstart")
    if not dtstart:
        return None
    dt = override_start or dtstart.dt
    summary = str(comp.get("summary", ""))
    dtend = comp.get("dtend")

    if isinstance(dt, datetime):
        local_start = dt.astimezone(LOCAL_TZ)
        if dtend and not override_start:
            local_end = dtend.dt.astimezone(LOCAL_TZ)
        elif dtend and override_start:
            duration = dtend.dt - dtstart.dt
            local_end = (override_start + duration).astimezone(LOCAL_TZ)
        else:
            local_end = None
        return {
            "time": local_start,
            "end": local_end,
            "summary": summary,
            "all_day": False,
        }
    elif isinstance(dt, date):
        end_dt = dtend.dt if dtend else dt + timedelta(days=1)
        return {
            "time": dt,
            "end": end_dt,
            "summary": summary,
            "all_day": True,
        }
    return None


def _expand_rrule(comp: icalendar.cal.Event, start_date: date, end_date: date) -> list[datetime]:
    """Expand RRULE for a VEVENT within the given date range, respecting EXDATEs."""
    rrule_prop = comp.get("rrule")
    if not rrule_prop:
        return []

    dtstart = comp.get("dtstart").dt
    rule_str = rrule_prop.to_ical().decode()

    # Collect EXDATEs
    exdates = set()
    exdate_raw = comp.get("exdate")
    if exdate_raw is not None:
        exdate_list = exdate_raw if isinstance(exdate_raw, list) else [exdate_raw]
        for exdate_prop in exdate_list:
            for dt_val in exdate_prop.dts:
                exdates.add(dt_val.dt)

    if isinstance(dtstart, datetime):
        # Make naive in local tz for rrule expansion
        dt_naive = dtstart.astimezone(LOCAL_TZ).replace(tzinfo=None)
        range_start = datetime.combine(start_date, datetime.min.time())
        range_end = datetime.combine(end_date, datetime.min.time())

        # rrulestr needs UNTIL in same tz-awareness as dtstart
        # Force naive by stripping UNTIL timezone issues
        try:
            rule = rrulestr("RRULE:" + rule_str, dtstart=dt_naive, ignoretz=True)
        except Exception:
            return []

        occurrences = []
        for occ in rule.between(range_start, range_end, inc=True):
            # Re-attach timezone for exdate comparison
            occ_aware = occ.replace(tzinfo=LOCAL_TZ)
            # Check exdates (compare in UTC to handle tz differences)
            occ_utc = occ_aware.astimezone(UTC)
            excluded = any(
                (ex.astimezone(UTC) if isinstance(ex, datetime) else ex) == occ_utc
                or (isinstance(ex, datetime) and ex.astimezone(UTC).date() == occ_utc.date()
                    and ex.astimezone(UTC).hour == occ_utc.hour)
                for ex in exdates
            )
            if not excluded:
                occurrences.append(occ_aware)
        return occurrences
    return []


def _query_events(start_date: date, end_date: date) -> list[dict]:
    """Query all EDS calendar caches for events in the given date range."""
    if not EDS_CACHE_DIR.exists():
        raise RuntimeError(
            f"Evolution calendar cache not found at {EDS_CACHE_DIR}. "
            "Is GNOME Online Accounts configured?"
        )

    start_utc, end_utc = _utc_bounds(start_date, end_date)
    events = []
    # Track UIDs of modified recurrence instances to avoid double-counting
    modified_instance_keys = set()

    for entry in EDS_CACHE_DIR.iterdir():
        db_path = entry / "cache.db"
        if not db_path.exists():
            continue
        conn = sqlite3.connect(str(db_path))
        try:
            # --- Pass 1: Timed events with occur_start in range ---
            rows = conn.execute(
                "SELECT occur_start, summary, ECacheOBJ "
                "FROM ECacheObjects "
                "WHERE occur_start IS NOT NULL "
                "AND occur_start >= ? AND occur_start < ?",
                (start_utc, end_utc),
            ).fetchall()

            for _, summary, ics_text in rows:
                comp = _parse_vevent(ics_text)
                if not comp:
                    continue
                ev = _vevent_to_dict(comp)
                if ev:
                    events.append(ev)
                # Track modified instances by their RECURRENCE-ID
                rec_id = comp.get("recurrence-id")
                if rec_id:
                    uid = str(comp.get("uid", ""))
                    rid = rec_id.dt
                    if isinstance(rid, datetime):
                        modified_instance_keys.add((uid, rid.astimezone(UTC)))

            # --- Pass 2: All-day events (occur_start is NULL) ---
            allday_rows = conn.execute(
                "SELECT summary, ECacheOBJ "
                "FROM ECacheObjects "
                "WHERE occur_start IS NULL AND ECacheOBJ IS NOT NULL",
            ).fetchall()

            for summary, ics_text in allday_rows:
                comp = _parse_vevent(ics_text)
                if not comp:
                    continue
                ev = _vevent_to_dict(comp)
                if ev and ev["all_day"]:
                    if ev["time"] < end_date and ev["end"] > start_date:
                        events.append(ev)

            # --- Pass 3: Expand base recurring events ---
            rec_rows = conn.execute(
                "SELECT ECacheOBJ FROM ECacheObjects "
                "WHERE has_recurrences = 1 AND ECacheOBJ IS NOT NULL",
            ).fetchall()

            for (ics_text,) in rec_rows:
                comp = _parse_vevent(ics_text)
                if not comp:
                    continue
                # Skip modified instances (they have RECURRENCE-ID)
                if comp.get("recurrence-id"):
                    continue
                # Skip if no RRULE
                if not comp.get("rrule"):
                    continue

                uid = str(comp.get("uid", ""))
                occurrences = _expand_rrule(comp, start_date, end_date)
                for occ in occurrences:
                    # Skip if a modified instance exists for this occurrence
                    occ_utc = occ.astimezone(UTC)
                    if (uid, occ_utc) in modified_instance_keys:
                        continue
                    ev = _vevent_to_dict(comp, override_start=occ)
                    if ev:
                        events.append(ev)

        except sqlite3.OperationalError:
            pass
        finally:
            conn.close()

    # Sort by date, then all-day first within each day, then by time
    def sort_key(e):
        if isinstance(e["time"], datetime):
            return (e["time"].date(), 1, e["time"])
        else:
            return (e["time"], 0, datetime.min.replace(tzinfo=LOCAL_TZ))

    events.sort(key=sort_key)
    return events


def _format_events(events: list[dict]) -> str:
    """Format events as plain text."""
    lines = []
    for ev in events:
        if ev["all_day"]:
            lines.append(f"All day: {ev['summary']}")
        else:
            end_str = f" - {ev['end'].strftime('%H:%M')}" if ev.get("end") else ""
            lines.append(f"{ev['time'].strftime('%H:%M')}{end_str} {ev['summary']}")
    return "\n".join(lines)


def get_today_events() -> str:
    """
    Return today's calendar events from GNOME Evolution Data Server.
    Reads locally cached data synced via GNOME Online Accounts.
    """
    today = date.today()
    events = _query_events(today, today + timedelta(days=1))
    return _format_events(events) or "No events today."


get_today_events.safe = True


def get_tomorrow_events() -> str:
    """
    Return tomorrow's calendar events from GNOME Evolution Data Server.
    Reads locally cached data synced via GNOME Online Accounts.
    """
    tomorrow = date.today() + timedelta(days=1)
    events = _query_events(tomorrow, tomorrow + timedelta(days=1))
    return _format_events(events) or "No events tomorrow."


get_tomorrow_events.safe = True


def get_week_events() -> str:
    """
    Return this week's calendar events from GNOME Evolution Data Server.
    Reads locally cached data synced via GNOME Online Accounts.
    """
    today = date.today()
    # Monday of current week
    week_start = today - timedelta(days=today.weekday())
    week_end = week_start + timedelta(days=7)
    events = _query_events(week_start, week_end)

    if not events:
        return "No events this week."

    # Group by day
    lines = []
    current_day = None
    for ev in events:
        ev_date = ev["time"] if isinstance(ev["time"], date) and not isinstance(ev["time"], datetime) else ev["time"].date()
        if ev_date != current_day:
            current_day = ev_date
            day_label = current_day.strftime("%A %b %d")
            if lines:
                lines.append("")
            lines.append(f"--- {day_label} ---")

        if ev["all_day"]:
            lines.append(f"  All day: {ev['summary']}")
        else:
            end_str = f" - {ev['end'].strftime('%H:%M')}" if ev.get("end") else ""
            lines.append(f"  {ev['time'].strftime('%H:%M')}{end_str} {ev['summary']}")

    return "\n".join(lines)


get_week_events.safe = True

if __name__ == "__main__":
    print(get_today_events())
