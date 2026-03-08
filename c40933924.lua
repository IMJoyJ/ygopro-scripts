--黒蠍盗掘団
-- 效果：
-- 这张卡给与对方玩家战斗伤害时，对方从卡组选择1张魔法卡送去墓地，之后卡组洗切。
function c40933924.initial_effect(c)
	-- 这张卡给与对方玩家战斗伤害时，对方从卡组选择1张魔法卡送去墓地，之后卡组洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40933924,0))  --"选择1张魔法卡送去墓地"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c40933924.condition)
	e1:SetOperation(c40933924.operation)
	c:RegisterEffect(e1)
end
-- 造成战斗伤害时的发动玩家不是自己
function c40933924.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 选择对方卡组中1张魔法卡送去墓地
function c40933924.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向对方玩家提示“请选择要送去墓地的卡”
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从对方卡组中选择1张魔法卡
	local g=Duel.SelectMatchingCard(1-tp,Card.IsType,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL)
	-- 将选中的魔法卡以效果原因送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
