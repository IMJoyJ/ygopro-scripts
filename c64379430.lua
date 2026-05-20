--終焉の精霊
-- 效果：
-- 这张卡的攻击力·守备力变成从游戏中除外的暗属性怪兽数量×300的数值。这张卡被破坏送去墓地时，从游戏中除外的暗属性怪兽全部回到墓地。
function c64379430.initial_effect(c)
	-- 这张卡的攻击力变成从游戏中除外的暗属性怪兽数量×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(c64379430.value)
	c:RegisterEffect(e1)
	-- 这张卡的守备力变成从游戏中除外的暗属性怪兽数量×300的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_DEFENSE)
	e2:SetValue(c64379430.value)
	c:RegisterEffect(e2)
	-- 这张卡被破坏送去墓地时，从游戏中除外的暗属性怪兽全部回到墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64379430,0))  --"返回墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c64379430.retcon)
	e3:SetTarget(c64379430.rettg)
	e3:SetOperation(c64379430.retop)
	c:RegisterEffect(e3)
end
-- 过滤除外区表侧表示的暗属性怪兽
function c64379430.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 计算并返回自身攻击力·守备力的数值
function c64379430.value(e,c)
	-- 获取双方除外区表侧表示的暗属性怪兽数量并乘以300
	return Duel.GetMatchingGroupCount(c64379430.filter,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)*300
end
-- 检查此卡是否因破坏而送去墓地
function c64379430.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 效果发动的目标确认，获取除外区所有表侧表示的暗属性怪兽并设置送去墓地的操作信息
function c64379430.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方除外区表侧表示的暗属性怪兽组
	local g=Duel.GetMatchingGroup(c64379430.filter,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	-- 设置效果处理信息为将除外的暗属性怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果处理，将所有除外的暗属性怪兽全部送回墓地
function c64379430.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方除外区表侧表示的暗属性怪兽组
	local g=Duel.GetMatchingGroup(c64379430.filter,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	-- 将目标怪兽组以效果和返回墓地的原因送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
end
