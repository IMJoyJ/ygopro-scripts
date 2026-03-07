--超化合獣メタン・ハイド
-- 效果：
-- 8星二重怪兽×2
-- ①：这张卡超量召唤成功时，以自己墓地1只二重怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：只要持有超量素材的这张卡在怪兽区域存在，对方不能把自己场上的二重怪兽作为攻击对象，也不能作为效果的对象。
-- ③：二重怪兽召唤成功时，把这张卡1个超量素材取除才能发动。对方必须把自身的手卡·场上1张卡送去墓地。
function c38026562.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足类型为二重的怪兽进行超量召唤，等级为8，需要2只怪兽
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsXyzType,TYPE_DUAL),8,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功时，以自己墓地1只二重怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38026562,0))  --"特殊召唤墓地二重怪兽"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c38026562.spcon)
	e1:SetTarget(c38026562.sptg)
	e1:SetOperation(c38026562.spop)
	c:RegisterEffect(e1)
	-- ②：只要持有超量素材的这张卡在怪兽区域存在，对方不能把自己场上的二重怪兽作为攻击对象，也不能作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c38026562.con)
	e2:SetValue(c38026562.atlimit)
	c:RegisterEffect(e2)
	-- ③：二重怪兽召唤成功时，把这张卡1个超量素材取除才能发动。对方必须把自身的手卡·场上1张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c38026562.con)
	-- 设置效果目标为场上的二重怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_DUAL))
	-- 设置效果值为不会成为对方的卡的效果对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：二重怪兽召唤成功时，把这张卡1个超量素材取除才能发动。对方必须把自身的手卡·场上1张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38026562,1))  --"对方卡送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c38026562.tgcon)
	e4:SetCost(c38026562.tgcost)
	e4:SetTarget(c38026562.tgtg)
	e4:SetOperation(c38026562.tgop)
	c:RegisterEffect(e4)
end
-- 判断此卡是否为超量召唤成功
function c38026562.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤满足条件的墓地二重怪兽
function c38026562.spfilter(c,e,tp)
	return c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标为满足条件的墓地二重怪兽
function c38026562.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c38026562.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的二重怪兽
		and Duel.IsExistingTarget(c38026562.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地二重怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c38026562.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c38026562.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断此卡是否持有超量素材
function c38026562.con(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 设置效果值为不会成为对方的卡的效果对象
function c38026562.atlimit(e,c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL)
end
-- 判断是否有二重怪兽被召唤成功
function c38026562.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_DUAL)
end
-- 判断此卡是否能移除1个超量素材作为代价
function c38026562.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置送去墓地效果的目标为对方场上的卡
function c38026562.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上有无卡牌
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)>0 end
	-- 设置效果操作信息为送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_ONFIELD+LOCATION_HAND)
end
-- 执行送去墓地操作
function c38026562.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的卡
	local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
	if g:GetCount()>0 then
		-- 提示对方选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 显示选择的卡被选为对象
		Duel.HintSelection(sg)
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(sg,REASON_RULE,1-tp)
	end
end
