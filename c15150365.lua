--白い泥棒
-- 效果：
-- 这张卡造成对方玩家基本分伤害的时候，对方随机丢弃1张卡。
function c15150365.initial_effect(c)
	-- 这张卡造成对方玩家基本分伤害的时候，对方随机丢弃1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15150365,0))  --"丢弃手牌"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c15150365.condition)
	e1:SetTarget(c15150365.target)
	e1:SetOperation(c15150365.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：判断造成战斗伤害的玩家是否为对方
function c15150365.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果作用：设置连锁操作信息，指定对方丢弃手牌
function c15150365.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置连锁操作信息，指定对方丢弃手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 效果作用：检索对方场上的手牌并随机选择一张丢弃
function c15150365.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取对方场上的所有手牌
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	local sg=g:RandomSelect(ep,1)
	-- 效果作用：将选中的卡送去墓地并标记为丢弃和效果破坏
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
