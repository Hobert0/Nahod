using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Cms.Models
{
    public class SlideshowModel
    {
        public int Id { get; set; }
        public string Page { get; set; }
        public string Image { get; set; }
        public string Url { get; set; }
        public string Title { get; set; }
        public int Active { get; set; }
        public HttpPostedFileBase[] TitleImage { get; set; }
    }
}