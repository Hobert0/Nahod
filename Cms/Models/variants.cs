//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Cms.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class variants
    {
        public int id { get; set; }
        public int prod_id { get; set; }
        public string price { get; set; }
        public string stock { get; set; }
        public string number { get; set; }
        public int attribute_id { get; set; }
        public string value { get; set; }
        public bool deleted { get; set; }
    }
}
