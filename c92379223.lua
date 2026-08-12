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
-- 过滤函数：用于筛选自己场上表侧表示的「黄金国巫妖」怪兽
function c92379223.filter(c)
	return c:IsSetCard(0x1142) and c:IsFaceup()
end
-- 过滤函数：用于筛选自己除外区表侧表示的「黄金国永生药」魔法·陷阱卡
function c92379223.tdfilter1(c)
	return c:IsSetCard(0x2142) and c:IsFaceup()
end
-- 过滤函数：用于筛选自己除外区表侧表示的「黄金乡」魔法·陷阱卡
function c92379223.tdfilter2(c)
	return c:IsSetCard(0x143) and c:IsFaceup()
end
-- 发动条件：检查自己场上是否存在「黄金国巫妖」怪兽
function c92379223.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「黄金国巫妖」怪兽
	return Duel.IsExistingMatchingCard(c92379223.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标选择与处理分支判定
function c92379223.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己除外区所有表侧表示的「黄金国永生药」魔法·陷阱卡
	local g1=Duel.GetMatchingGroup(c92379223.tdfilter1,tp,LOCATION_REMOVED,0,nil)
	-- 获取自己除外区所有表侧表示的「黄金乡」魔法·陷阱卡
	local g2=Duel.GetMatchingGroup(c92379223.tdfilter2,tp,LOCATION_REMOVED,0,nil)
	-- 检查是否满足分支1的发动条件：除外区有3种以上不同卡名的「黄金国永生药」卡，且场上有其他卡可以破坏
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
	-- 让玩家选择要发动的效果分支
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==1 then
		-- 获取场上除这张卡以外的所有卡片
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
		-- 设置效果处理信息：分类为破坏，目标为场上所有的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 效果处理：根据选择的分支，执行对应的回卡组及后续效果
function c92379223.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==1 then
		-- 获取自己除外区所有表侧表示的「黄金国永生药」魔法·陷阱卡
		local g=Duel.GetMatchingGroup(c92379223.tdfilter1,tp,LOCATION_REMOVED,0,nil)
		if g:GetClassCount(Card.GetCode)>=3 then
			-- 提示玩家选择要返回卡组的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			-- 从符合条件的卡片中选择3张卡名不同的卡
			local tg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
			if #tg>0 then
				-- 为选中的卡片显示被选为对象的动画效果
				Duel.HintSelection(tg)
			end
			-- 将选中的卡片送回持有者卡组并洗牌
			Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			-- 获取上一步操作中实际被送回卡组的卡片组
			local og=Duel.GetOperatedGroup()
			-- 若有卡片被送回主卡组，则洗切卡组
			if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
			local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
			if ct==3 then
				-- 中断当前效果，使后续的破坏处理与回卡组不视为同时处理
				Duel.BreakEffect()
				-- 获取场上除这张卡以外的所有卡片
				local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
				if #g>0 then
					-- 破坏场上所有的卡
					Duel.Destroy(g,REASON_EFFECT)
				end
			end
		end
	else
		-- 获取自己除外区所有表侧表示的「黄金乡」魔法·陷阱卡
		local g=Duel.GetMatchingGroup(c92379223.tdfilter2,tp,LOCATION_REMOVED,0,nil)
		if g:GetClassCount(Card.GetCode)>=3 then
			-- 提示玩家选择要返回卡组的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			-- 从符合条件的卡片中选择3张卡名不同的卡
			local tg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
			if #tg>0 then
				-- 为选中的卡片显示被选为对象的动画效果
				Duel.HintSelection(tg)
			end
			-- 将选中的卡片送回持有者卡组并洗牌
			Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			-- 获取上一步操作中实际被送回卡组的卡片组
			local og=Duel.GetOperatedGroup()
			-- 若有卡片被送回主卡组，则洗切卡组
			if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
			local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
			if ct==3 then
				-- 中断当前效果，使后续的生命值变化处理与回卡组不视为同时处理
				Duel.BreakEffect()
				-- 将对方的基本分变成一半（向上取整）
				Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
				-- 自己回复等同于对方当前基本分数值的基本分
				Duel.Recover(tp,Duel.GetLP(1-tp),REASON_EFFECT)
			end
		end
	end
end
