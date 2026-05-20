--E・HERO クノスペ
-- 效果：
-- 每次给与对方玩家战斗伤害，这张卡的攻击力上升100，守备力下降100。只要除这张卡以外的名字带有「元素英雄」的怪兽在自己场上表侧表示存在，对方不能把这张卡选择作为攻击对象，这张卡可以直接攻击对方玩家。
function c62107981.initial_effect(c)
	-- 只要除这张卡以外的名字带有「元素英雄」的怪兽在自己场上表侧表示存在，……这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c62107981.atcon)
	c:RegisterEffect(e1)
	-- 每次给与对方玩家战斗伤害，这张卡的攻击力上升100，守备力下降100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62107981,0))  --"攻守变化"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c62107981.adcon)
	e2:SetOperation(c62107981.adop)
	c:RegisterEffect(e2)
	-- 只要除这张卡以外的名字带有「元素英雄」的怪兽在自己场上表侧表示存在，对方不能把这张卡选择作为攻击对象……
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c62107981.atcon)
	-- 设置不能成为攻击对象效果的过滤函数（自身不免疫该效果时适用）
	e3:SetValue(aux.imval1)
	c:RegisterEffect(e3)
end
-- 判断受到战斗伤害的玩家是否为对方
function c62107981.adcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 给与对方战斗伤害时，若此卡在场上表侧表示且守备力大于等于100，则使其攻击力上升100，守备力下降100
function c62107981.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:GetDefense()>=100 then
		-- 这张卡的攻击力上升100
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-100)
		c:RegisterEffect(e2)
	end
end
-- 过滤自己场上表侧表示的名字带有「元素英雄」的怪兽
function c62107981.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
-- 判断自己场上是否存在除这张卡以外的表侧表示的「元素英雄」怪兽
function c62107981.atcon(e)
	-- 检索自己场上是否存在至少1张除自身以外的表侧表示的「元素英雄」怪兽
	return Duel.IsExistingMatchingCard(c62107981.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
