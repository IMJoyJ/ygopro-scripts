--ドレミコード・エレガンス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从卡组把1只「七音服」灵摆怪兽在自己的灵摆区域放置。
-- ●从手卡把1只「七音服」灵摆怪兽表侧加入额外卡组。那之后，从卡组把灵摆刻度是奇数和偶数的「七音服」灵摆怪兽各1只在自己的灵摆区域放置。
-- ●从自己的灵摆区域把灵摆刻度是奇数和偶数的卡各1张表侧加入额外卡组，自己抽2张。
function c27870337.initial_effect(c)
	-- 创建效果，设置为发动时点，自由连锁，限制区域发动，发动次数限制为1次
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCountLimit(1,27870337+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c27870337.target)
	e1:SetOperation(c27870337.activate)
	e1:SetValue(c27870337.zones)
	c:RegisterEffect(e1)
end
-- 判断是否可以发动第3个效果：灵摆区存在奇数和偶数刻度的卡，且自己可以抽2张卡
function c27870337.sel3(tp)
	-- 检查玩家在灵摆区是否存在奇数刻度的「七音服」灵摆怪兽
	return Duel.IsExistingMatchingCard(c27870337.toexfilter1,tp,LOCATION_PZONE,0,1,nil)
		-- 检查玩家在灵摆区是否存在偶数刻度的「七音服」灵摆怪兽
		and Duel.IsExistingMatchingCard(c27870337.toexfilter2,tp,LOCATION_PZONE,0,1,nil)
		-- 检查玩家是否可以抽2张卡
		and Duel.IsPlayerCanDraw(tp,2)
end
-- 计算可发动区域，根据是否满足条件3和灵摆区是否为空来决定返回值
function c27870337.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	local b3=c27870337.sel3(tp)
	if b3 then return zone end
	-- 检查玩家灵摆区0号位置是否可用
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	-- 检查玩家灵摆区1号位置是否可用
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	if not b or p0 and p1 then return zone end
	if p0 then zone=zone-0x1 end
	if p1 then zone=zone-0x10 end
	return zone
end
-- 过滤函数，筛选「七音服」灵摆怪兽（不包括禁止的）
function c27870337.pendfilter(c)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 过滤函数，筛选「七音服」灵摆怪兽（奇数刻度）
function c27870337.pendfilter1(c)
	return c27870337.pendfilter(c) and c:GetCurrentScale()%2~=0
end
-- 过滤函数，筛选「七音服」灵摆怪兽（偶数刻度）
function c27870337.pendfilter2(c)
	return c27870337.pendfilter(c) and c:GetCurrentScale()%2==0
end
-- 过滤函数，筛选「七音服」灵摆怪兽（不考虑刻度）
function c27870337.toexfilter(c)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM)
end
-- 过滤函数，筛选奇数刻度的灵摆怪兽
function c27870337.toexfilter1(c)
	return c:GetCurrentScale()%2~=0
end
-- 过滤函数，筛选偶数刻度的灵摆怪兽
function c27870337.toexfilter2(c)
	return c:GetCurrentScale()%2==0
end
-- 效果选择函数，判断是否可以发动3个效果中的任意一个
function c27870337.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组是否存在「七音服」灵摆怪兽
	local b1=Duel.IsExistingMatchingCard(c27870337.pendfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查玩家灵摆区是否有空位
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
	-- 检查玩家手牌是否存在「七音服」灵摆怪兽
	local b2=Duel.IsExistingMatchingCard(c27870337.toexfilter,tp,LOCATION_HAND,0,1,nil)
		-- 检查玩家卡组是否存在奇数刻度的「七音服」灵摆怪兽
		and Duel.IsExistingMatchingCard(c27870337.pendfilter1,tp,LOCATION_DECK,0,1,nil)
		-- 检查玩家卡组是否存在偶数刻度的「七音服」灵摆怪兽
		and Duel.IsExistingMatchingCard(c27870337.pendfilter2,tp,LOCATION_DECK,0,1,nil)
		-- 检查玩家灵摆区0号和1号位置是否都可用
		and Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1)
	local b3=c27870337.sel3(tp)
	if chk==0 then return b1 or b2 or b3 end
	local off=1
	local ops,opval={},{}
	if b1 then
		ops[off]=aux.Stringid(27870337,0)  --"放置1只灵摆怪兽"
		opval[off]=0
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(27870337,1)  --"放置2只灵摆怪兽"
		opval[off]=1
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(27870337,2)  --"抽2张卡"
		opval[off]=2
		off=off+1
	end
	-- 让玩家选择发动效果的选项
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(0)
	elseif sel==1 then
		e:SetCategory(0)
	elseif sel==2 then
		e:SetCategory(CATEGORY_DRAW)
		-- 设置连锁操作的目标玩家为当前玩家
		Duel.SetTargetPlayer(tp)
		-- 设置连锁操作的目标参数为2
		Duel.SetTargetParam(2)
		-- 设置连锁操作信息为抽2张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	end
end
-- 效果发动函数，根据选择的选项执行对应操作
function c27870337.activate(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then
		-- 检查玩家灵摆区是否都不可用，若不可用则返回
		if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从玩家卡组选择1只「七音服」灵摆怪兽
		local sg=Duel.SelectMatchingCard(tp,c27870337.pendfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=sg:GetFirst()
		if tc then
			-- 将选中的卡移动到玩家灵摆区
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	elseif sel==1 then
		-- 提示玩家选择要加入额外卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(27870337,3))  --"请选择要加入额外卡组的卡"
		-- 从玩家手牌选择1只「七音服」灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c27870337.toexfilter,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选中的卡送入玩家额外卡组
		if g:GetCount()>0 and Duel.SendtoExtraP(g,nil,REASON_EFFECT)~=0
			-- 检查玩家灵摆区0号和1号位置是否都可用
			and Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1) then
			-- 获取玩家卡组中所有奇数刻度的「七音服」灵摆怪兽
			local g1=Duel.GetMatchingGroup(c27870337.pendfilter1,tp,LOCATION_DECK,0,nil)
			-- 获取玩家卡组中所有偶数刻度的「七音服」灵摆怪兽
			local g2=Duel.GetMatchingGroup(c27870337.pendfilter2,tp,LOCATION_DECK,0,nil)
			if g1:GetCount()>0 and g2:GetCount()>0 then
				-- 中断当前效果，使之后的效果处理视为不同时处理
				Duel.BreakEffect()
				-- 提示玩家选择要放置到场上的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
				local sg1=g1:Select(tp,1,1,nil)
				-- 提示玩家选择要放置到场上的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
				local sg2=g2:Select(tp,1,1,nil)
				sg1:Merge(sg2)
				local tc=sg1:GetFirst()
				while tc do
					-- 将选中的卡移动到玩家灵摆区
					Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
					tc=sg1:GetNext()
				end
			end
		end
	elseif sel==2 then
		-- 提示玩家选择要加入额外卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(27870337,3))  --"请选择要加入额外卡组的卡"
		-- 从玩家灵摆区选择1张奇数刻度的「七音服」灵摆怪兽
		local g1=Duel.SelectMatchingCard(tp,c27870337.toexfilter1,tp,LOCATION_PZONE,0,1,1,nil)
		-- 提示玩家选择要加入额外卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(27870337,3))  --"请选择要加入额外卡组的卡"
		-- 从玩家灵摆区选择1张偶数刻度的「七音服」灵摆怪兽
		local g2=Duel.SelectMatchingCard(tp,c27870337.toexfilter2,tp,LOCATION_PZONE,0,1,1,nil)
		g1:Merge(g2)
		-- 将选中的卡送入玩家额外卡组
		if Duel.SendtoExtraP(g1,nil,REASON_EFFECT)~=0 then
			-- 获取连锁的目标玩家和目标参数
			local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
			-- 让目标玩家抽指定数量的卡
			Duel.Draw(p,d,REASON_EFFECT)
		end
	end
end
