% TODO: FIx recursive removal of attributes when removing object
#script(python)
from clingo.symbol import Function, Number, String
parts = {}
attr = {}
def name(a, capitalize=None):
    """
    Takes the name form the path bu removing the prefix and the index
    """
    name = str(a).split(".")[-1].split("[")[0]
    if capitalize is not None:
        name = name.upper()
    return Function(name, [])
def part_id(a):
    """
    An id for each part to order them in the UI
    """
    if not a in parts:
        parts[a] = len(parts)+1
    return Number( parts[a] )

def attr_id(a):
    """
    An id for each attribute to order them in the UI
    """
    if not a in attr:
        attr[a] = len(attr)+1
    return Number( attr[a] )

def img_name(color, front, back):
    path = "./img/"
    color = str(color).strip('"').lower()
    path += f"{color}/b"
    if int(str(front)):
        path += "-front"
    if int(str(back)):
        path += "-back"
    return String(path + ".jpg")
#end.

% ============ Auxiliaries

% ----------- FEATURES
% ----- Parts (COOM Structures)
included_part("root").
included_part(I) :- _all(include(I)), type(I,T), part(T).
included_part(I) :- include(I), type(I,T), part(T), _clinguin_browsing.
included_part_by_assumption(I) :- included_part(I), _clinguin_assume(include(I),true), I!="root".
possibly_included_part(I) :- _any(include(I)), type(I,T), part(T), not included_part(I).
has_larger_part(I) :- included_part(I), included_part(I'), set(P,I), set(P,I'), I'>I.

% ----- Attributes (Enumerations and Numeric Features Attributes of enumerations)
attr_type(I,discrete) :- type(I,T), discrete(T).
attr_type(I,integer)  :- type(I,T), integer(T).
included_attr(I,AT)   :-  attr_type(I, AT),  _all(include(I)).
included_attr(I,AT)   :-  attr_type(I, AT),  include(I), _clinguin_browsing.
discrete_main_attr(I) :-included_attr(I,discrete), parent(I,P), included_part(P). %To treat differently the discrete sub-attributes

% ----- Values
included_value(I,V) :- included_attr(I,_), _all(value(I,V)), not _clinguin_assume(value(I,V),true).
included_value(I,V) :- included_attr(I,_), _clinguin_assume(value(I,V),true).
included_value(I,V) :- included_attr(I,_), value(I,V), _clinguin_browsing.
% included_value_by_assumption(I):- included_value(I,V), _clinguin_assume(value(I,V),true).



% ============ UI

% Window
elem(window, window, root).
attr(window, class, ("d-flex";"flex-row")).


% -------   Image

elem(imagec, container, window).
attr(imagec, width, 700).
attr(imagec, height, 500).
attr(imagec, class, ("d-flex";"align-items-center";"p-3")).
attr(imagec, class, ("bg-light";"ms-5";"mt-3";"rounded-4";"border";"border-4";"border-primary")).


    color(X):-_all_opt(value("root.color[0]",X)), not _clinguin_browsing.
    color("Black"):-not _all_opt(value("root.color[0]",_)), not _clinguin_browsing.
    color(X):-value("root.color[0]",X), _clinguin_browsing.
    back(1):-_all_opt(include("root.rearBasket[0]")),not _clinguin_browsing.
    back(1):-include("root.rearBasket[0]"), _clinguin_browsing.
    back(0):- not _all_opt(include("root.rearBasket[0]")),not _clinguin_browsing.
    back(0):- not include("root.rearBasket[0]"), _clinguin_browsing.
    front(1):-_all_opt(include("root.frontBasket[0]")),not _clinguin_browsing.
    front(1):-include("root.frontBasket[0]"), _clinguin_browsing.
    front(0):- not _all_opt(include("root.frontBasket[0]")),not _clinguin_browsing.
    front(0):- not include("root.frontBasket[0]"), _clinguin_browsing.
    elem(c, canvas, imagec).
    attr(c, order, 2).
    attr(c, image, @img_name(C, F,B)):- color(C), back(B), front(F).
    attr(c, width, 600).
    attr(c, height, 430).


% Main container for root part, other parts are added below recursively
elem(all_parts, container, window).
% attr(all_parts, class, ("w-50")).
% attr(all_parts, width, ("fit-content")).
attr(all_parts, width, 500).

elem(part_container("root"), container, all_parts).


    % +++++++ TITLE

    elem(part_title(I), container, part_container((I)))             :- included_part(I).
    attr(part_title(I), order, 1)                                   :- included_part(I).
    attr(part_title(I), class, ("d-inline-flex";"flex-row";"px-3")) :- included_part(I).

        % Title label name
        elem(part_title_l(I), label, part_title(I)) :- included_part(I).
        attr(part_title_l(I), label,@name(I,1))       :- included_part(I), I!="root".
        attr(part_title_l(I), label,@name("Bicycle",1))       :- included_part(I), I=="root".
        attr(part_title_l(I), class, ("h6"))        :- included_part(I).
        attr(part_title_l(I), order, 1)             :- included_part(I).

        % Title label type
        elem(part_title_t(I), label, part_title(I))               :- included_part(I).
        attr(part_title_t(I), label,  @format("({0})",T))         :- included_part(I), type(I,T).
        attr(part_title_t(I), class, ("px-1";"m-1";"fw-lighter";"text-primary")) :- included_part(I).
        attr(part_title_t(I), order, 2)                           :- included_part(I).

        % Title container to remove the part
        elem(part_title_bc(I), container, part_title(I)) :- included_part(I).
        % attr(part_title_bc(I), class,  ("ms-auto"))      :- included_part(I).
        attr(part_title_bc(I), order,  3)                :- included_part(I).

            % Title button to remove the part
            elem(part_title_b(I), button, part_title_bc(I))                    :- included_part(I).
            attr(part_title_b(I), icon,  "fa-xmark")                           :- included_part(I).
            attr(part_title_b(I), "font-size",  "8pt")                           :- included_part(I).
            attr(part_title_b(I), class,  ("border-0";"btn-sm"))                        :- included_part(I).
            attr(part_title_b(I), class,  ("btn-danger";"text-danger";"bg-light"))   :- included_part_by_assumption(I), not has_larger_part(I).
            attr(part_title_b(I), class,  ("btn-outline-info";"disabled"))     :- included_part(I), not included_part_by_assumption(I).
            attr(part_title_b(I), tooltip,  "Can't remove necessary object")    :- included_part(I), not included_part_by_assumption(I).
            attr(part_title_b(I), class,  ("btn-outline-info";"disabled"))     :- included_part(I), has_larger_part(I).
            attr(part_title_b(I), tooltip, @format("Remove other {} first",T)) :- included_part(I), type(I,T), has_larger_part(I).
            % Recursive removal of parts, attributes and enumerations
            child_remove(I,I)   :- included_part_by_assumption(I), not has_larger_part(I).
            child_remove(I,I'') :- child_remove(I, I'), parent(I'',I').
            child_assumption(I,include(I'))                                     :- child_remove(I,I').
            child_assumption(I,value(I',any))                                   :- child_remove(I,I'), included_attr(I',_).
            when(part_title_b(I), click,  call, remove_assumption_signature(A)) :- child_remove(I,I), child_assumption(I, A).
            % when(part_title_b(I), mouseenter,  update, (part_container(I),class,"bg-primary")) :- included_part(I).
            % when(part_title_b(I), mouseenter,  call, next_solution) :- included_part(I).
            when(part_title_b(I), mouseenter,  update, (part_container(I),filter,"opacity(0.5)")) :- included_part(I).
            when(part_title_b(I), mouseleave,  update, (part_container(I),filter,"opacity(1)")) :- included_part(I).

    % +++++++ Parts

    %  Container for all sub-parts
    elem(parts_container(I), container, part_container(I))        :- included_part(I).
    attr(parts_container(I), order, 5)                            :- included_part(I).
    attr(parts_container(I), class, ("d-inline-flex";"flex-col")) :- included_part(I).

        % Container per part
        elem(part_container(I), container, parts_container(P))                                :- included_part(I), parent(I,P).
        attr(part_container(I), class, ("m-2";"p-2";"ms-4"))                                         :- included_part(I).
        attr(part_container(I), order, @part_id(I))                                         :- included_part(I).

        % attr(part_container(I), width, ("95%"))                                               :- included_part(I).
        % attr(part_container(I), class, ("shadow"))                                            :- included_part(I).
        attr(part_container(I), class, ("bg-light"))                           :- included_part(I).
        attr(part_container(I), class, ("bd-highlight";"d-inline-flex";"flex-col")) :- included_part(I).
        % attr(part_container(I), class, ("container-light"))                   :- included_part(I).
        attr(part_container(I), class, ("border-start";"border-2";"border-primary"))                   :- included_part(I).
        % attr(part_container(I), "border-style", "dotted") :- included_part(I), _clinguin_browsing, not _all(include(I)).

            % Containier for button to add a new part
            elem(possible_parts(I), container, part_container(I))               :- included_part(I).
            attr(possible_parts(I), order, 4)                                   :- included_part(I).
            attr(possible_parts(I), class, ("ms-2";"d-inline-flex";"flex-row")) :- included_part(I).

                % One container per part type to include
                elem(possible_part(I), container, possible_parts(P)) :- not _clinguin_browsing, possibly_included_part(I), parent(I,P), #false: possibly_included_part(I'), set(X,I), set(X,I'), I'<I.
                attr(possible_part(I), class, "ps-1") :- not _clinguin_browsing, possibly_included_part(I), parent(I,P), #false: possibly_included_part(I'), set(X,I), set(X,I'), I'<I.

                    elem(possible_part_b(I), button, possible_part(I))                :- elem(possible_part(I),_,_).
                    attr(possible_part_b(I), label, @name(I))                         :- elem(possible_part(I),_,_).
                    attr(possible_part_b(I), icon, "fa-circle-plus")                  :- elem(possible_part(I),_,_).
                    attr(possible_part_b(I), class, ("btn-outline-secondary";"border-0";"btn-sm"))  :- elem(possible_part(I),_,_).
                    when(possible_part_b(I), click, call, add_assumption(include(I))) :- elem(possible_part(I),_,_).

    % +++++++ ENUMERATIONS AND ATTRIBUTES

    %  Part container for all its attributes
    elem(attrs_container(I), container, part_container(I))                            :- included_part(I).
    attr(attrs_container(I), order, 2)                                                :- included_part(I).
    attr(attrs_container(I), heigth, 50)                                              :- included_part(I).
    attr(attrs_container(I), class, ("align-items-start";"d-inline-flex";"flex-col";"ms-3")) :- included_part(I).

        % Part container for Numeric Enumerations
        elem(num_attrs_container(I), container, attrs_container(I))                           :- included_part(I).
        attr(num_attrs_container(I), order, 1)                                                :- included_part(I).
        attr(num_attrs_container(I), heigth, 50)                                              :- included_part(I).
        attr(num_attrs_container(I), class, ("align-items-start";"d-inline-flex";"flex-col")) :- included_part(I).

        %  Part container for all discrete attributes
        elem(dis_attrs_container(I), container, attrs_container(I))                           :- included_part(I).
        attr(dis_attrs_container(I), order, 2)                                                :- included_part(I).
        attr(dis_attrs_container(I), heigth, 50)                                              :- included_part(I).
        attr(dis_attrs_container(I), class, ("align-items-start";"d-inline-flex";"flex-col")) :- included_part(I).
        attr(dis_attrs_container(I), class, ("ms-2";"ps-2";"pe-3")) :- included_part(I).
        % attr(dis_attrs_container(I), class, ("bg-tertiary-300")) :- included_part(I).


            % Container per discrete attribute
            % If we want to make it general then this should alsobe work if the parent is an attribute
            elem(discrete_container(I), container, dis_attrs_container(P))       :- discrete_main_attr(I), parent(I,P).
            % attr(discrete_container(I), class, ("mx-3";"my-1";"px-2";"rounded")) :- discrete_main_attr(I).
            attr(discrete_container(I), class, ("d-inline-flex";"flex-col"))     :- discrete_main_attr(I).
            % attr(discrete_container(I), class, ("bg-tertiary-300")) :- discrete_main_attr(I).
            attr(discrete_container(I), order, N) :- discrete_main_attr(I), #count{I':discrete_main_attr(I'), I'>I}=N.


                elem(discrete_main_attr(I), container, discrete_container(I)) :- elem(discrete_container(I),_,_).
                attr(discrete_main_attr(I), order, 1)                         :- elem(discrete_container(I),_,_).
                attr(discrete_main_attr(I), class, "ps-2")                         :- elem(discrete_container(I),_,_).
                elem(discrete_sub_attr(I), container, discrete_container(I))  :- elem(discrete_container(I),_,_).
                attr(discrete_sub_attr(I), order, 2)                          :- elem(discrete_container(I),_,_).
                attr(discrete_sub_attr(I), class, "ps-1")                          :- elem(discrete_container(I),_,_).
                attr(discrete_sub_attr(I), display, none)                          :- elem(discrete_container(I),_,_).
                % attr(discrete_sub_attr(I), class, ("d-inline-flex";"flex-col"))                          :- elem(discrete_container(I),_,_).
                % attr(discrete_sub_attr(I), visibility, hidden)                          :- elem(discrete_container(I),_,_).
                % attr(discrete_sub_attr(I), class, ("ms-4";"border-start"))                          :- elem(discrete_container(I),_,_).


                % Container for title and options of enumerations and attributes
                elem(attr_value(I), container, discrete_sub_attr(P))   :- included_attr(I,_), parent(I,P), included_attr(P,discrete).
                elem(attr_value(I), container, discrete_main_attr(I))  :- included_attr(I,discrete), parent(I,P), included_part(P).
                elem(attr_value(I), container, num_attrs_container(P)) :- included_attr(I,integer), parent(I,P), included_part(P).
                attr(attr_value(I), order, @attr_id(I)) :- included_attr(I,_).
                attr(attr_value(I), class, ("d-inline-flex";"flex-row";"justify-content-between")) :- included_attr(I,_).
                when(attr_value(I), right_click, update, (attr_value_context(I), visibility, shown)) :- included_attr(I,_), not discrete_main_attr(I).

                % elem(attr_value_context(I), context_menu, window) :- included_attr(I,_), not discrete_main_attr(I).

                    % elem(attr_value_context_minimize(I), button, attr_value_context(I)) :- included_attr(I,_), not discrete_main_attr(I).
                    % attr(attr_value_context_minimize(I), label, " Minimize")               :- included_attr(I,_), not discrete_main_attr(I).
                    % attr(attr_value_context_minimize(I), icon, "fa-trophy")            :- included_attr(I,_), not discrete_main_attr(I).
                    % attr(attr_value_context_minimize(I), class, ("text-success"))            :- included_attr(I,_), not discrete_main_attr(I).
                    % when(attr_value_context_minimize(I), click, call, add_atom(minimize(I))) :- included_attr(I,_), not discrete_main_attr(I).

                    % elem(attr_value_context_maximize(I), button, attr_value_context(I)) :- included_attr(I,_), not discrete_main_attr(I).
                    % attr(attr_value_context_maximize(I), label, "Maximize")               :- included_attr(I,_), not discrete_main_attr(I).
                    % attr(attr_value_context_maximize(I), icon, "fa-up-long")              :- included_attr(I,_), not discrete_main_attr(I).
                    % when(attr_value_context_maximize(I), click, call, remove_atom(minimize(I))) :- included_attr(I,_), not discrete_main_attr(I).
                % attr(attr_value(I), width,00) :- included_attr(I,_).

                    % Title for dropdown
                    elem(attr_value_title(I), container, attr_value(I))            :- included_attr(I,_).
                    attr(attr_value_title(I), class, ("d-inline-flex";"flex-row";"ms-2")) :- included_attr(I,_).
                    attr(attr_value_title(I), class, ("border-start")) :- included_attr(I,_), not discrete_main_attr(I).
                    attr(attr_value_title(I), width, 190)                          :- included_attr(I,_).
                    when(attr_value_title(I), click, update, (discrete_sub_attr(I), display, block))                          :- included_attr(I,_), elem(_,_,discrete_sub_attr(I)).
                    when(attr_value_title(I), dblclick, update, (discrete_sub_attr(I), display, none))                          :- included_attr(I,_).


                        elem(attr_value_opt_c(I), container, attr_value_title(I))           :- included_attr(I,_), not discrete_main_attr(I).
                        attr(attr_value_opt_c(I), order, 1)                             :- included_attr(I,_), not discrete_main_attr(I).

                            icon(I,"fa-circle"):- included_attr(I,_), not discrete_main_attr(I), not minimize(I), not maximize(I).
                            icon(I,"fa-circle-down"):- included_attr(I,_), not discrete_main_attr(I), minimize(I).
                            icon(I,"fa-circle-up"):- included_attr(I,_), not discrete_main_attr(I), maximize(I).
                            active_opt(I):- included_attr(I,_), not discrete_main_attr(I), maximize(I).
                            active_opt(I):- included_attr(I,_), not discrete_main_attr(I), minimize(I).

                            elem(attr_value_opt_b(I), button, attr_value_opt_c(I))           :- included_attr(I,_), not discrete_main_attr(I).
                            attr(attr_value_opt_b(I), icon, X)            :- included_attr(I,_), not discrete_main_attr(I), icon(I,X).
                            attr(attr_value_opt_b(I), class, ("btn-primary";"text-success";"bg-light";"border-0";"btn-sm")) :- included_attr(I,_), not discrete_main_attr(I).
                            attr(attr_value_opt_b(I), opacity, "0.3") :- included_attr(I,_), not discrete_main_attr(I), not active_opt(I).
                            attr(attr_value_opt_b(I), class, "disabled") :- included_attr(I,_), not discrete_main_attr(I), active_opt(I), not _clinguin_atom(minimize(I)), not _clinguin_atom(maximize(I)).
                            attr(attr_value_opt_b(I), tooltip, "Can't edit optimization fixed by input") :- included_attr(I,_), not discrete_main_attr(I), active_opt(I), not _clinguin_atom(minimize(I)), not _clinguin_atom(maximize(I)).
                            when(attr_value_opt_b(I), mouseenter,update, (attr_value_opt_b(I), opacity, "1")) :- included_attr(I,_), not discrete_main_attr(I).
                            when(attr_value_opt_b(I), mouseleave,update, (attr_value_opt_b(I), opacity, "0.3")) :- included_attr(I,_), not discrete_main_attr(I), not active_opt(I).
                            when(attr_value_opt_b(I), click,call, add_atom(minimize(I))) :- included_attr(I,_), not discrete_main_attr(I), not active_opt(I).
                            when(attr_value_opt_b(I), click,call, (remove_atom(minimize(I)),add_atom(maximize(I)))) :- included_attr(I,_), not discrete_main_attr(I), minimize(I).
                            when(attr_value_opt_b(I), click,call, remove_atom(maximize(I))) :- included_attr(I,_), not discrete_main_attr(I), maximize(I).

                        elem(attr_value_l(I), label, attr_value_title(I)) :- included_attr(I,_).
                        attr(attr_value_l(I), label, @name(I))            :- included_attr(I,_).
                        attr(attr_value_l(I), order, 2)                   :- included_attr(I,_).
                        % attr(attr_value_l(I), class, ("fst-italic"))      :- included_attr(I,_).
                        attr(attr_value_l(I), class, ("h7";"fw-medium"))  :- discrete_main_attr(I).
                        attr(attr_value_l(I), class, ("h8";"px-0";"fst-italic";"fw-light")) :- included_attr(I,_), not discrete_main_attr(I).
                        attr(attr_value_l(I), class, ("text-secondary-400")) :- included_attr(I,_), not discrete_main_attr(I).
                        % attr(attr_value_l(I), class, ("text-success")) :- included_attr(I,_), not discrete_main_attr(I), _clinguin_browsing, minimize(I).

                        % Added type to title only for discrete enumerations
                        elem(attr_value_t(I), label, attr_value_title(I))           :- discrete_main_attr(I).
                        attr(attr_value_t(I), label, @format("({0})",T))            :- discrete_main_attr(I), type(I,T).
                        attr(attr_value_t(I), class, ("px-1";"fw-lighter";"small")) :- discrete_main_attr(I).
                        attr(attr_value_t(I), order, 3)                             :- discrete_main_attr(I).

                    % Container with dropdown
                    elem(attr_value_title_o(I), container, attr_value(I)) :- included_attr(I,_).
                    attr(attr_value_title_o(I), order, 3)                 :- included_attr(I,_).
                    attr(attr_value_title_o(I), class, "p-1")             :- included_attr(I,_).

                        elem(attr_value_title_o_dd(I), dropdown_menu, attr_value_title_o(I)) :- included_attr(I,_).
                        attr(attr_value_title_o_dd(I), selected, V)                          :- included_value(I,V), not _clinguin_assume(value(I,V),true).
                        attr(attr_value_title_o_dd(I), selected, V)                          :- _clinguin_assume(value(I,V),true).
                        % attr(attr_value_title_o_dd(I), selected, V) :- included_value(I,V), _clinguin_browsing.


                        % attr(attr_value_title_o_dd(I), class, ("fw-bold")) :- included_attr(I,_), value(I,V), _clinguin_browsing, not _all(value(I,V)).
                        % attr(attr_value_title_o_dd(I), class, ("opacity-50")) :- included_value(I,V), not _clinguin_browsing.
                        % attr(attr_value_title_o_dd(I), class, ("btn-secondary")) :- discrete_main_attr(I), not included_value(I,_).
                        % attr(attr_value_title_o_dd(I), class, ("btn-primary")) :- included_attr(I,_), not discrete_main_attr(I),  not included_value(I,_).
                        % attr(attr_value_title_o_dd(I), class, ("border-0";"btn-outline-secondary")) :- discrete_main_attr(I), included_value(I,_).
                        % attr(attr_value_title_o_dd(I), class, ("border-0";"btn-outline-primary")) :- not discrete_main_attr(I),  included_value(I,_).
                        % attr(attr_value_title_o_dd(I), class, ("btn-danger")) :- _clinguin_mus(value(I,V)).


                        attr(attr_value_title_o_dd(I), class, ("btn-sm")) :- included_attr(I,_).
                        attr(attr_value_title_o_dd(I), class, ("disabled")) :- included_attr(I,_), _clinguin_browsing.
                        attr(attr_value_title_o_dd(I), class, ("fw-bold"))  :- included_attr(I,_), _clinguin_browsing, not _all(value(I,_)).
                        attr(attr_value_title_o_dd(I), class, ("fw-light";"opacity-50")) :- included_value(I,V), _all(value(I,V)),not _clinguin_assume(value(I,V),true).
                        attr(attr_value_title_o_dd(I), class, ("btn-primary")) :- included_attr(I,discrete), not included_value(I,_).
                        attr(attr_value_title_o_dd(I), class, ("btn-secondary")) :- included_attr(I,discrete), _clinguin_assume(value(I,_),true).
                        attr(attr_value_title_o_dd(I), class, ("btn-secondary")) :- included_attr(I,discrete), _clinguin_assume(value(I,_),true).
                        attr(attr_value_title_o_dd(I), class, ("btn-primary")) :- included_attr(I,integer),  not included_value(I,_).
                        attr(attr_value_title_o_dd(I), class, ("btn-secondary")) :- included_attr(I,integer), _clinguin_assume(value(I,_),true).
                        attr(attr_value_title_o_dd(I), class, ("border-0";"btn-outline-secondary")) :- included_attr(I,_), included_value(I,_), not _clinguin_assume(value(I,_),true).
                        attr(attr_value_title_o_dd(I), class, ("border-0";"btn-outline-secondary")) :- included_attr(I,_), included_value(I,_), not _clinguin_assume(value(I,_),true), not _clinguin_browsing.
                        attr(attr_value_title_o_dd(I), class, ("border-0";"btn-outline-success")) :- included_attr(I,_), included_value(I,_), not _clinguin_assume(value(I,_),true), _clinguin_browsing, active_opt(I).
                        % attr(attr_value_title_o_dd(I), class, ("border-0";"btn-outline-primary"))  :- included_attr(I,integer),  included_value(I,_), not _clinguin_assume(value(I,_),true).
                        attr(attr_value_title_o_dd(I), class, ("btn-danger")) :- _clinguin_mus(value(I,V)).
                        attr(attr_value_title_o_dd(I), tooltip_error, (M)) :- _clinguin_mus(value(I,V)), _clinguin_mus(constraint(C,("boolean";"table"))) , explanation(E,M), C=(E,_).




                            option((I,V),invalid):- included_attr(I,_), domain(T,V), type(I,T), not _any(value(I,V)).
                            option((I,V),valid):- included_attr(I,_), _any(value(I,V)), not _clinguin_assume(value(I,_),true).

                            elem(attr_value_title_o_ddi(I,V), dropdown_menu_item, attr_value_title_o_dd(I)) :- option((I,V),_).
                            attr(attr_value_title_o_ddi(I,V), label, V) :- option((I,V),_).
                            when(attr_value_title_o_ddi(I,V), click, call, add_assumption(value(I,V))) :- option((I,V),_).
                            attr(attr_value_title_o_ddi(I,V), class, ("text-danger")) :- option((I,V),invalid).
                            attr(attr_value_title_o_ddi(I,V), class, ("disabled")) :- option((I,V),_), _clinguin_assume(value(I,V2),true).

                            elem(attr_value_title_o_ddi(I,remove), dropdown_menu_item, attr_value_title_o_dd(I)) :- included_attr(I,_).
                            attr(attr_value_title_o_ddi(I,remove), icon, "fa-ban") :- included_attr(I,_).
                            attr(attr_value_title_o_ddi(I,remove), class, "text-info") :- included_attr(I,_).
                            when(attr_value_title_o_ddi(I,remove), click, call, remove_assumption_signature(value(I,any))) :- included_attr(I,_).





    % +++++++ Messages for explanation
    % elem(message_unsat(C),message,window)      :- _clinguin_mus(constraint(C,("boolean";"table"))), explanation(I,M), C=(I,_).
    % attr(message_unsat(C),title,"Explanation") :- _clinguin_mus(constraint(C,("boolean";"table"))), explanation(I,M), C=(I,_).
    % attr(message_unsat(C),type,"error")        :- _clinguin_mus(constraint(C,("boolean";"table"))), explanation(I,M), C=(I,_).
    % attr(message_unsat(C),class,("bg-danger";"border-danger"))        :- _clinguin_mus(constraint(C,("boolean";"table"))), explanation(I,M), C=(I,_).
    % attr(message_unsat(C),message,M)           :- _clinguin_mus(constraint(C,("boolean";"table"))) , explanation(I,M), C=(I,_).

    % +++++++ Menu bar

    elem(menu_bar, menu_bar, window).
    attr(menu_bar, title, "Product Configuration").
    attr(menu_bar, icon, "fa-cog").


        elem(menu_bar_restart, button, menu_bar).
        attr(menu_bar_restart, label, "Restart").
        attr(menu_bar_restart, icon, "fa-arrows-rotate").
        attr(menu_bar_restart, class, "btn-menu-danger").
        attr(menu_bar_restart, class, "border-0").
        when(menu_bar_restart, click, call, restart).

        elem(menu_bar_stop, button, menu_bar).
        attr(menu_bar_stop, label, "Stop browsing").
        attr(menu_bar_stop, icon, "fa-stop").
        attr(menu_bar_stop, class, "btn-menu-danger").
        attr(menu_bar_stop, class, "border-0").
        attr(menu_bar_stop, class, "disabled"):- not _clinguin_browsing.
        when(menu_bar_stop, click, call, stop_browsing).

        % elem(menu_bar_clear, button, menu_bar).
        % attr(menu_bar_clear, label, "Clear").
        % attr(menu_bar_clear, icon, "fa-trash").
        % attr(menu_bar_clear, class, "btn-menu-danger").
        % attr(menu_bar_clear, class, "border-0").
        % when(menu_bar_clear, click, call, clear_assumptions).

        % elem(menu_bar_upload, button, menu_bar).
        % attr(menu_bar_upload, label, "Upload").
        % attr(menu_bar_upload, class, "btn-menu").
        % attr(menu_bar_upload, icon, "fa-upload").
        % when(menu_bar_upload, click, update, (upload_modal, visibility, shown)).


        % elem(menu_bar_download, button, menu_bar).
        % attr(menu_bar_download, label, "Download").
        % attr(menu_bar_download, class, "btn-menu").
        % attr(menu_bar_download, icon, "fa-download").
        % when(menu_bar_download, click, call, download("#show . #show include(I) : include(I), type(I,T), part(T).#show value(X,V) : value(X,V), type(X,T), integer(T). #show value(X,V) : value(X,V), type(X,T), discrete(T).", "current_solution.coom")).


        elem(menu_bar_select, button, menu_bar).
        attr(menu_bar_select, label, "Pick current solution").
        attr(menu_bar_select, class, "btn-menu").
        attr(menu_bar_select, icon, "fa-hand-pointer").
        when(menu_bar_select, click, call, select("#show . #show include(I) : include(I), type(I,T), part(T). #show value(X,V) : value(X,V), type(X,T), integer(T). #show value(X,V) : value(X,V), type(X,T), discrete(T).")).

        elem(menu_bar_next, button, menu_bar).
        attr(menu_bar_next, label, "Find next solution").
        attr(menu_bar_next, class, "btn-menu").
        attr(menu_bar_next, icon, "fa-forward-step").
        when(menu_bar_next, click, call, next_solution(optN)).

            % +++++++ Upload COOM file modal

            elem(upload_modal, modal, window).
            attr(upload_modal, title, "Upload COOM file").

            elem(c1, container, upload_modal).
            attr(c1, child_layout, flex).
            attr(c1, flex_direction, row_reverse).
            attr(c1, class, "align-items-center").

                elem(f1, file_input, c1).
                attr(f1, accept, ".coom").
                when(f1, change, call, upload_file).


% elem(s, sidebar, window).
% attr(s, position, end).
% attr(s, title, "Optimization").
% attr(s, class, ("bg-tertiary-500")).
