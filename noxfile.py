import os

import nox

nox.options.sessions = ["test", "lint_pylint", "lint_flake8"]

DEFAULT_PYTHON = "3.10"

EDITABLE_TESTS = True
PYTHON_VERSIONS = [DEFAULT_PYTHON]

if "GITHUB_ACTIONS" in os.environ:
    PYTHON_VERSIONS = ["3.10"]
    EDITABLE_TESTS = False


@nox.session(python=DEFAULT_PYTHON)
def lint_flake8(session):
    session.install("-e", ".[lint_flake8]")
    session.run("flake8", "clinguin", "tests")


@nox.session(python=DEFAULT_PYTHON)
def lint_pylint(session):
    session.install("-e", ".[lint_pylint]")
    session.run("pylint", "clinguin")


@nox.session(python=DEFAULT_PYTHON)
def format(session):
    session.install("-e", ".[format]")
    check = "check" in session.posargs

    autoflake_args = [
        "--in-place",
        "--imports=fillname",
        "--ignore-init-module-imports",
        "--remove-unused-variables",
        "-r",
        "clinguin",
        "tests",
    ]
    if check:
        autoflake_args.remove("--in-place")
    session.run("autoflake", *autoflake_args)

    isort_args = ["--profile", "black", "clinguin", "tests"]
    if check:
        isort_args.insert(0, "--check")
        isort_args.insert(1, "--diff")
    session.run("isort", *isort_args)

    black_args = ["clinguin", "tests"]
    if check:
        black_args.insert(0, "--check")
        black_args.insert(1, "--diff")
    session.run("black", *black_args)


@nox.session(python=PYTHON_VERSIONS)
def test(session):
    session.install("pytest")
    if EDITABLE_TESTS:
        session.install("-e", ".")
    else:
        session.install(".")
    session.run("pytest")