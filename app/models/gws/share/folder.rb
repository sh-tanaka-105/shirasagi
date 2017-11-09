class Gws::Share::Folder
  include SS::Document
  include Gws::Reference::User
  include Gws::Reference::Site
  include Gws::Addon::ReadableSetting
  include Gws::Addon::GroupPermission
  #include SS::UserPermission
  include Gws::Addon::File
  include Gws::Share::DescendantsFileInfo

  store_in collection: :gws_share_folders

  seqid :id
  field :name, type: String
  field :order, type: Integer, default: 0
  field :state, type: String, default: "closed"
  field :share_max_file_size, type: Integer, default: 0
  field :share_max_folder_size, type: Integer, default: 0
  attr_accessor :in_share_max_file_size_mb
  attr_accessor :in_share_max_folder_size_mb

  has_many :files, class_name: "Gws::Share::File", order: { created: -1 }, dependent: :destroy, autosave: false

  permit_params :name, :order, :share_max_file_size, :in_share_max_file_size_mb, :share_max_folder_size, :in_share_max_folder_size_mb

  before_validation :set_share_max_file_size
  before_validation :set_share_max_folder_size

  validates :name, presence: true, uniqueness: { scope: :site_id }
  validates :share_max_file_size, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }

  default_scope ->{ order_by order: 1 }

  class << self
    def search(params)
      criteria = where({})
      return criteria if params.blank?

      criteria = criteria.keyword_in params[:keyword], :name if params[:keyword].present?
      criteria
    end

    def download_root_path
      "#{Rails.root}/private/files/gws_share_files/"
    end

    def zip_path(folder_id)
      self.download_root_path + folder_id.to_s.split(//).join("/") + "/_/#{folder_id}"
    end

    def create_download_directory(download_dir)
      FileUtils.mkdir_p(download_dir) unless Dir.exist?(download_dir)
    end

    def create_zip(zipfile, items, filename_duplicate_flag, folder_updated_time)
      if File.exist?(zipfile)
        return if folder_updated_time < File.stat(zipfile).mtime
        File.unlink(zipfile) if folder_updated_time > File.stat(zipfile).mtime
      end

      Zip::File.open(zipfile, Zip::File::CREATE) do |zip_file|
        items.each do |item|
          if File.exist?(item.path)
            if filename_duplicate_flag == 0
              zip_file.add(NKF::nkf('-sx --cp932', item.name), item.path)
            elsif filename_duplicate_flag == 1
              zip_file.add(NKF::nkf('-sx --cp932',item._id.to_s + "_" + item.name), item.path)
            end
          end
        end
      end
    end
  end

  private

  def set_share_max_file_size
    return if in_share_max_file_size_mb.blank?
    self.share_max_file_size = Integer(in_share_max_file_size_mb) * 1_024 * 1_024
  end

  def set_share_max_folder_size
    return if in_share_max_folder_size_mb.blank?
    self.share_max_folder_size = Integer(in_share_max_folder_size_mb) * 1_024 * 1_024
  end
end
