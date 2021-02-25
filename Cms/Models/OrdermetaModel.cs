using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class OrdermetaModel
    {
        public int Id { get; set; }
        public string Ordernumber { get; set; }
        public string Product { get; set; }
        public string Productid { get; set; }
        public string Pieces { get; set; }
        public string Productimage { get; set; }
        public string Price { get; set; }
        public string Size { get; set; }
    }
}