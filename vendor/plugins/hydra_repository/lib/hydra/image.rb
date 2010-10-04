require "hydra"
require "httparty"

module Hydra
class Image < ActiveFedora::Base
  include Hydra::ModelMethods
  include HTTParty

  class Hydra::Image::NoFileError < RuntimeError; end;
  class Hydra::Image::UnknownImageType < RuntimeError; end;

  DS_DEFAULTS = {
    :max => {:op => "convert", :convertTo => "jpg"},
    :thumbnail => {:op => "resize",:newWidth=> 100},
    :screen => {:op => "resize", :newWidth => 960}
  }

  attr_accessor :derivations

  def initialize( attrs={})
    existing_image = true if attrs[:pid]
    @generate_derivatives = attrs[:derivatives] ? attrs[:derivatives] : false
    super
    unless existing_image
      if attrs.has_key?(:file) #&& attrs[:file].class == File
        self.image = attrs[:file]
        attrs.delete(:file)
      elsif attrs.has_key?(:stream) && attrs.has_key?(:image_type)
        data = attrs[:stream]
        attrs.delete(:stream)
        self.image = data, attrs[:image_type]
      else
        raise Hydra::Image::NoFileError, "No file indicated."
      end
    end
  end

  has_relationship "parts", :is_part_of, :inbound => true
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositor', :string
  end

  def image=(image_data)
    delete_file_datastreams
    case image_data
      when File
        master_from_file image_data
      when Array
        needs_cleanup = true
        image_file =  string_to_file(image_data[0],"MASTER",image_data[1])
        master_from_file image_file
      when String
        master_from_url image_data
      else
        raise Hydra::Image::UnknownImageType, "Specified image is neither a file nor an appropriate image blob: #{image_data.class.to_s}"
    end
    save
    File.delete(image_file.path) if needs_cleanup
    generate_derivatives if @generate_derivatives
  end

  def ds_options
    if @derivations
      return DS_DEFAULTS.merge( @derivations )
    else
      return DS_DEFAULTS
    end
  end

  def derivative_datastream ds_name
    opts = ds_options[ds_name]
    ds_location = derivation_url(ds_name, opts)
    ds = ActiveFedora::Datastream.new(:dsid => ds_name.to_s.upcase, :label => ds_name.to_s.upcase, :dsLocation => ds_location, :controlGroup => "M", :mimeType => "image/jpeg")
    add_datastream(ds)
    save
  end

  def thumbnail
    datastreams["THUMBNAIL"].content
  end

  def screen
    datastreams["SCREEN"].content
  end

  def max
    datastreams["MAX"].content
  end

  private

  def master_from_file image_file
    add_file_datastream(image_file,:dsid=>"MASTER",:label=>"MASTER")
    
  end

  def master_from_url url
    puts "creating datastream object for: #{url}"
    mime_types = MIME::Types.of(url.split(/\//).last)
    mime_type ||= mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type
    ds = ActiveFedora::Datastream.new(:dsid=> "MASTER", :label => "MASTER", :controlGroup => "M", :dsLocation => url, :mimeType=>mime_type)
    add_datastream(ds)
    save
  end

  def generate_derivatives
    [:max,:thumbnail,:screen].each {|ds| derivative_datastream ds }
  end

  def delete_file_datastreams
    ["MASTER","MAX","THUMBNAIL","SCREEN"].each {|ds_name| datastreams[ds_name].delete if datastreams.has_key? ds_name}
  end

  def derivation_url ds_name, opts={}
    source_ds_name = ds_name == :max ? "MASTER" : "MAX"
    if ds_name == :max && datastreams["MASTER"].attributes["mimeType"] == "image/jpeg"
      url = datastream_url(source_ds_name)
    else
      opts_array=[]
      opts.merge!(:url => datastream_url(source_ds_name)).each{|k,v| opts_array << "#{k}=#{v}" }
      url = "http://localhost:8983/imagemanip/ImageManipulation?" + opts_array.join("&")
    end
    return url
  end

  def string_to_file blob, suffix, ext=nil
    file_name = Time.now.strftime("%Y%m%d-%H%M%S")
    ext = "jpg" unless suffix == "MASTER"
    f = File.new("#{Rails.root}/tmp/#{file_name}-#{suffix}.#{ext}","w")
    f.write blob
    f.close
    return f
  end

  def datastream_url ds_name="MASTER"
    "http://127.0.0.1:8983/fedora/objects/#{pid}/datastreams/#{ds_name}/content"
  end

end
end
