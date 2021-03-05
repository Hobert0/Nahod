using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class VariantModel
    {
        [JsonProperty("name")]
        public string name { get; set; }
    }
}