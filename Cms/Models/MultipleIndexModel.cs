using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using PagedList;

namespace Cms.Models
{
    public class MultipleIndexModel
    {
        public IEnumerable<Cms.Models.products> ProductModel { get; set; }
        public IEnumerable<Cms.Models.pages> PagesModel { get; set; }
        public IEnumerable<Cms.Models.slideshow> SlideshowModel { get; set; }
        public UsersModel UsersModel { get; set; }
        public OrdersModel OrdersModel { get; set; }
        public CategoriesModel Categories { get; set; }
        public CategoriesModel CategoriesEditModel { get; set; }
        public BrandsModel Brands { get; set; }
        public BrandsModel BrandsEditModel { get; set; }
        public CouponsModel Coupons { get; set; }
        public CouponsModel CouponsEditModel { get; set; }
        public AdminModel AdminLoginModel { get; set; }
        public UsersmetaModel UsersmetaModel { get; set; }
        public WishlistModel WishlistModel { get; set; }
        public NewsletterModel NewsletterModel { get; set; }
        public EmailSendModel EmailSendModel { get; set; }
        public IEnumerable<Cms.Models.orders> OrderDataModel { get; set; }
        public IEnumerable<Cms.Models.ordermeta> OrderMetaModel { get; set; }
        public IEnumerable<Cms.Models.e_settings> EsettingsModel { get; set; }
        public IEnumerable<Cms.Models.settings> SettingsModel { get; set; }
        public IEnumerable<Cms.Models.categories> CategoriesModel { get; set; }
        public IEnumerable<Cms.Models.brands> BrandsModel { get; set; }
        public IEnumerable<Cms.Models.blog> BlogModel { get; set; }

        public IEnumerable<Cms.Models.coupons> CouponsModel { get; set; }
        public IPagedList<Cms.Models.products> ProductsPaged { get; set; }
        public IPagedList<Cms.Models.users> AllUsersPaged { get; set; }
        public IEnumerable<Cms.Models.usersmeta> AllUsersMetaModel { get; set; }
        public IEnumerable<Cms.Models.wishlist> AllWishlistModel { get; set; }
        public IEnumerable<Cms.Models.newsletter> AllNewslettersModel { get; set; }
        public IEnumerable<Cms.Models.users> AllUsers { get; set; }
        public IPagedList<Cms.Models.newsletter> AllNewslettersPaged { get; set; }
    }
}