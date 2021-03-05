using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class VariantModel
    {
        public string Price { get; set; }
        public string Stock { get; set; }
        public string Number { get; set; }
        public string AttributeId { get; set; }
        public string Value { get; set; }
    }
}