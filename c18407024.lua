--エレキンギョ
-- 效果：
-- 这张卡直接攻击给与对方基本分战斗伤害时，对方选择1张手卡丢弃。
function c18407024.initial_effect(c)
	-- 这张卡直接攻击给与对方基本分战斗伤害时，对方选择1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18407024,0))  --"丢弃手牌"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c18407024.condition)
	e1:SetTarget(c18407024.target)
	e1:SetOperation(c18407024.operation)
	c:RegisterEffect(e1)
end
-- 效果适用的条件：对方为攻击玩家且没有攻击目标
function c18407024.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方为攻击玩家且没有攻击目标
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 效果的处理目标设定：对方选择1张手卡丢弃
function c18407024.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定连锁操作信息为对方丢弃手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 效果的处理流程：对方选择并丢弃1张手牌
function c18407024.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的手牌组
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	-- 提示对方选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local sg=g:Select(1-tp,1,1,nil)
	-- 将选择的卡片送去墓地并记录为丢弃和效果造成
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
