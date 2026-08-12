--リチュア・ノエリア
-- 效果：
-- 这张卡召唤成功时，可以从自己卡组上面把5张卡翻开。翻开的卡之中有仪式魔法卡或者名字带有「遗式」的怪兽卡的场合，那些卡全部送去墓地。剩下的卡用喜欢的顺序回到卡组最下面。
function c63942761.initial_effect(c)
	-- 这张卡召唤成功时，可以从自己卡组上面把5张卡翻开。翻开的卡之中有仪式魔法卡或者名字带有「遗式」的怪兽卡的场合，那些卡全部送去墓地。剩下的卡用喜欢的顺序回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63942761,0))  --"卡组确认"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c63942761.target)
	e1:SetOperation(c63942761.operation)
	c:RegisterEffect(e1)
end
-- 效果发动目标检查函数
function c63942761.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能将卡组最上方5张卡送去墓地（作为能否发动效果的判定）
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) end
end
-- 过滤函数：筛选出仪式魔法卡（类型为0x82）或名字带有「遗式」（字段为0x3a）的怪兽卡
function c63942761.filter(c)
	return c:GetType()==0x82 or (c:IsSetCard(0x3a) and c:IsType(TYPE_MONSTER))
end
-- 效果处理核心函数
function c63942761.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查玩家是否能将卡组最上方5张卡送去墓地，不能则不处理
	if not Duel.IsPlayerCanDiscardDeck(tp,5) then return end
	-- 确认玩家卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	-- 获取玩家卡组最上方的5张卡
	local g=Duel.GetDecktopGroup(tp,5)
	local sg=g:Filter(c63942761.filter,nil)
	if sg:GetCount()>0 then
		-- 设置接下来的操作不触发洗牌检测
		Duel.DisableShuffleCheck()
		-- 将翻开的卡中满足条件的卡因效果且作为翻开状态送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)
	end
	-- 让玩家对卡组最上方剩下的卡（5减去送去墓地的卡数量）进行排序
	Duel.SortDecktop(tp,tp,5-sg:GetCount())
	for i=1,5-sg:GetCount() do
		-- 获取当前卡组最上方的一张卡
		local mg=Duel.GetDecktopGroup(tp,1)
		-- 将该卡移动到卡组最下方
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
end
