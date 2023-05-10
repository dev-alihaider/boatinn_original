$(document).ready(function() {

  var imagesUpload = (function() {
    var moduleWrap, imageBlock;
    return {
      fileReaderHandler: function(input) {
        if (input.files && input.files[0]) {
          var reader = new FileReader();
          var loadImage = $(input).parents(imageBlock).find('.loadImage');
          reader.onload = function(e) {
            loadImage.attr('src', e.target.result).hide().fadeIn(650);
          };
          reader.readAsDataURL(input.files[0]);
        }
      },
      inputOnChange: function() {
        $(moduleWrap).on('change', '.inputImg', function(e) {
          imagesUpload.fileReaderHandler(this);
          var currentBlock = imagesUpload.getCurrentBlock(this);
          currentBlock.find('.remove-btn input[type="checkbox"]').prop("checked", false);
        });
      },
      renderAddBlockOrder: function(setMessage){
        var message = setMessage || 'Image ';
        
        $(moduleWrap).find(imageBlock).each(function(index, item) {
          var label = $(item).find('.jsLabel');
          var order = parseInt(index + 1);

          label.text(message + order);
        });
      },
      removeImage: function() {
        $(moduleWrap).on('click', '.remove-btn', function(e){
          var parent = imagesUpload.getCurrentBlock(this);
          
          imagesUpload.removeImageData(parent);
        });
      },
      getCurrentBlock: function(item) {
        return $(item).parents(imageBlock);
      },
      removeImageBlock: function() {
        $(moduleWrap).on('click', '.remove-block', function() {
          var currentBlock = imagesUpload.getCurrentBlock(this);
          var length = $(this).parents(moduleWrap).find(imageBlock).length;
          if (length > 1) {
            currentBlock.remove();
          } else {
            imagesUpload.removeImageData(currentBlock);
          }

          imagesUpload.renderAddBlockOrder();
        });
      },
      removeImageData: function(item) {
        item.find('.inputImg').val('');
        item.find('.loadImage').attr('src', '');
      },
      addImageBlock: function() {
        $(moduleWrap).find('.add-btn').on('click', function(e){
          var parent = $(this).parents(moduleWrap);
          var elToClone = parent.find(imageBlock);

          var clonedEl = elToClone.last().clone();
          
          imagesUpload.removeImageData(clonedEl);
          parent.find('.form-inner').append(clonedEl);

          imagesUpload.renderAddBlockOrder();

        });
      },
      init: function(setModuleWrap, setImageBlock){
        moduleWrap = setModuleWrap;
        imageBlock = setImageBlock;
        
        this.inputOnChange();
        this.renderAddBlockOrder();
        this.removeImage();
        this.removeImageBlock();
        this.addImageBlock();
      }
    }
  })();

  imagesUpload.init('.community-form', '.jsGroup');

  // language tabs

  $(".language-tabs").on("click", "li", function() {
    $(this).addClass("active").siblings().removeClass("active");
    var $this = $(this);
    
    $(".tab-pane").each(function(){
      $(this).find('.tab-content').each(function(){
        var contentAttr = $(this).data("lang");
        var tabHref = $this.find("a").attr("href").slice(1);
        if(contentAttr === tabHref) {
          $(this).removeClass('hidden').siblings().addClass('hidden');
        }
      });
    });
  });

  $('[data-provider="summernote"]').summernote({
    focus: true,
      toolbar: [
        ['style', ['bold']],
        ['para', ['ul', 'ol', 'paragraph']],
        ['insert', ['linkDialogShow']],
        ['view', ['codeview']]
      ]
  });

    $('[data-provider="summernote_compose_email"]').summernote({
        focus: true,
        toolbar: [
            ['style', ['bold']],
            ['para', ['ul', 'ol', 'paragraph']],
            ['insert', ['linkDialogShow']],
            ['view', ['codeview']],
            ['insert', ['link', 'hr']]
        ]
    });

  var smoothScroll = (function(){
    var anchor, sectionId, speed;
    
    return {
      onClick: function(setParent, setAnchor) {
        $(setParent).on('click', setAnchor, function(event){
          event.preventDefault();
          $(this).parents('.accordion-item').siblings().find('li').removeClass('active');
          $(this).parent().addClass('active').siblings().removeClass('active');
          
          sectionId = $(this).attr('href');
          if(sectionId.length) {
            smoothScroll.scrollToSection(sectionId);
            $(sectionId).parent('div').siblings().find('div').removeClass('active');
            $(sectionId).addClass('active').siblings().removeClass('active');
          }
        })
      },
      scrollToSection: function(sectionId) {
        if ($(sectionId).length) {
          $('html, body').animate({
            scrollTop: $(sectionId).offset().top - 200
          }, speed);
          // $(sectionId).addClass('active').siblings().removeClass('active');
        }
      },
      init: function(setParent, setAnchor, setSpeed){
        anchor = setAnchor;
        parent = setParent;
        speed = setSpeed;
        
        this.onClick(anchor);
      }
    }
  })();

  smoothScroll.init('.accordion-item','.accordion-link', 1000);

  $('.listing-admin-cancel').on('click', function(event) {
    var acceptWin = confirm('Are you sure?');
    
    if(acceptWin) {
      this.submit();
    } else {
      return false;
    }
  });

  $("select#to").on("change", function(){
    if($(this).val() === "manual") {
      $(".compose-emails-block").fadeIn();    
    } else {
      $(".compose-emails-block").fadeOut();  
    }
  });

});
