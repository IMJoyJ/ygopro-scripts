--E・HERO ブルーメ
-- 效果：
-- 这张卡不能通常召唤。这张卡用「花瓣」的效果才能特殊召唤。对方只能把「元素英雄 鲜花女郎」选择作为攻击对象。每次给与对方玩家战斗伤害，这张卡的攻击力上升200，守备力下降200。
function c51085303.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「花瓣」的效果才能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 每次给与对方玩家战斗伤害，这张卡的攻击力上升200，守备力下降200
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51085303,0))  --"攻守变化"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c51085303.adcon)
	e2:SetOperation(c51085303.adop)
	c:RegisterEffect(e2)
	-- 对方只能把「元素英雄 鲜花女郎」选择作为攻击对象
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c51085303.atlimit)
	c:RegisterEffect(e3)
	-- 不能直接攻击
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e4)
end
-- 造成战斗伤害时的敌方玩家
function c51085303.adcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 满足条件时增加攻击力并减少守备力
function c51085303.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:GetDefense()>=200 then
		-- 增加攻击力200
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
-- 攻击时只能选择此卡为攻击对象
function c51085303.atlimit(e,c)
	return c:IsFacedown() or not c:IsCode(51085303)
end
