--地獄将軍・メフィスト
-- 效果：
-- 这张卡攻击守备表示的怪兽时，若攻击力超过那个守备力，给与对方那个数值的战斗伤害。这张卡对对方造成战斗伤害时，对方随机丢弃1张手卡。
function c46820049.initial_effect(c)
	-- 这张卡对对方造成战斗伤害时，对方随机丢弃1张手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46820049,0))  --"丢弃手牌"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c46820049.condition)
	e1:SetTarget(c46820049.target)
	e1:SetOperation(c46820049.operation)
	c:RegisterEffect(e1)
	-- 这张卡攻击守备表示的怪兽时，若攻击力超过那个守备力，给与对方那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 效果发动条件：造成战斗伤害的玩家不是自己
function c46820049.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果处理目标设定：设置丢弃手牌的操作信息
function c46820049.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为丢弃手牌，对象为对方1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 效果处理流程：检索对方手牌并随机选择1张丢弃
function c46820049.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有手牌组成卡片组
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(ep,1)
	-- 将选中的手牌以丢弃和效果原因送入墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
