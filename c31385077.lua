--カオス・ゴッデス－混沌の女神－
-- 效果：
-- 光属性调整＋调整以外的暗属性怪兽2只以上
-- ①：1回合1次，从手卡把1只光属性怪兽送去墓地，以自己墓地1只5星以上的暗属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽不能作为同调素材。
function c31385077.initial_effect(c)
	-- 添加同调召唤手续，需要1只光属性调整和2只以上暗属性调整以外的怪兽
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
-- 过滤满足条件的光属性怪兽（用于支付效果代价）
function c31385077.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGraveAsCost()
end
-- 选择并把1只光属性怪兽从手卡送去墓地作为效果代价
function c31385077.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在满足条件的光属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c31385077.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只光属性怪兽
	local g=Duel.SelectMatchingCard(tp,c31385077.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡送去墓地作为效果代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤满足条件的5星以上暗属性怪兽（用于特殊召唤）
function c31385077.filter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，选择满足条件的墓地暗属性怪兽
function c31385077.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31385077.filter(chkc,e,tp) end
	-- 检查场上是否存在空位用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的暗属性怪兽
		and Duel.IsExistingTarget(c31385077.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只墓地暗属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c31385077.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果，将目标怪兽特殊召唤并设置不能作为同调素材
function c31385077.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使特殊召唤的怪兽不能作为同调素材
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
