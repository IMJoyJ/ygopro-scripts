--フレムベル・ウルキサス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。每次这张卡给与对方基本分战斗伤害，这张卡的攻击力上升300。
function c53714009.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要“调整＋调整以外的怪兽1只以上”（此处调整和调整以外的怪兽均无额外限制）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	-- 每次这张卡给与对方基本分战斗伤害，这张卡的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53714009,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c53714009.atkcon)
	e2:SetOperation(c53714009.atkop)
	c:RegisterEffect(e2)
end
-- 条件判断：本次战斗伤害是由这张卡给与对方基本分（ep≠tp，即受到伤害的玩家不是这张卡的控制者）时，效果才满足发动条件。
function c53714009.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果处理：若这张卡仍表侧表示且与所发动效果保持关联，则赋予其攻击力上升300的效果，该效果会在离场、效果被无效等标准重置时机消失。
function c53714009.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
