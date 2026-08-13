--カオス・ゴッデス－混沌の女神－
-- 效果：
-- 光属性调整＋调整以外的暗属性怪兽2只以上
-- ①：1回合1次，从手卡把1只光属性怪兽送去墓地，以自己墓地1只5星以上的暗属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽不能作为同调素材。
function c31385077.initial_effect(c)
	-- 为这张卡添加同调召唤手续：光属性调整加上调整以外的暗属性怪兽至少2只作为同调素材。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_DARK),2)
	c:EnableReviveLimit()
	-- ①：1回合1次，从手卡把1只光属性怪兽送去墓地，以自己墓地1只5星以上的暗属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽不能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31385077,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c31385077.spcost)
	e1:SetTarget(c31385077.sptg)
	e1:SetOperation(c31385077.spop)
	c:RegisterEffect(e1)
end
-- 定义代价筛选函数：从手卡选出的作为代价的怪兽必须是光属性怪兽，且能够作为代价送去墓地。
function c31385077.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGraveAsCost()
end
-- 代价处理函数：发动时从手卡选择1只光属性怪兽送去墓地作为代价。
function c31385077.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：若手卡存在至少1只满足costfilter的光属性怪兽，则代价条件成立，可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c31385077.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 显示选择提示，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选出1只满足costfilter的光属性怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c31385077.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选出的手卡怪兽送去墓地，作为发动效果的代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义特殊召唤对象筛选函数：自己墓地的暗属性怪兽，等级在5星以上，并且可以被效果特殊召唤。
function c31385077.filter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择函数：先检查自己主要怪兽区有空位且墓地存在符合条件的对象；选择对象时仅能选择自己墓地的暗属性5星以上可特殊召唤怪兽。
function c31385077.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31385077.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的主要怪兽区域空位，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足filter条件的暗属性5星以上怪兽，且能成为此效果的对象。
		and Duel.IsExistingTarget(c31385077.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足filter条件的暗属性5星以上怪兽，并将其设置为效果的对象。
	local g=Duel.SelectTarget(tp,c31385077.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理信息，表明本次效果处理将进行特殊召唤，对象为已选择的1张墓地怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得对象怪兽，若卡仍与效果关联则将其特殊召唤，并为该怪兽附加不能作为同调素材的效果。
function c31385077.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象怪兽（唯一目标）。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与此效果关联，则将其以表侧表示特殊召唤到自己的主要怪兽区；特殊召唤成功后继续处理限制效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽不能作为同调素材。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
