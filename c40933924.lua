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
-- 效果发动条件：确认受到战斗伤害的玩家是对方（ep~=tp），即此卡给予对方玩家战斗伤害时才满足条件。
function c40933924.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果的发动处理：由对方玩家从卡组选择1张魔法卡送去墓地，之后卡组洗切。
function c40933924.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向对方玩家显示“请选择要送去墓地的卡”的提示，用于选择卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 令对方玩家从自己的卡组中筛选并选取1张魔法卡（TYPE_SPELL）作为送去墓地的对象。
	local g=Duel.SelectMatchingCard(1-tp,Card.IsType,1-tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL)
	-- 将所选择的魔法卡以效果原因（REASON_EFFECT）送去墓地，完成“送去墓地”的处理。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
