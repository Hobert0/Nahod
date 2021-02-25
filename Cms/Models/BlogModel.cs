using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Cms.Models
{
    public class BlogModel
    {
        public int Id { get; set; }
        public string Slug { get; set; }
        [AllowHtml]
        public string Content { get; set; }
        public string Title { get; set; }
        public string Date { get; set; }
        public bool Meno { get; set; }
        public string Excerpt { get; set; }
        public string Image { get; set; }
        public string Gallery { get; set; }
        public HttpPostedFileBase[] TitleImage { get; set; }
        public HttpPostedFileBase[] ImageGallery { get; set; }
    }
}