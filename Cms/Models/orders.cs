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
    
    public partial class orders
    {
        public int id { get; set; }
        public string ordernumber { get; set; }
        public string name { get; set; }
        public string surname { get; set; }
        public string address { get; set; }
        public string city { get; set; }
        public string zip { get; set; }
        public string phone { get; set; }
        public string email { get; set; }
        public string companyname { get; set; }
        public string ico { get; set; }
        public string dic { get; set; }
        public string icdph { get; set; }
        public string date { get; set; }
        public string payment { get; set; }
        public string shipping { get; set; }
        public int status { get; set; }
        public string finalprice { get; set; }
        public string billnumber { get; set; }
        public string name_shipp { get; set; }
        public string surname_shipp { get; set; }
        public string address_shipp { get; set; }
        public string companyname_shipp { get; set; }
        public string city_shipp { get; set; }
        public string zip_shipp { get; set; }
        public string phone_shipp { get; set; }
        public string comment { get; set; }
        public string usedcoupon { get; set; }
        public Nullable<int> userid { get; set; }
    }
}
