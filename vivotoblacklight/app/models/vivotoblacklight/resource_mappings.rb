# @author Darcy Branchini, Huda Khan
# @company Mann Library, Cornell University
# -*- encoding : utf-8 -*-
##Store mappings between files or terms and resource URIs
module Vivotoblacklight


class ResourceMappings
  @@highlightMappings = {
    "problems" => {
      "query_id" => "highlights",
      "vivo_collections" => {
        "problems" => Rails.application.config.VIVONamespace + "individual/n16864",
        "impacts" => Rails.application.config.VIVONamespace + "individual/n50290",
        "vulnerabilities" => Rails.application.config.VIVONamespace + "individual/n13097",
        "hazard-coastal" => Rails.application.config.VIVONamespace + "individual/n4447",
        "hazard-extreme" => Rails.application.config.VIVONamespace + "individual/n30495",
        "hazard-heat" => Rails.application.config.VIVONamespace + "individual/n3832",
        "hazard-downpours" => Rails.application.config.VIVONamespace + "individual/n88",
        "hazard-snowpack" => Rails.application.config.VIVONamespace + "individual/n11992",
        "hazard-drought" => Rails.application.config.VIVONamespace + "individual/n3231"
      }
    },
    "solutions" => {
      "query_id" => "highlights", 
      "vivo_collections" => {
        "adaptation" => Rails.application.config.VIVONamespace + "individual/n65129",
        "mitigation" => Rails.application.config.VIVONamespace + "individual/n5412",
        "solutions-agriculture" => Rails.application.config.VIVONamespace + "individual/n5548",
        "solutions-buildings" => Rails.application.config.VIVONamespace + "individual/n21650",
        "solutions-coastal" => Rails.application.config.VIVONamespace + "individual/n31231",
        "solutions-ecosystems" => Rails.application.config.VIVONamespace + "individual/n48719",
        "solutions-energy" => Rails.application.config.VIVONamespace + "individual/n14010",
        "solutions-public-health" => Rails.application.config.VIVONamespace + "individual/n151225",
        "solutions-telecommunications" => Rails.application.config.VIVONamespace + "individual/n14390",
        "solutions-transportation" => Rails.application.config.VIVONamespace + "individual/n23595",
        "solutions-water-resources" => Rails.application.config.VIVONamespace + "individual/n24558",
        "evaluate-solutions" => Rails.application.config.VIVONamespace + "individual/n29941"
      }
    },
    "actions" => {
      "query_id" => "highlights",
      "vivo_collections" => {
        "create-plan" => Rails.application.config.VIVONamespace + "individual/n29559",
        "find-funding" => Rails.application.config.VIVONamespace + "individual/n5964",
        "success-1" => Rails.application.config.VIVONamespace + "individual/n28035",
        "success-2" => Rails.application.config.VIVONamespace + "individual/n23172",
        "success-3" => Rails.application.config.VIVONamespace + "individual/n13496",
        "success-4" => Rails.application.config.VIVONamespace + "individual/n27607",
        "success-5" => Rails.application.config.VIVONamespace + "individual/n14266",
        "success-6" => Rails.application.config.VIVONamespace + "individual/n81509"
      }
    },
    "home" => {
      "query_id" => "highlights",
      "vivo_collections" => {
        "success-1" => Rails.application.config.VIVONamespace + "individual/n28035",
        "success-2" => Rails.application.config.VIVONamespace + "individual/n23172",
        "success-4" => Rails.application.config.VIVONamespace + "individual/n27607",
        "success-5" => Rails.application.config.VIVONamespace + "individual/n14266",
        "success-6" => Rails.application.config.VIVONamespace + "individual/n81509"
      }
    },
    "communicate" => {
      "query_id" => "highlights",
      "vivo_collections" => {
        "communicate-general" => Rails.application.config.VIVONamespace + "individual/n13004",
        "communicate-visual" => Rails.application.config.VIVONamespace + "individual/n16139"
      }
    },
    "maps" => {
      "query_id" => "data-maps",
      "vivo_collections" => {
        "primary-maps" => Rails.application.config.VIVONamespace + "individual/n190069",
        "secondary-maps" => Rails.application.config.VIVONamespace + "individual/n5308",
        "adaptation-maps" => Rails.application.config.VIVONamespace + "individual/n20051",
        "climateandweather-maps" => Rails.application.config.VIVONamespace + "individual/n25767",
        "energy-maps" => Rails.application.config.VIVONamespace + "individual/n40976",
        "flooding-maps" => Rails.application.config.VIVONamespace + "individual/n10179",
        "lakeriverstream-maps" => Rails.application.config.VIVONamespace + "individual/n9259",
        "plantanimals-maps" => Rails.application.config.VIVONamespace + "individual/n15824",
        "sealevel-maps" => Rails.application.config.VIVONamespace + "individual/n11946",
        "socialeconomic-maps" => Rails.application.config.VIVONamespace + "individual/n22797"
      }
    },
    "data_products" => {
      "query_id" => "data-maps",
      "vivo_collections" => {
        "primary-data" => Rails.application.config.VIVONamespace + "individual/n21908",
        "secondary-data" => Rails.application.config.VIVONamespace + "individual/n15584",
        "spatial-data" => Rails.application.config.VIVONamespace + "individual/n18698",
        "station-data" => Rails.application.config.VIVONamespace + "individual/n32645",
        "climateandweather-data" => Rails.application.config.VIVONamespace + "individual/n25065",
        "drought-data" => Rails.application.config.VIVONamespace + "individual/n16129",
        "energy-data" => Rails.application.config.VIVONamespace + "individual/n12343",
        "flooding-data" => Rails.application.config.VIVONamespace + "individual/n8317",
        "greatlakes-data" => Rails.application.config.VIVONamespace + "individual/n28115",
        "greenhousegases-data" => Rails.application.config.VIVONamespace + "individual/n20109",
        "plantanimals-data" => Rails.application.config.VIVONamespace + "individual/n3602",
        "sealevel-data" => Rails.application.config.VIVONamespace + "individual/n45678"
      }
    },
    "documents" => {
      "query_id" => "documents",
      "vivo_collections" => {
        "primary-documents" => Rails.application.config.VIVONamespace + "individual/n60153",
        "secondary-documents" => Rails.application.config.VIVONamespace + "individual/n4077"
      }
    }
  }

  def get_query_id(key) 
    return @@highlightMappings.values_at(key).first.values_at('query_id').first
  end

  def get_properties(key) 
    return @@highlightMappings.values_at(key).first.values_at('vivo_collections').first
  end
 
end
end