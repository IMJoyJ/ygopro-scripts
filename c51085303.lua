--E・HERO ブルーメ
-- 效果：
-- 这张卡不能通常召唤。这张卡用「花瓣」的效果才能特殊召唤。对方只能把「元素英雄 鲜花女郎」选择作为攻击对象。每次给与对方玩家战斗伤害，这张卡的攻击力上升200，守备力下降200。
function c51085303.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。这张卡用「花瓣」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 每次给与对方玩家战斗伤害，这张卡的攻击力上升200，守备力下降200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51085303,0))  --"攻守变化"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c51085303.adcon)
	e2:SetOperation(c51085303.adop)
	c:RegisterEffect(e2)
	-- 对方只能把「元素英雄 鲜花女郎」选择作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c51085303.atlimit)
	c:RegisterEffect(e3)
	-- 对方只能把「元素英雄 鲜花女郎」选择作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e4)
end
-- 攻击力上升效果的触发条件：判定受到战斗伤害的一方（ep）不是自己（tp），即自己给与对方战斗伤害时触发。
function c51085303.adcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 处理攻守变化：获取效果持有者；若它仍与效果关联、表侧表示且当前守备力不低于200，则给它注册一个攻击力上升200的效果，并克隆一个守备力下降200的效果。
function c51085303.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:GetDefense()>=200 then
		-- 这张卡的攻击力上升200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-200)
		c:RegisterEffect(e2)
	end
end
-- 选择攻击对象的限制条件：对方不能选择里侧表示的卡或卡名不是「元素英雄 鲜花女郎」的卡作为攻击对象，因此只能选择表侧表示的这张卡攻击。
function c51085303.atlimit(e,c)
	return c:IsFacedown() or not c:IsCode(51085303)
end
