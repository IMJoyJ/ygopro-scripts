--盗み見ゴブリン
-- 效果：
-- 对方从卡组上面把3张卡翻开。自己从那之中选择1张回到对方卡组最下面，剩下的卡用喜欢的顺序回到对方卡组上面。
function c52263685.initial_effect(c)
	-- 效果原文：对方从卡组上面把3张卡翻开。自己从那之中选择1张回到对方卡组最下面，剩下的卡用喜欢的顺序回到对方卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52263685.target)
	e1:SetOperation(c52263685.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查对方卡组是否至少有3张牌，若满足条件则设置目标玩家为当前玩家。
function c52263685.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断当前玩家对方卡组是否有不少于3张牌。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=3 end
	-- 效果作用：将连锁的目标玩家设为当前玩家。
	Duel.SetTargetPlayer(tp)
end
-- 效果原文：对方从卡组上面把3张卡翻开。自己从那之中选择1张回到对方卡组最下面，剩下的卡用喜欢的顺序回到对方卡组上面。
function c52263685.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果作用：判断目标玩家对方卡组是否为空，若为空则返回。
	if Duel.GetFieldGroupCount(p,0,LOCATION_DECK)==0 then return end
	-- 效果作用：确认对方卡组最上方3张牌。
	Duel.ConfirmDecktop(1-p,3)
	-- 效果作用：获取对方卡组最上方3张牌组成的手牌组。
	local g=Duel.GetDecktopGroup(1-p,3)
	local ct=g:GetCount()
	if ct>0 then
		-- 效果作用：提示当前玩家选择一张牌放回对方卡组底部。
		Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(52263685,0))  --"请选择放回卡组最下方的卡"
		local sg=g:Select(p,1,1,nil)
		-- 效果作用：将选中的牌移动到对方卡组底部。
		Duel.MoveSequence(sg:GetFirst(),SEQ_DECKBOTTOM)
		-- 效果作用：确认对方查看了被移至卡组底的那张牌。
		Duel.ConfirmCards(1-p,sg)
		-- 效果作用：让当前玩家对对方卡组最上方剩余的牌进行排序。
		Duel.SortDecktop(p,1-p,ct-1)
		-- 效果作用：再次确认对方卡组最上方剩余的牌。
		Duel.ConfirmDecktop(1-p,ct-1)
	end
end
