--フレムベル・ウルキサス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。每次这张卡给与对方基本分战斗伤害，这张卡的攻击力上升300。
function c53714009.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽参与同调
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
-- 判断造成战斗伤害的玩家是否与这张卡的控制者不同
function c53714009.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 使这张卡的攻击力上升300点
function c53714009.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 将攻击力上升300的效果注册给这张卡，并在标准重置条件下重置
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
