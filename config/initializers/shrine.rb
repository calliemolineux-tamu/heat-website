# frozen_string_literal: true

require 'shrine'

# Storage backend selection:
#   * test               -> in-memory (fast, no network, nothing to clean up)
#   * R2_BUCKET present   -> Cloudflare R2 (S3-compatible) - production / staging
#   * otherwise           -> local disk under public/uploads (contributors without R2 creds)
if Rails.env.test?
  require 'shrine/storage/memory'

  Shrine.storages = {
    cache: Shrine::Storage::Memory.new,
    store: Shrine::Storage::Memory.new
  }
elsif ENV['R2_BUCKET'].present?
  require 'shrine/storage/s3'

  # Cloudflare R2 speaks the S3 API. Notes specific to R2:
  #   * region is ignored by R2 - "auto" is Cloudflare's recommended value
  #   * R2_ENDPOINT is the S3 API host: https://<ACCOUNT_ID>.r2.cloudflarestorage.com
  #   * force_path_style is required (R2 does not do virtual-host-style buckets)
  #   * no :public / ACL option - R2 has no per-object ACLs; make the bucket
  #     publicly readable in the Cloudflare dashboard instead (r2.dev subdomain
  #     or a custom domain) and point R2_PUBLIC_URL at that.
  s3_options = {
    access_key_id: ENV.fetch('R2_ACCESS_KEY_ID'),
    secret_access_key: ENV.fetch('R2_SECRET_ACCESS_KEY'),
    region: 'auto',
    bucket: ENV.fetch('R2_BUCKET'),
    endpoint: ENV.fetch('R2_ENDPOINT'),
    force_path_style: true
  }

  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: 'cache', **s3_options), # temporary
    store: Shrine::Storage::S3.new(prefix: 'store', **s3_options)  # permanent
  }

  # The S3 API endpoint above is NOT browser-accessible. Generated <img> URLs
  # must point at the bucket's public r2.dev URL / custom domain instead.
  public_url = ENV.fetch('R2_PUBLIC_URL')
  Shrine.plugin :url_options,
                cache: { host: public_url, public: true },
                store: { host: public_url, public: true }
else
  require 'shrine/storage/file_system'

  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache'),
    store: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/store')
  }
end

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data # for retaining the cached file across form redisplays
Shrine.plugin :restore_cached_data    # for re-extracting metadata when attaching a cached file
Shrine.plugin :validation_helpers
Shrine.plugin :validation
Shrine.plugin :determine_mime_type
