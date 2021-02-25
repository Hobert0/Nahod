using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class CategoriesModel
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Slug { get; set; }
        public string Topcat { get; set; }
        public string Topcat2 { get; set; }
        public string Maincat { get; set; }
        public string Description { get; set; }
        public string Image { get; set; }
        public HttpPostedFileBase[] TitleImage { get; set; }
    }
}