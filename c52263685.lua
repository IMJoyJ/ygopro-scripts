--盗み見ゴブリン
-- 效果：
-- 对方从卡组上面把3张卡翻开。自己从那之中选择1张回到对方卡组最下面，剩下的卡用喜欢的顺序回到对方卡组上面。
function c52263685.initial_effect(c)
	-- 对方从卡组上面把3张卡翻开。自己从那之中选择1张回到对方卡组最下面，剩下的卡用喜欢的顺序回到对方卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52263685.target)
	e1:SetOperation(c52263685.activate)
	c:RegisterEffect(e1)
end
-- 发动时的目标处理：先检查发动条件（对方卡组是否有至少3张卡），然后将当前玩家（自己）设置为效果的对象玩家，表示由自己来选择卡片。
function c52263685.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：以发动者tp的视角，检查对方卡组是否存在至少3张卡，不足3张则不能发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=3 end
	-- 将当前连锁的对象玩家设置为tp（即自己），后续效果处理时通过CHAININFO_TARGET_PLAYER获取该玩家，用于选择卡片。
	Duel.SetTargetPlayer(tp)
end
-- 效果处理函数：获取对象玩家p（自己）；若p的对方卡组为0则终止；翻开对方卡组最上方3张；取得这3张卡的组g；若g非空，则给p显示选择提示，由p选择1张移动至对方卡组最下方；向对方确认该卡；再让p对剩余卡按喜好排序放回对方卡组最上方；最后向对方确认排列后的剩余卡。
function c52263685.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设置的对象玩家（即自己），赋值给p，作为后续选择/排序的玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 若对象玩家p的对方卡组数量为0，则无法进行翻卡，效果处理直接返回。
	if Duel.GetFieldGroupCount(p,0,LOCATION_DECK)==0 then return end
	-- 让对方玩家（1-p）翻开并确认其卡组最上方3张卡，即执行‘对方从卡组上面把3张卡翻开’。
	Duel.ConfirmDecktop(1-p,3)
	-- 获取对方卡组最上方3张卡作为卡组对象g，供随后选择放回最下方的卡。
	local g=Duel.GetDecktopGroup(1-p,3)
	local ct=g:GetCount()
	if ct>0 then
		-- 给玩家p（自己）发送卡片选择提示（内容为‘请选择放回卡组最下方的卡’），并将其写入选择消息缓存，供g:Select使用。
		Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(52263685,0))  --"请选择放回卡组最下方的卡"
		local sg=g:Select(p,1,1,nil)
		-- 将选中的那张卡移动到对方卡组最下端，对应‘选择1张回到对方卡组最下面’。
		Duel.MoveSequence(sg:GetFirst(),SEQ_DECKBOTTOM)
		-- 向对方玩家（1-p）展示被选中放回卡组最下面的卡，使其确认。
		Duel.ConfirmCards(1-p,sg)
		-- 让玩家p（自己）对剩余ct-1张卡进行排序并放回对方卡组最上方，对应‘剩下的卡用喜欢的顺序回到对方卡组上面’。
		Duel.SortDecktop(p,1-p,ct-1)
		-- 向对方玩家（1-p）确认排序后放回卡组最上方的剩余卡。
		Duel.ConfirmDecktop(1-p,ct-1)
	end
end
