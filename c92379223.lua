--黄金の征服王
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「黄金国巫妖」怪兽存在的场合，可以从以下效果选择1个发动。
-- ●选除外的自己的「黄金国永生药」魔法·陷阱卡3种类各1张回到卡组，场上的卡全部破坏。
-- ●选除外的自己的「黄金乡」魔法·陷阱卡3种类各1张回到卡组，对方基本分变成一半。那之后，自己基本分回复对方基本分的数值。
function c92379223.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「黄金国巫妖」怪兽存在的场合，可以从以下效果选择1个发动。●选除外的自己的「黄金国永生药」魔法·陷阱卡3种类各1张回到卡组，场上的卡全部破坏。●选除外的自己的「黄金乡」魔法·陷阱卡3种类各1张回到卡组，对方基本分变成一半。那之后，自己基本分回复对方基本分的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,92379223+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c92379223.condition)
	e1:SetTarget(c92379223.target)
	e1:SetOperation(c92379223.activate)
	c:RegisterEffect(e1)
end
-- 过滤表侧表示的「黄金国巫妖」怪兽
function c92379223.filter(c)
	return c:IsSetCard(0x1142) and c:IsFaceup()
end
-- 过滤表侧表示的「黄金国永生药」卡
function c92379223.tdfilter1(c)
	return c:IsSetCard(0x2142) and c:IsFaceup()
end
-- 过滤表侧表示的「黄金乡」卡
function c92379223.tdfilter2(c)
	return c:IsSetCard(0x143) and c:IsFaceup()
end
-- 发动条件：自己场上有表侧表示的「黄金国巫妖」怪兽存在
function c92379223.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「黄金国巫妖」怪兽
	return Duel.IsExistingMatchingCard(c92379223.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标与选项选择：检查各分支发动条件并让玩家选择一个效果发动
function c92379223.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己除外区表侧表示的「黄金国永生药」卡片组
	local g1=Duel.GetMatchingGroup(c92379223.tdfilter1,tp,LOCATION_REMOVED,0,nil)
	-- 获取自己除外区表侧表示的「黄金乡」卡片组
	local g2=Duel.GetMatchingGroup(c92379223.tdfilter2,tp,LOCATION_REMOVED,0,nil)
	-- 判断选项1是否满足条件（除外的「黄金国永生药」卡至少有3种且场上有其他卡）
	local b1=g1:GetClassCount(Card.GetCode)>2 and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	local b2=g2:GetClassCount(Card.GetCode)>2
	if chk==0 then return b1 or b2 end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(92379223,0)  --"场上的卡全部破坏"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(92379223,1)  --"对方基本分变成一半"
		opval[off-1]=2
		off=off+1
	end
	-- 让玩家从满足条件的选项中选择1个效果
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==1 then
		-- 获取场上除此卡以外的所有卡片组
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
		-- 设置操作信息：破坏场上除此卡以外的所有卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 效果处理：执行所选效果（返回卡组并全场破坏，或返回卡组并削减/回复基本分）
function c92379223.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==1 then
		-- 获取自己除外区表侧表示的「黄金国永生药」卡片组
		local g=Duel.GetMatchingGroup(c92379223.tdfilter1,tp,LOCATION_REMOVED,0,nil)
		if g:GetClassCount(Card.GetCode)>=3 then
			-- 设置选择提示：选择要返回卡组的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			-- 选择3种类各1张卡名不同的「黄金国永生药」卡
			local tg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
			if not tg then return end
			-- 显示选中卡片的目标提示动画
			Duel.HintSelection(tg)
			-- 将选中的3张卡返回卡组并洗牌
			Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			-- 获取实际操作返回卡组的卡片组
			local og=Duel.GetOperatedGroup()
			-- 若有卡片返回主卡组则洗切卡组
			if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
			local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
			if ct==3 then
				-- 中断效果处理
				Duel.BreakEffect()
				-- 获取场上除此卡以外的所有卡片组
				local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
				if #g>0 then
					-- 将场上的卡全部破坏
					Duel.Destroy(g,REASON_EFFECT)
				end
			end
		end
	else
		-- 获取自己除外区表侧表示的「黄金乡」卡片组
		local g=Duel.GetMatchingGroup(c92379223.tdfilter2,tp,LOCATION_REMOVED,0,nil)
		if g:GetClassCount(Card.GetCode)>=3 then
			-- 设置选择提示：选择要返回卡组的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			-- 选择3种类各1张卡名不同的「黄金乡」卡
			local tg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
			if not tg then return end
			-- 显示选中卡片的目标提示动画
			Duel.HintSelection(tg)
			-- 将选中的3张卡返回卡组并洗牌
			Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			-- 获取实际操作返回卡组的卡片组
			local og=Duel.GetOperatedGroup()
			-- 若有卡片返回主卡组则洗切卡组
			if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
			local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
			if ct==3 then
				-- 中断效果处理
				Duel.BreakEffect()
				-- 将对方基本分变成一半
				Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
				-- 自己基本分回复对方基本分的数值
				Duel.Recover(tp,Duel.GetLP(1-tp),REASON_EFFECT)
			end
		end
	end
end
