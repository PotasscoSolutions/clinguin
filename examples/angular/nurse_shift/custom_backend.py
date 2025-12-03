from clinguin.server.application.backends.clingo_backend import ClingoBackend


class CustomBackend(ClingoBackend):
    
    def __init__(self, args):
        self._auto_solve = False
        super().__init__(args)

    def _init_ds_constructors(self):
        super()._init_ds_constructors()
        self._add_domain_state_constructor("_ds_auto_solve")

    @property
    def _ds_auto_solve(self):
        return "#defined _clinguin_auto_solve/0. " + \
               ("_clinguin_auto_solve." if self._auto_solve else "") + "\n"

    def stop_auto_solve(self):
        self._auto_solve = False
        self._clear_cache(["_ds_auto_solve"])
        self._outdate()

    def continue_auto_solve(self):
        self._auto_solve = True
        self._clear_cache(["_ds_auto_solve"])
        self._outdate()