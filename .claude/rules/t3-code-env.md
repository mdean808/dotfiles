# Running Electron apps from T3 Code

T3 Code starts agent shells with `ELECTRON_RUN_AS_NODE=1` in the environment.
Any Electron binary started from that shell runs as plain Node instead of as
an app. Cypress is an Electron binary, so `cypress run`, `cypress verify` and
`yarn test:unit` die before the runner starts, with:

    The Test Runner unexpectedly exited via a exit event with signal SIGILL

That is the environment, not the code or the Cypress install. Clear the
variable for the one command, and don't reinstall Cypress or move the run
into Docker to get around it:

    env -u ELECTRON_RUN_AS_NODE yarn test:unit
    env -u ELECTRON_RUN_AS_NODE npx cypress run --component --spec '<path>'

Don't unset it for the whole session or in settings, because T3 sets it on
purpose and its tools may depend on it. Check with `env | grep ELECTRON_RUN_AS_NODE`; outside T3 Code it is unset
and the prefix changes nothing.
