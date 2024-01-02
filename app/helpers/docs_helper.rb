module DocsHelper
    def image_for_doc(doc)
        str = ""
        if !doc.image.attached?
          str += "<div class='h-52 w-52 text-gray-400 text-2xl font-bold grid justify-items-center items-center shadow mx-auto my-auto'><span class='mx-auto my-auto'>#{doc.name.upcase}</span></div>".html_safe
        else
          str += image_tag(doc.image.representation(resize_to_limit: [500, 500]).processed.url, class: "shadow mx-auto my-auto")
        end
        str.html_safe
    end
end
