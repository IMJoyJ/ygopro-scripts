--白兵戦型お手伝いロボ
-- 效果：
-- 这张卡每次战斗破坏对方怪兽，自己抽1张卡，之后从手卡选择1张卡放回卡组最下面。
function c47025270.initial_effect(c)
	-- 这张卡每次战斗破坏对方怪兽，自己抽1张卡，之后从手卡选择1张卡放回卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47025270,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetTarget(c47025270.drtg)
	e1:SetOperation(c47025270.drop)
	c:RegisterEffect(e1)
end
-- 效果作用
function c47025270.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果作用
function c47025270.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行抽卡效果，若成功则继续处理后续效果
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从手卡选择1张卡作为目标
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选中的卡放回卡组最下面
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
