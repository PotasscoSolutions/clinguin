from clinguin.server.application.backends.clingo_backend import ClingoBackend
from clingo import Control, parse_term


class CustomBackend(ClingoBackend):

    def __init__(self, args):
        self._auto_solve = False
        super().__init__(args)

    def _init_ds_constructors(self):
        super()._init_ds_constructors()
        self._add_domain_state_constructor("_ds_auto_solve")

    @property
    def _ds_auto_solve(self):
        return (
            "#defined _clinguin_auto_solve/0. "
            + ("_clinguin_auto_solve." if self._auto_solve else "")
            + "\n"
        )

    def stop_auto_solve(self):
        self._auto_solve = False
        self._clear_cache(["_ds_auto_solve"])
        # self._outdate()

    def continue_auto_solve(self):
        self._auto_solve = True
        self._clear_cache(["_ds_auto_solve"])
        # self._outdate()

    def add_assumption(self, atom, value="true"):
        atom_symbol = parse_term(atom)
        if atom_symbol not in [a[0] for a in self._assumptions]:
            self._add_assumption(atom_symbol, value)
            if self._handler:
                self._handler.cancel()
                self._handler = None
            self._iterator = None
        else:
            self._logger.warning("Assumption already exists. Not adding it again.")

    def remove_assumption(self, atom):
        atom_symbol = parse_term(atom)
        for a, v in self._assumptions:
            if a == atom_symbol:
                self._assumptions.remove((a, v))
                if self._handler:
                    self._handler.cancel()
                    self._handler = None
                self._iterator = None
                return
