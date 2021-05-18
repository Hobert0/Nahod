using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class VariantAttributesModel
    {
        public int Id { get; set; }
        public string AttrName { get; set; }
        public int ProdId { get; set; }
        public string AttrValue { get; set; }
        public string Stock { get; set; }
    }
}