--星の金貨
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：选自己2张手卡加入对方手卡。那之后，自己从卡组抽2张。
function c43528009.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：选自己2张手卡加入对方手卡。那之后，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,43528009+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c43528009.target)
	e1:SetOperation(c43528009.activate)
	c:RegisterEffect(e1)
end
-- 效果发动前的合法性检查：确认自己手牌除本卡外至少有2张卡可以送对方手牌，且自己可以抽2张；若满足则允许发动，并登记后续抽卡的操作信息。
function c43528009.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时条件判定：自己手卡中存在至少2张可被选择的手牌（除本卡自身外），并且我方玩家当前可以进行2张抽卡，满足则返回true允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,2,e:GetHandler()) and Duel.IsPlayerCanDraw(tp,2) end
	-- 登记操作信息：本连锁将执行抽卡效果，预计我方玩家抽2张卡，供相关效果（如“星尘龙”等）进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理时的实际执行：从自己手卡选择2张送入对方手卡，确认并洗切双方手牌后，中断时点，再让自己抽2张卡。
function c43528009.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示发动玩家tp选择要加入对方手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(43528009,0))  --"请选择要加入对方手卡的卡"
	-- 从发动玩家tp的手卡（LOCATION_HAND）中选择2张卡（使用aux.TRUE表示所有手牌均符合条件），选中结果存入ag。
	local ag=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,2,2,nil)
	if ag:GetCount()==2 then
		-- 将选中的2张手牌ag送给对方玩家（1-tp）的手卡，原因是效果，实现“选自己2张手卡加入对方手卡”。
		Duel.SendtoHand(ag,1-tp,REASON_EFFECT)
		-- 将已送入对方手卡的这些卡展示给发动玩家tp确认。
		Duel.ConfirmCards(tp,ag)
		-- 洗切发动玩家tp的手卡，因为其手卡数量发生变化且后续要抽卡，需要重新随机排列。
		Duel.ShuffleHand(tp)
		-- 洗切对方玩家（1-tp）的手卡，使加入的2张卡混入对方手牌并隐藏顺序。
		Duel.ShuffleHand(1-tp)
		-- 中断当前效果处理，使“送卡/洗切”与“抽卡”成为不同时点，严格体现“那之后”的先后关系。
		Duel.BreakEffect()
		-- 发动玩家tp以效果原因从卡组抽2张卡，执行“自己从卡组抽2张”的效果。
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
