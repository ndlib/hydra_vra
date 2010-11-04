fluid_1_2=fluid_1_2||{};(function($,fluid){var STATE_INITIAL="state_initial",STATE_CHANGED="state_changed",STATE_REVERTED="state_reverted";function defaultRenderer(that,targetContainer){var str=that.options.strings;var markup="<span class='flc-undo'><a href='#' class='flc-undo-undoControl'>"+str.undo+"</a><a href='#' class='flc-undo-redoControl'>"+str.redo+"</a></span>";var markupNode=$(markup).attr({role:"region","aria-live":"polite","aria-relevant":"all"});targetContainer.append(markupNode);return markupNode}function refreshView(that){if(that.state===STATE_INITIAL){that.locate("undoContainer").hide();that.locate("redoContainer").hide()}else{if(that.state===STATE_CHANGED){that.locate("undoContainer").show();that.locate("redoContainer").hide()}else{if(that.state===STATE_REVERTED){that.locate("undoContainer").hide();that.locate("redoContainer").show()}}}}var bindHandlers=function(that){that.locate("undoControl").click(function(){if(that.state!==STATE_REVERTED){fluid.model.copyModel(that.extremalModel,that.component.model);that.component.updateModel(that.initialModel,that);that.state=STATE_REVERTED;refreshView(that);that.locate("redoControl").focus()}return false});that.locate("redoControl").click(function(){if(that.state!==STATE_CHANGED){that.component.updateModel(that.extremalModel,that);that.state=STATE_CHANGED;refreshView(that);that.locate("undoControl").focus()}return false});return{modelChanged:function(newModel,oldModel,source){if(source!==that){that.state=STATE_CHANGED;fluid.model.copyModel(that.initialModel,oldModel);refreshView(that)}}}};fluid.undoDecorator=function(component,userOptions){var that=fluid.initView("undo",null,userOptions);that.container=that.options.renderer(that,component.container);fluid.initDomBinder(that);fluid.tabindex(that.locate("undoControl"),0);fluid.tabindex(that.locate("redoControl"),0);that.component=component;that.initialModel={};that.extremalModel={};fluid.model.copyModel(that.initialModel,component.model);fluid.model.copyModel(that.extremalModel,component.model);that.state=STATE_INITIAL;refreshView(that);var listeners=bindHandlers(that);that.returnedOptions={listeners:listeners};return that};fluid.defaults("undo",{selectors:{undoContainer:".flc-undo-undoControl",undoControl:".flc-undo-undoControl",redoContainer:".flc-undo-redoControl",redoControl:".flc-undo-redoControl"},strings:{undo:"undo",redo:"redo"},renderer:defaultRenderer})})(jQuery,fluid_1_2);