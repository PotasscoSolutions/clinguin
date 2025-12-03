% ============================================================================
% PART 1: DATA MAPPING & CONFIGURATION
% ============================================================================
% TODO: FIx recursive removal of attributes when removing object
#script(python)
from clingo.symbol import String

def day(a):
    """
    Takes the name form the path bu removing the prefix and the index
    """
    day = str(a)[-2:]
    return String(day)
def full_date(a):
    """
    Takes the name form the path bu removing the prefix and the index
    """
    import datetime
    date_str = str(a)
    try:
        dt = datetime.datetime.strptime(date_str, "%Y%m%d")
        nice = dt.strftime("%A, %d %B %Y")  # e.g., "Monday, 01 January 2024"
    except Exception:
        nice = date_str
    return String(nice)

#end.
% Historical data integration (days -7..-1)
date(D, W) :- prev_date(D, W).
staff_id_map(N, ID) :- staff(N, _, _, ID, _).
date_map(Date, D) :- base_date(D, Date, _), D >= -7, D <= -1.
date_day(D, @day(Date)) :- base_date(D, Date, _).
ext_assigned(N, D, S) :- shift_data(ID, _, Date, S), staff_id_map(N, ID), date_map(Date, D), D >= -7, D <= -1.
ext_assigned(N, D, S) :- assigned(N, D, S).

% Grid layout configuration
has_historical_data :- ext_assigned(_, D, _), D >= -7, D <= -1.
hist_col_offset(7) :- has_historical_data.
hist_col_offset(0) :- not has_historical_data.

% Weekend detection
is_weekend_any(D) :- date(D, "Sa").
is_weekend_any(D) :- date(D, "Su").

% ============================================================================
% PART 2: SHIFT DEFINITIONS
% ============================================================================

% All shift types
shift_type("D").   shift_type("LD").  shift_type("EM").  shift_type("LM").
shift_type("E").   shift_type("SE").  shift_type("N").   shift_type("SN").
shift_type("WR").  shift_type("PH").  shift_type("BT").  shift_type("TR").
shift_type("HC").  shift_type("AL").  shift_type("BL").  shift_type("HL").
shift_type("ML").  shift_type("NL").  shift_type("PL").  shift_type("SL").
shift_type("SP").  shift_type("VL").  shift_type("WL").

% Shift descriptions (tooltips)
shift_description("D", "Day").                    shift_description("LD", "Long day").
shift_description("EM", "Early morning").         shift_description("LM", "Late morning").
shift_description("E", "Evening").                shift_description("SE", "Short evening").
shift_description("N", "Night").                  shift_description("SN", "Short night").
shift_description("WR", "Weekly rest").           shift_description("PH", "Public holiday").
shift_description("BT", "Business trip").         shift_description("TR", "Training").
shift_description("HC", "Health check").          shift_description("AL", "Annual leave").
shift_description("BL", "Bereavement leave").     shift_description("HL", "Health leave").
shift_description("ML", "Maternity leave").       shift_description("NL", "Nursing leave").
shift_description("PL", "Parental leave").        shift_description("SL", "Sick leave").
shift_description("SP", "Special leave").         shift_description("VL", "Volunteer leave").
shift_description("WL", "Wedding leave").

% FontAwesome icons by time of day
shift_icon_fa("EM", "coffee").    shift_icon_fa("LM", "coffee").
shift_icon_fa("D", "sun").        shift_icon_fa("LD", "sun").
shift_icon_fa("E", "cloud-sun").  shift_icon_fa("SE", "cloud-sun").
shift_icon_fa("N", "moon").       shift_icon_fa("SN", "moon").
shift_icon_fa("BT", "briefcase").

% Display labels for grid cells (FA icons only)
shift_display_label(S, Label) :-
    shift_icon_fa(S, Icon),
    Label = @concat("<i class='fas fa-", Icon, "'></i> ", S).

shift_display_label(S, S) :- shift_type(S), not shift_icon_fa(S, _), S != "WR".
shift_display_label("WR", "").

% ============================================================================
% PART 3: MAIN GRID STRUCTURE
% ============================================================================

elem(w, window, root).
elem(main, container, w).
attr(main, child_layout, grid).
attr(main, order, 3).
attr(main, class, ("mt-4";"me-3";"ms-4")).
attr(main, width, cwith*16).

% Corner header (Nurse label)
elem(corner, label, main).
attr(corner, grid_column, 1).
attr(corner, grid_row, 1).
attr(corner, grid_row_span, 2).
attr(corner, label, "<i class='fas fa-user-md'></i> Nurse").
attr(corner, icon, "fa-user-md").
attr(corner, class, ("border";"border-secondary";"text-start";"h5";"p-2";"ps-3";"bg-primary";"text-white")).

% ============================================================================
% PART 4: HEADER ROWS (Day numbers and weekday names)
% ============================================================================

% Day number headers (row 1) - historical
elem(top_day_num(D), label, main) :- date(D, _), D >= -7, D <= -1, has_historical_data.
attr(top_day_num(D), width, cwith) :- date(D, _), D >= -7, D <= -1, has_historical_data.
attr(top_day_num(D), grid_column, D+9) :- date(D, _), D >= -7, D <= -1, has_historical_data.
attr(top_day_num(D), grid_row, 1) :- date(D, _), D >= -7, D <= -1, has_historical_data.
attr(top_day_num(D), label, D) :- date(D, _), D >= -7, D <= -1, has_historical_data.
attr(top_day_num(D), class, ("border";"border-secondary";"text-center";"h6";"p-2";"bg-secondary-400";"text-light")) :-
    date(D, _), D >= -7, D <= -1, has_historical_data.

% Day number headers (row 1) - current week
elem(top_day_num(D), label, main) :- date(D, _), D >= 0, D <= 6.
attr(top_day_num(D), width, cwith) :- date(D, _), D >= 0, D <= 6.
attr(top_day_num(D), grid_column, D+2+Offset) :- date(D, _), D >= 0, D <= 6, hist_col_offset(Offset).
attr(top_day_num(D), grid_row, 1) :- date(D, _), D >= 0, D <= 6.
attr(top_day_num(D), label, D) :- date(D, _), D >= 0, D <= 6.
attr(top_day_num(D), class, ("border";"border-secondary";"text-center";"h6";"p-2";"bg-primary-500";"text-light")) :-
    date(D, _), D >= 0, D <= 6.

% Statistics header
% elem(stats_header, label, main).
% attr(stats_header, grid_column, 9+Offset) :- hist_col_offset(Offset).
% attr(stats_header, grid_row, 1).
% attr(stats_header, label, "Statistics").
% attr(stats_header, class, ("border";"text-center";"fw-bold";"p-2";"bg-secondary-500";"text-light")).

% Shared styling rules for weekday headers
weekday_header_class(("border";"text-center";"p-2";"bg-tertiary-200";"text-secondary-500")).
weekend_header_class(("border";"text-center";"p-2";"fw-bold";"bg-tertiary-500")).
weekend_cell_class(("bg-tertiary-200")).

% Weekday name headers (row 2) - historical
elem(hist_day_header(D), label, main) :- date(D, _), D >= -7, D <= -1, has_historical_data.
attr(hist_day_header(D), width, cwith) :- date(D, _), D >= -7, D <= -1, has_historical_data.
attr(hist_day_header(D), grid_column, D+9) :- date(D, _), D >= -7, D <= -1, has_historical_data.
attr(hist_day_header(D), grid_row, 2) :- date(D, _), D >= -7, D <= -1, has_historical_data.
attr((hist_day_header(D);day_header(D)), label, @concat(W," (",Day,")")) :- date(D, W), date_day(D,Day).
attr((hist_day_header(D);day_header(D)), tooltip, @full_date(Date)) :- base_date(D, Date, _).
attr(hist_day_header(D), class, Class) :-
    date(D, _), D >= -7, D <= -1, has_historical_data,
    not is_weekend_any(D), weekday_header_class(Class).
attr(hist_day_header(D), class, Class) :-
    date(D, _), D >= -7, D <= -1, has_historical_data,
    is_weekend_any(D), weekend_header_class(Class).

% Weekday name headers (row 2) - current week
elem(day_header(D), label, main) :- date(D, _), D >= 0, D <= 6.
attr(day_header(D), width, cwith) :- date(D, _), D >= 0, D <= 6.
attr(day_header(D), grid_column, D+2) :- date(D, _), D >= 0, D <= 6, not has_historical_data.
attr(day_header(D), grid_column, D+9) :- date(D, _), D >= 0, D <= 6, has_historical_data.
attr(day_header(D), grid_row, 2) :- date(D, _), D >= 0, D <= 6.
% attr(day_header(D), label, @concat(W," (",D,")")) :- date(D, W), D >= 0, D <= 6.
attr(day_header(D), class, Class) :-
    date(D, _), D >= 0, D <= 6, not is_weekend_any(D), weekday_header_class(Class).
attr(day_header(D), class, Class) :-
    date(D, _), D >= 0, D <= 6, is_weekend_any(D), weekend_header_class(Class).
attr(day_header(D), class, "text-info") :-
    date(D, _), D<0.
attr(day_header(D), class, "text-dark") :-
    date(D, _), D>0.

% Statistics column header (under "Statistics")
% elem(stats_cols, label, main).
% attr(stats_cols, grid_column, 9) :- not has_historical_data.
% attr(stats_cols, grid_column, 16) :- has_historical_data.
% attr(stats_cols, grid_row, 2).
% attr(stats_cols, class, ("border";"border-secondary";"text-center";"p-2";"bg-tertiary-200";"text-secondary-500")).

% ============================================================================
% PART 5: NURSE ROW LABELS
% ============================================================================


elem(staff_row(N), label, main) :- staff(N,_,_,_,_).
attr(staff_row(N), grid_column, 1) :- staff(N,_,_,_,_).
attr(staff_row(N), grid_row, N+2) :- staff(N,_,_,_,_).
attr(staff_row(N), label, Name) :- staff(N,Name,_,_,_).
attr(staff_row(N), width, cwith*3) :- staff(N,Name,_,_,_).
attr(staff_row(N), class, ("border";"text-start";"h6";"p-2";"bg-light";"text-dark")) :-
    staff(N,_,_,_,_).

% ============================================================================
% PART 6: SHIFT CELLS (Main Schedule Grid)
% ============================================================================

#const cwith = 85.
% Historical shift cells
elem(hist_shift_cell(N,D), label, main) :-
    staff(N,_,_,_,_), date(D,_), D >= -7, D <= -1, has_historical_data.
attr(hist_shift_cell(N,D), width, cwith) :- staff(N,_,_,_,_), date(D,_), D >= -7, D <= -1, has_historical_data.
attr(hist_shift_cell(N,D), grid_column, D+9) :-
    staff(N,_,_,_,_), date(D,_), D >= -7, D <= -1, has_historical_data.
attr(hist_shift_cell(N,D), grid_row, N+2) :-
    staff(N,_,_,_,_), date(D,_), D >= -7, D <= -1, has_historical_data.
attr(hist_shift_cell(N,D), label, Label) :-
    ext_assigned(N,D,S), D >= -7, D <= -1, shift_display_label(S, Label).
attr(hist_shift_cell(N,D), label, "-") :-
    staff(N,_,_,_,_), date(D,_), D >= -7, D <= -1, has_historical_data, not ext_assigned(N,D,_).
attr(hist_shift_cell(N,D), tooltip, Desc) :-
    ext_assigned(N,D,S), D >= -7, D <= -1, shift_description(S, Desc).
attr(hist_shift_cell(N,D), class, ("border";"text-center";"p-2";"bg-tertiary-200";"text-secondary-300")) :-
    staff(N,_,_,_,_), date(D,_), D >= -7, D <= -1, has_historical_data.

% Current plan shift cells
elem(shift_cell(N,D), label, main) :- staff(N,_,_,_,_), date(D,_), D >= 0, D <= 6.
attr(shift_cell(N,D), width, cwith) :- staff(N,_,_,_,_), date(D,_), D >= 0, D <= 6.
attr(shift_cell(N,D), grid_column, D+2) :-
    staff(N,_,_,_,_), date(D,_), D >= 0, D <= 6, not has_historical_data.
attr(shift_cell(N,D), grid_column, D+9) :-
    staff(N,_,_,_,_), date(D,_), D >= 0, D <= 6, has_historical_data.
attr(shift_cell(N,D), grid_row, N+2) :- staff(N,_,_,_,_), date(D,_), D >= 0, D <= 6.

% Labels and tooltips
attr(shift_cell(N,D), label, Label) :-
    ext_assigned(N,D,S), D >= 0, D <= 6, shift_display_label(S, Label).
attr(shift_cell(N,D), label, "-") :-
    staff(N,_,_,_,_), date(D,_), D >= 0, D <= 6, not ext_assigned(N,D,_).
attr(shift_cell(N,D), tooltip, Desc) :-
    ext_assigned(N,D,S), D >= 0, D <= 6, shift_description(S, Desc).

% Base styling for all cells
attr(shift_cell(N,D), class, ("border";"text-center";"p-2";"bg-light")) :-
    staff(N,_,_,_,_), date(D,_), D >= 0, D <= 6.

% Assumed cell styling
attr(shift_cell(N,D), class, ("border";"text-center";"p-2";"bg-light";"fw-bold";"border-primary";"border-1";"text-primary")) :-
    _clinguin_assume(assigned(N,D,_), true).

% Click handler - add assumption if not already assumed
when(shift_cell(N,D), click, call, (stop_auto_solve(), add_assumption(assigned(N,D,S), true))) :-
    ext_assigned(N,D,S), D >= 0, D <= 6,
    not _clinguin_assume(assigned(N,D,S), true).

% Click handler - remove assumption if already assumed
when(shift_cell(N,D), click, call, (stop_auto_solve(), remove_assumption(assigned(N,D,S)))) :-
    ext_assigned(N,D,S), D >= 0, D <= 6,
    _clinguin_assume(assigned(N,D,S), true).

% Weekend styling overlay
attr(shift_cell(N,D), class, Class) :-
    staff(N,_,_,_,_), date(D,_), D >= 0, D <= 6,
    is_weekend_any(D),
    weekend_cell_class(Class).

% ============================================================================
% PART 7: STATISTICS COLUMN (per nurse)
% ============================================================================

is_work_shift(N,D) :- ext_assigned(N,D,S), D >= 0, D <= 6, S != "WR", S != "PH".
is_weekend(D) :- date(D,"Sa"), D >= 0, D <= 6.
is_weekend(D) :- date(D,"Su"), D >= 0, D <= 6.
is_wknd_off(N,D) :- ext_assigned(N,D,"WR"), is_weekend(D).
is_ph_day(D) :- date(D,"PH"), D >= 0, D <= 6.
is_ph_off(N,D) :- ext_assigned(N,D,"WR"), is_ph_day(D).
is_ph_off(N,D) :- ext_assigned(N,D,"PH"), is_ph_day(D).

shift_count(N, Count) :- staff(N,_,_,_,_), Count = #count{ D : is_work_shift(N,D) }.
wknd_off_count(N, Count) :- staff(N,_,_,_,_), Count = #count{ D : is_wknd_off(N,D) }.
ph_off_count(N, Count) :- staff(N,_,_,_,_), Count = #count{ D : is_ph_off(N,D) }.

% elem(stats_cell(N), label, main) :- staff(N,_,_,_,_).
% attr(stats_cell(N), grid_column, 9) :- staff(N,_,_,_,_), not has_historical_data.
% attr(stats_cell(N), grid_column, 16) :- staff(N,_,_,_,_), has_historical_data.
% attr(stats_cell(N), grid_row, N+2) :- staff(N,_,_,_,_).
attr(staff_row(N), tooltip, @concat("Shifts: ",SC," Weekend off: ",WO," PH off: ",PO)) :-
    shift_count(N, SC), wknd_off_count(N, WO), ph_off_count(N, PO).

% attr(stats_cell(N), label, "Shifts: 0<br>Weekend off: 0<br>PH off: 0") :-
%     staff(N,_,_,_,_), not shift_count(N, _).
% attr(stats_cell(N), class, ("border";"rounded";"text-center";"p-2";"bg-tertiary-300";"text-secondary-500")) :-
%     staff(N,_,_,_,_).

% ============================================================================
% PART 8: MENU BAR
% ============================================================================

elem(menu_bar, menu_bar, w).
attr(menu_bar, title, "Nurse Shift Planner").
attr(menu_bar, icon, "fa-calendar-alt").
attr(menu_bar, order, 1).

when(w, load, call, next_solution(optN, 1)) :- _clinguin_auto_solve, not _clinguin_optimal.

elem(btn_auto_solve, button, menu_bar).

attr(btn_auto_solve, label, "Stop") :- _clinguin_auto_solve.
attr(btn_auto_solve, icon, "fa-stop") :- _clinguin_auto_solve.
attr(btn_auto_solve, class, ("btn-text-dark")) :- _clinguin_auto_solve.
when(btn_auto_solve, click, call, stop_auto_solve) :- _clinguin_auto_solve.

attr(btn_auto_solve, label, "Solve") :- not _clinguin_auto_solve.
attr(btn_auto_solve, label, "Continue solving") :- _clinguin_browsing, not _clinguin_auto_solve.
attr(btn_auto_solve, icon, "fa-play") :- not _clinguin_auto_solve.
attr(btn_auto_solve, class, ("btn-text-dark")) :- not _clinguin_auto_solve.
when(btn_auto_solve, click, call, continue_auto_solve) :- not _clinguin_auto_solve.

elem(btn_clear_assumptions, button, menu_bar).
attr(btn_clear_assumptions, label, "Clear").
attr(btn_clear_assumptions, order, 3).
attr(btn_clear_assumptions, icon, "fa-eraser").
attr(btn_clear_assumptions, class, ("btn-outline-danger";"border-0")).
when(btn_clear_assumptions, click, call, (stop_auto_solve, clear_assumptions)).

elem(open_add_nurse_btn, button, menu_bar).
attr(open_add_nurse_btn, icon, "fa-user-plus").
attr(open_add_nurse_btn, label, "Add Nurse").
attr(open_add_nurse_btn, class, ("btn-text-dark")).
when(open_add_nurse_btn, click, update, (add_nurse_modal, visibility, shown)).

% ============================================================================
% PART 9: ADD NURSE MODAL
% ============================================================================

elem(add_nurse_modal, modal, w).
attr(add_nurse_modal, title, "Add Nurse").

elem(nurse_form, container, add_nurse_modal).
attr(nurse_form, child_layout, flex).
attr(nurse_form, flex_direction, column).
attr(nurse_form, class, ("p-3";"gap-2";"d-flex";"align-items-start";"flex-column")).

elem(nurse_id_input, textfield, nurse_form).
attr(nurse_id_input, order, 1).
attr(nurse_id_input, width, 400).
attr(nurse_id_input, placeholder, "Staff number (e.g., 41)").
when(nurse_id_input, input, context, (nurse_id, _value)).

elem(nurse_name_input, textfield, nurse_form).
attr(nurse_name_input, order, 2).
attr(nurse_name_input, width, 400).
attr(nurse_name_input, placeholder, "Name (e.g., Alice Smith)").
when(nurse_name_input, input, context, (nurse_name, _value)).

elem(nurse_points_input, textfield, nurse_form).
attr(nurse_points_input, order, 3).
attr(nurse_points_input, width, 400).
attr(nurse_points_input, placeholder, "Skill points (e.g., 5)").
when(nurse_points_input, input, context, (nurse_points, _value)).

% elem(nurse_group_label, label, nurse_form).
% attr(nurse_group_label, label, "Select Group:").
% attr(nurse_group_label, class, ("fw-bold")).

elem(nurse_group_input, dropdown_menu, nurse_form).
attr(nurse_group_input, selected, "Choose group").
attr(nurse_group_input, order, 4).
attr(nurse_group_input, width, 400).

    elem(gr_expert, dropdown_menu_item, nurse_group_input).
    attr(gr_expert, label, "Expert").
    when(gr_expert, click, context, (nurse_group, "Expert")).
    when(gr_expert, click, update, (nurse_group_input, selected, "Expert")).

    elem(gr_medium, dropdown_menu_item, nurse_group_input).
    attr(gr_medium, label, "Medium").
    when(gr_medium, click, context, (nurse_group, "Medium")).
    when(gr_medium, click, update, (nurse_group_input, selected, "Medium")).

    elem(gr_novice, dropdown_menu_item, nurse_group_input).
    attr(gr_novice, label, "Novice").
    when(gr_novice, click, context, (nurse_group, "Novice")).
    when(gr_novice, click, update, (nurse_group_input, selected, "Novice")).

% elem(selected_group_display, label, nurse_form).
% attr(selected_group_display, label, @concat("Selected: ", _context_value(nurse_group, str))).
% attr(selected_group_display, class, ("text-muted";"small")).

elem(nurse_add_btn, button, nurse_form).
attr(nurse_add_btn, order, 5).
attr(nurse_add_btn, label, "Add Nurse").
attr(nurse_add_btn, icon, "fa-user-plus").
attr(nurse_add_btn, class, ("btn";"btn-primary";"mt-3")).
when(nurse_add_btn, click, call, (
    add_atom(staff(_context_value(nurse_id,int), _context_value(nurse_name,str), "Nurse",
                   @concat("N", _context_value(nurse_id,int)), _context_value(nurse_points,int))),
    add_atom(staff_group(_context_value(nurse_group,str), _context_value(nurse_id,int))),
    next_solution
)).
when(nurse_add_btn, click, update, (add_nurse_modal, visibility, hidden)).

% ============================================================================
% PART 10: CONSTRAINT COVERAGE ROWS (Bottom Section)
% ============================================================================

staff_group_type("All").
staff_group_type(G) :- staff_group(G, _).
tracked_shift(S) :- vertical_constraint_type(_, S, _).

staff_assigned("All", Shift, Day, Count) :-
    tracked_shift(Shift), date(Day, _), Day >= 0, Day <= 6,
    Count = #count{ N : ext_assigned(N, Day, Shift), staff(N,_,_,_,_) }.

staff_assigned(Group, Shift, Day, Count) :-
    staff_group_type(Group), Group != "All", tracked_shift(Shift), date(Day, _), Day >= 0, Day <= 6,
    Count = #count{ N : ext_assigned(N, Day, Shift), staff_group(Group, N) }.

staff_row_num(N, R) :- staff(N,_,_,_,_), R = N+2.
max_staff_row(R) :- R = #max{ Row : staff_row_num(_, Row) }.
base_bottom_row(R) :- max_staff_row(MaxRow), R = MaxRow + 1.
bottom_row_offset(G, S, Offset) :-
    has_valid_constraint(G, S),
    Offset = #count{ G2,S2 : has_valid_constraint(G2, S2), (G2,S2) < (G,S) }.

has_constraint_bounds(G, S, DayType, Min, Max) :-
    staff_dweek_soft_lb(G, S, DayType, Min), staff_dweek_soft_ub(G, S, DayType, Max).
has_constraint_bounds(G, S, DayType, Min, Max) :-
    staff_group_type(G), tracked_shift(S),
    not staff_dweek_soft_lb(G, S, DayType, _),
    staff_dweek_hard_lb(G, S, DayType, Min), staff_dweek_hard_ub(G, S, DayType, Max).

has_valid_constraint(G, S) :- staff_group_type(G), tracked_shift(S).

day_type(D, "Weekend") :- is_weekend_any(D), D >= 0, D <= 6.
day_type(D, "Holiday") :- date(D, "PH"), D >= 0, D <= 6.
day_type(D, "Weekday") :- date(D, _), D >= 0, D <= 6, not is_weekend_any(D), not date(D, "PH").

has_violation(G, S, D) :- penalty(_, staff_lb(G, S, D), _, _, _, _).
has_violation(G, S, D) :- penalty(_, staff_ub(G, S, D), _, _, _, _).
has_violation(G, S, D) :-
    day_type(D, DayType), has_constraint_bounds(G, S, DayType, Min, _),
    staff_assigned(G, S, D, Count), Count < Min.
has_violation(G, S, D) :-
    day_type(D, DayType), has_constraint_bounds(G, S, DayType, _, Max),
    staff_assigned(G, S, D, Count), Count > Max.

% elem(bottom_label(G, S), label, main) :- has_valid_constraint(G, S).
% attr(bottom_label(G, S), grid_column, 1) :- has_valid_constraint(G, S).
% attr(bottom_label(G, S), grid_row, R) :-
%     base_bottom_row(Base), bottom_row_offset(G, S, Offset), R = Base + Offset, has_valid_constraint(G, S).
% attr(bottom_label(G, S), label, @concat(G, " - ", S, " (", Min, "-", Max, ")")) :-
%     has_constraint_bounds(G, S, "Weekday", Min, Max).
% attr(bottom_label(G, S), label, @concat(G, " - ", S)) :-
%     has_valid_constraint(G, S), not has_constraint_bounds(G, S, "Weekday", _, _).
% attr(bottom_label(G, S), class, ("border";"rounded";"text-center";"p-2";"fw-bold";"bg-secondary";"text-white")) :-
%     has_valid_constraint(G, S).

% elem(bottom_cell(G, S, D), label, main) :- has_valid_constraint(G, S), date(D, _), D >= 0, D <= 6.
% attr(bottom_cell(G, S, D), grid_column, D+2) :-
%     has_valid_constraint(G, S), date(D, _), D >= 0, D <= 6, not has_historical_data.
% attr(bottom_cell(G, S, D), grid_column, D+9) :-
%     has_valid_constraint(G, S), date(D, _), D >= 0, D <= 6, has_historical_data.
% attr(bottom_cell(G, S, D), grid_row, R) :-
%     base_bottom_row(Base), bottom_row_offset(G, S, Offset), R = Base + Offset,
%     date(D, _), D >= 0, D <= 6, has_valid_constraint(G, S).
% attr(bottom_cell(G, S, D), label, C) :- staff_assigned(G, S, D, C), has_valid_constraint(G, S).
% attr(bottom_cell(G, S, D), label, "0") :-
%     has_valid_constraint(G, S), date(D, _), D >= 0, D <= 6, not staff_assigned(G, S, D, _).
% attr(bottom_cell(G, S, D), tooltip, @concat("Min: ", Min, " | Max: ", Max)) :-
%     has_valid_constraint(G, S), date(D, _), D >= 0, D <= 6,
%     day_type(D, DayType), has_constraint_bounds(G, S, DayType, Min, Max).

% attr(bottom_cell(G, S, D), class, ("border";"rounded";"text-center";"p-2";"bg-light";"text-dark")) :-
%     has_valid_constraint(G, S), date(D, _), D >= 0, D <= 6, not has_violation(G, S, D).

% attr(bottom_cell(G, S, D), class, ("border";"rounded";"text-center";"p-2";"bg-light";"text-danger";"fw-bold")) :-
%     has_valid_constraint(G, S), date(D, _), D >= 0, D <= 6, has_violation(G, S, D).

% elem(bottom_stats_cell(G, S), label, main) :- has_valid_constraint(G, S).
% attr(bottom_stats_cell(G, S), grid_column, 9) :- has_valid_constraint(G, S), not has_historical_data.
% attr(bottom_stats_cell(G, S), grid_column, 16) :- has_valid_constraint(G, S), has_historical_data.
% attr(bottom_stats_cell(G, S), grid_row, R) :-
%     base_bottom_row(Base), bottom_row_offset(G, S, Offset), R = Base + Offset, has_valid_constraint(G, S).
% attr(bottom_stats_cell(G, S), label, "") :- has_valid_constraint(G, S).
% attr(bottom_stats_cell(G, S), class, ("border";"rounded";"p-2";"bg-light";"text-dark")) :-
%     has_valid_constraint(G, S).

% ============================================================================
% PART 11: OPTIMIZATION PROGRESS DISPLAY
% ============================================================================

elem(statistics_main, collapse, w).
attr(statistics_main, label, "Progress").
attr(statistics_main, icon, "fa-spinner").
attr(statistics_main, width, 1485).
attr(statistics_main, class, ("p-3";"bg-tertiary-200";"h5";"ms-4";"me-3";"mt-1";"mb-0";"text-primary")).
attr(statistics_main, class, ("border-start";"border-primary";"border-2")).
% attr(statistics_main, opacity, "0.5"):- not _clinguin_cost(_, _).
attr(statistics_main, tooltip, "No optimization in progress"):- not _clinguin_cost(_, _).
attr(statistics_main, order, 2).

elem(cost_section, container, statistics_main).
attr(cost_section, class, ("p-1";"pb-4";"bg-tertiary-200";"ms-4";"me-3")).
attr(cost_section, class, ("border-start";"border-primary";"border-2")).


% Baseline (starting penalty values)
baseline(0, 10).    baseline(1, 100).   baseline(2, 2000).  baseline(3, 100).
baseline(4, 100).   baseline(5, 3000).  baseline(6, 100).

% Target values
goal(0, 0).  goal(1, 0).  goal(2, 0).  goal(3, 0).
goal(4, 0).  goal(5, 0).  goal(6, 0).

level(I) :- baseline(I,_).

current_cost(I, C) :- _clinguin_cost(I, C).
current_cost(I, B) :- baseline(I, B), not _clinguin_cost(I, _).

priority_label(0, "Nurse Requests").
priority_label(1, "Shift Sequences").
priority_label(2, "Coverage Bounds").
priority_label(3, "Base Hard Constraints").
priority_label(4, "Nurse Requests").
priority_label(5, "Patterns & Coverage").
priority_label(6, "Distribution & Rewards").

elem(progress_container, container, cost_section).
attr(progress_container, class, "mt-1").
attr(progress_container, order, 2).

elem(level_row_info(I), container, progress_container) :- level(I).
attr(level_row_info(I), class, ("d-flex"; "flex-row"; "p-2";"align-items-start")) :- level(I).
attr(level_row_info(I), order, I+2) :- level(I).

elem(level_row(I), container, level_row_info(I)) :- level(I).
attr(level_row(I), child_layout, grid) :- level(I).
attr(level_row(I), grid_template_columns, "auto";"1fr") :- level(I).
attr(level_row(I), class, ("align-items-center"; "gap-2"; "mb-2")) :- level(I).
attr(level_row(I), order, I+2) :- level(I).

elem(level_label(I), label, level_row_info(I)) :- level(I).
attr(level_label(I), label, Label) :- level(I), priority_label(I, Label).
attr(level_label(I), class, ("text-start";"ps-4";"h6")) :- level(I), priority_label(I, Label).
% attr(level_label(I), fontSize, "15px") :- level(I), priority_label(I, Label).
attr(level_label(I), order, 1) :- level(I).
attr(level_label(I), width, 300) :- level(I).

elem(level_progress(I), progress_bar, level_row_info(I)) :- level(I).
attr(level_progress(I), max, V) :- level(I), baseline(I, V).
attr(level_progress(I), value, P) :-
    level(I), current_cost(I, P), P > 0, P < V, baseline(I, V).
attr(level_progress(I), value, -P) :- level(I), current_cost(I, P), P <= 0.
attr(level_progress(I), value, V) :-
    level(I), current_cost(I, P), P > V, baseline(I, V).
attr(level_progress(I), height, 18) :- level(I).
attr(level_progress(I), opacity, @decimal_string(100 - (10*I), 1)) :- level(I).
attr(level_progress(I), width, "100%") :- level(I).
attr(level_progress(I), order, 2) :- level(I).

attr(level_progress(I), class, ("rounded";"no-transition";"bg-success")) :-
    current_cost(I, P), P < 0.
attr(level_progress(I), class, ("rounded";"no-transition";"bg-danger")) :-
    current_cost(I, P), P >= 0.
