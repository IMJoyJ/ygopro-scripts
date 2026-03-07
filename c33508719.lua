--メタモルポット
-- 效果：
-- ①：这张卡反转的场合发动。有手卡的玩家把那些手卡全部丢弃。双方从卡组抽5张。
function c33508719.initial_effect(c)
	-- ①：这张卡反转的场合发动。有手卡的玩家把那些手卡全部丢弃。双方从卡组抽5张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c33508719.target)
	e1:SetOperation(c33508719.operation)
	c:RegisterEffect(e1)
end
-- 设置效果的处理目标为双方手牌丢弃和双方抽卡
function c33508719.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为双方手牌丢弃
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,0)
	-- 设置操作信息为双方各抽5张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,5)
end
-- 效果处理函数，执行手牌丢弃和抽卡效果
function c33508719.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家手牌组
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	-- 如果手牌存在则将其送去墓地
	if g:GetCount()>0 then Duel.SendtoGrave(g,REASON_DISCARD+REASON_EFFECT) end
	-- 中断当前效果处理流程
	Duel.BreakEffect()
	-- 当前玩家从卡组抽5张卡
	Duel.Draw(tp,5,REASON_EFFECT)
	-- 对方玩家从卡组抽5张卡
	Duel.Draw(1-tp,5,REASON_EFFECT)
end
