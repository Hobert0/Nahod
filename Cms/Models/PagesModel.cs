using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Cms.Models
{
    public class PagesModel
    {
        public int Id { get; set; }
        public string Slug { get; set; }
        [AllowHtml]
        public string Content { get; set; }
        public string Title { get; set; }
        public string Date { get; set; }
        public bool Menu { get; set; }
    }
}