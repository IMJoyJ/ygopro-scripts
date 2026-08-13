--ドレミコード・エレガンス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从卡组把1只「七音服」灵摆怪兽在自己的灵摆区域放置。
-- ●从手卡把1只「七音服」灵摆怪兽表侧加入额外卡组。那之后，从卡组把灵摆刻度是奇数和偶数的「七音服」灵摆怪兽各1只在自己的灵摆区域放置。
-- ●从自己的灵摆区域把灵摆刻度是奇数和偶数的卡各1张表侧加入额外卡组，自己抽2张。
function c27870337.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●从卡组把1只「七音服」灵摆怪兽在自己的灵摆区域放置。●从手卡把1只「七音服」灵摆怪兽表侧加入额外卡组。那之后，从卡组把灵摆刻度是奇数和偶数的「七音服」灵摆怪兽各1只在自己的灵摆区域放置。●从自己的灵摆区域把灵摆刻度是奇数和偶数的卡各1张表侧加入额外卡组，自己抽2张。
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
-- 检查是否满足第三个选项的发动条件：自己的灵摆区域存在奇数刻度和偶数刻度的卡各至少1张，且自己可以抽2张卡。
function c27870337.sel3(tp)
	-- 检查自己的灵摆区域是否存在至少1张灵摆刻度为奇数的卡（用于第三效果“从灵摆区域把奇数刻度卡加入额外卡组”的发动条件）。
	return Duel.IsExistingMatchingCard(c27870337.toexfilter1,tp,LOCATION_PZONE,0,1,nil)
		-- 检查自己的灵摆区域是否存在至少1张灵摆刻度为偶数的卡（用于第三效果“从灵摆区域把偶数刻度卡加入额外卡组”的发动条件）。
		and Duel.IsExistingMatchingCard(c27870337.toexfilter2,tp,LOCATION_PZONE,0,1,nil)
		-- 检查自己是否允许通过效果抽2张卡（第三效果抽卡部分的前提）。
		and Duel.IsPlayerCanDraw(tp,2)
end
-- 计算本卡发动时允许放置的区域：若第三选项可用或两个灵摆区域均空则允许全部区域；否则若仅一侧灵摆区域被占用，则将该侧灵摆区域从允许放置区域中排除，以避免占用后续效果所需的灵摆区域。
function c27870337.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	local b3=c27870337.sel3(tp)
	if b3 then return zone end
	-- 检查自己的左方灵摆区域是否为空。
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	-- 检查自己的右方灵摆区域是否为空。
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	if not b or p0 and p1 then return zone end
	if p0 then zone=zone-0x1 end
	if p1 then zone=zone-0x10 end
	return zone
end
-- 判断一张卡是否为「七音服」灵摆怪兽且未被禁止，用于从卡组检索/放置灵摆怪兽的筛选条件。
function c27870337.pendfilter(c)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 判断一张卡是否为可放置的「七音服」灵摆怪兽，且其当前灵摆刻度为奇数（用于从卡组选择奇数刻度怪兽）。
function c27870337.pendfilter1(c)
	return c27870337.pendfilter(c) and c:GetCurrentScale()%2~=0
end
-- 判断一张卡是否为可放置的「七音服」灵摆怪兽，且其当前灵摆刻度为偶数（用于从卡组选择偶数刻度怪兽）。
function c27870337.pendfilter2(c)
	return c27870337.pendfilter(c) and c:GetCurrentScale()%2==0
end
-- 判断一张卡是否为「七音服」灵摆怪兽，用于从手牌表侧加入额外卡组的筛选条件。
function c27870337.toexfilter(c)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM)
end
-- 判断一张卡的当前灵摆刻度是否为奇数（用于从自己的灵摆区域选择要加入额外卡组的奇数刻度卡）。
function c27870337.toexfilter1(c)
	return c:GetCurrentScale()%2~=0
end
-- 判断一张卡的当前灵摆刻度是否为偶数（用于从自己的灵摆区域选择要加入额外卡组的偶数刻度卡）。
function c27870337.toexfilter2(c)
	return c:GetCurrentScale()%2==0
end
-- 发动时的目标处理：检查三个可选分支各自是否满足条件，让玩家选择要使用的分支，将选择记录在效果标签中，并设置对应的效果分类和抽卡操作信息。
function c27870337.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的「七音服」灵摆怪兽（用于第一效果“从卡组放置1只”）。
	local b1=Duel.IsExistingMatchingCard(c27870337.pendfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查自己的灵摆区域是否至少有一个空格，保证第一效果可以放置灵摆怪兽。
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
	-- 检查手牌中是否存在至少1只「七音服」灵摆怪兽（用于第二效果中先表侧加入额外卡组）。
	local b2=Duel.IsExistingMatchingCard(c27870337.toexfilter,tp,LOCATION_HAND,0,1,nil)
		-- 检查卡组中是否存在至少1只灵摆刻度为奇数的「七音服」灵摆怪兽（用于第二效果中从卡组放置）。
		and Duel.IsExistingMatchingCard(c27870337.pendfilter1,tp,LOCATION_DECK,0,1,nil)
		-- 检查卡组中是否存在至少1只灵摆刻度为偶数的「七音服」灵摆怪兽（用于第二效果中从卡组放置）。
		and Duel.IsExistingMatchingCard(c27870337.pendfilter2,tp,LOCATION_DECK,0,1,nil)
		-- 检查自己的两个灵摆区域均为空，确保第二效果后续能放置两只灵摆怪兽。
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
	-- 让玩家从当前可用的选项中选择要发动的效果，并转换为内部编号。
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(0)
	elseif sel==1 then
		e:SetCategory(0)
	elseif sel==2 then
		e:SetCategory(CATEGORY_DRAW)
		-- 将本次效果的抽卡对象玩家设置为当前发动者（用于第三效果的抽卡）。
		Duel.SetTargetPlayer(tp)
		-- 将本次效果的抽卡数量参数设置为2（用于第三效果抽2张卡）。
		Duel.SetTargetParam(2)
		-- 设置连锁处理信息，声明本效果将进行抽卡操作：对象玩家为tp，预计抽2张卡。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	end
end
-- 效果处理时根据发动时选择的分支执行：1）从卡组选1只「七音服」灵摆怪兽放置到自己的灵摆区域；2）从手牌选1只表侧加入额外卡组，成功后再从卡组选奇数和偶数刻度各1只放置；3）从自己的灵摆区域选奇数和偶数刻度卡各1张表侧加入额外卡组，然后抽2张。
function c27870337.activate(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then
		-- 如果自己的两个灵摆区域都不是空位，则无法执行放置，直接终止该分支的处理。
		if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
		-- 向玩家显示“请选择要放置到场上的卡”的选择提示，用于从卡组选择要放置的灵摆怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从卡组选择1张满足条件的「七音服」灵摆怪兽，作为第一效果要放置到场上的卡。
		local sg=Duel.SelectMatchingCard(tp,c27870337.pendfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=sg:GetFirst()
		if tc then
			-- 将选择的卡从卡组以表侧表示放置到自己的灵摆区域。
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	elseif sel==1 then
		-- 向玩家显示“请选择要加入额外卡组的卡”的选择提示，用于选择要从手牌加入额外卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(27870337,3))  --"请选择要加入额外卡组的卡"
		-- 从手牌选择1只「七音服」灵摆怪兽，用于第二效果中将其表侧加入额外卡组。
		local g=Duel.SelectMatchingCard(tp,c27870337.toexfilter,tp,LOCATION_HAND,0,1,1,nil)
		-- 若手牌选出的卡存在、且表侧加入额外卡组成功（实际送入额外卡组的数量不为0），则继续后续处理。
		if g:GetCount()>0 and Duel.SendtoExtraP(g,nil,REASON_EFFECT)~=0
			-- 并确认自己的两个灵摆区域均为空，满足之后从卡组放置两只灵摆怪兽的条件。
			and Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1) then
			-- 获取卡组中所有灵摆刻度为奇数的「七音服」灵摆怪兽，用于第二效果中选择1只放置。
			local g1=Duel.GetMatchingGroup(c27870337.pendfilter1,tp,LOCATION_DECK,0,nil)
			-- 获取卡组中所有灵摆刻度为偶数的「七音服」灵摆怪兽，用于第二效果中选择1只放置。
			local g2=Duel.GetMatchingGroup(c27870337.pendfilter2,tp,LOCATION_DECK,0,nil)
			if g1:GetCount()>0 and g2:GetCount()>0 then
				-- 中断当前效果，使“从手牌加入额外卡组”与“从卡组放置灵摆怪兽”视为不同时处理，避免错过时点。
				Duel.BreakEffect()
				-- 提示玩家从奇数刻度灵摆怪兽中选择要放置到场上的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
				local sg1=g1:Select(tp,1,1,nil)
				-- 提示玩家从偶数刻度灵摆怪兽中选择要放置到场上的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
				local sg2=g2:Select(tp,1,1,nil)
				sg1:Merge(sg2)
				local tc=sg1:GetFirst()
				while tc do
					-- 将选出的灵摆怪兽依次以表侧表示放置到自己的灵摆区域。
					Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
					tc=sg1:GetNext()
				end
			end
		end
	elseif sel==2 then
		-- 提示玩家从自己的灵摆区域选择要加入额外卡组的奇数刻度卡。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(27870337,3))  --"请选择要加入额外卡组的卡"
		-- 从自己的灵摆区域选择1张灵摆刻度为奇数的卡，作为第三效果中要加入额外卡组的卡。
		local g1=Duel.SelectMatchingCard(tp,c27870337.toexfilter1,tp,LOCATION_PZONE,0,1,1,nil)
		-- 提示玩家从自己的灵摆区域选择要加入额外卡组的偶数刻度卡。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(27870337,3))  --"请选择要加入额外卡组的卡"
		-- 从自己的灵摆区域选择1张灵摆刻度为偶数的卡，作为第三效果中要加入额外卡组的卡。
		local g2=Duel.SelectMatchingCard(tp,c27870337.toexfilter2,tp,LOCATION_PZONE,0,1,1,nil)
		g1:Merge(g2)
		-- 如果选出的奇偶两张卡均成功表侧加入额外卡组（实际操作数不为0），则执行抽卡。
		if Duel.SendtoExtraP(g1,nil,REASON_EFFECT)~=0 then
			-- 读取发动时设置的抽卡对象玩家和抽卡数量参数。
			local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
			-- 让对应玩家根据参数抽2张卡，完成第三效果的抽卡部分。
			Duel.Draw(p,d,REASON_EFFECT)
		end
	end
end
