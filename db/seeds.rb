# frozen_string_literal: true

# NOTE: the placeholder 2024 dev-team "members" that used to be seeded here were
# removed on purpose (they kept reappearing after every Heroku deploy because the
# release phase runs `rails db:seed`, which used find_or_create_by and recreated
# them whenever they'd been deleted from the live database).

# NOTE: the placeholder 2024 links that used to be seeded here were removed for the
# same reason as the members above - db:seed reruns on every Heroku deploy release,
# so find_or_create_by kept bringing them back after they'd been deleted.
