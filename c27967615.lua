--フュージョン・ウェポン
-- 效果：
-- 6星以下的融合怪兽才能装备。装备怪兽的攻击力·守备力上升1500。
function c27967615.initial_effect(c)
	-- 装备怪兽的攻击力·守备力上升1500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c27967615.target)
	e1:SetOperation(c27967615.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力·守备力上升1500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力·守备力上升1500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(1500)
	c:RegisterEffect(e3)
	-- 6星以下的融合怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c27967615.eqlimit)
	c:RegisterEffect(e4)
end
-- 限制装备对象为6星以下的融合怪兽。
function c27967615.eqlimit(e,c)
	return c:IsType(TYPE_FUSION) and c:IsLevelBelow(6)
end
-- 筛选满足条件的场上怪兽（6星以下的融合怪兽）。
function c27967615.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsLevelBelow(6)
end
-- 选择装备对象，要求为6星以下的融合怪兽。
function c27967615.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c27967615.filter(chkc) end
	-- 判断是否满足选择装备对象的条件。
	if chk==0 then return Duel.IsExistingTarget(c27967615.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个6星以下的融合怪兽作为装备对象。
	Duel.SelectTarget(tp,c27967615.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次效果的处理信息为装备。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给选中的怪兽。
function c27967615.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
