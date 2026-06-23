--双天の調伏
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「双天」怪兽和对方场上1张卡为对象才能发动。那些卡破坏。这个效果把自己场上的「双天」融合怪兽破坏的场合，可以再从以下效果选1个适用。
-- ●自己从卡组抽1张。
-- ●从对方墓地选1张卡除外。
function c49158617.initial_effect(c)
	-- ①：以自己场上1只「双天」怪兽和对方场上1张卡为对象才能发动。那些卡破坏。这个效果把自己场上的「双天」融合怪兽破坏的场合，可以再从以下效果选1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,49158617+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c49158617.target)
	e1:SetOperation(c49158617.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为正面表示的「双天」怪兽
function c49158617.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14f)
end
-- 过滤函数，用于判断是否为之前在自己场上正面表示的「双天」融合怪兽
function c49158617.ffilter(c,tp)
	return c:IsPreviousSetCard(0x14f) and c:IsPreviousControler(tp) and c:GetPreviousTypeOnField()&TYPE_FUSION~=0
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果发动时的处理，检查是否满足选择对象的条件
function c49158617.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只正面表示的「双天」怪兽
	if chk==0 then return Duel.IsExistingTarget(c49158617.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1张卡
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只正面表示的「双天」怪兽作为对象
	local g1=Duel.SelectTarget(tp,c49158617.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为对象
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息，指定将要破坏的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	-- 设置操作信息，指定将要除外的对方墓地中的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
-- 效果发动时处理函数，获取连锁中被选择的对象卡片组
function c49158617.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡片组进行破坏处理
		Duel.Destroy(tg,REASON_EFFECT)
		-- 获取实际被操作的卡片组
		local og=Duel.GetOperatedGroup()
		if og:IsExists(c49158617.ffilter,1,nil,tp) then
			-- 检查玩家是否可以抽1张卡
			local b1=Duel.IsPlayerCanDraw(tp,1)
			-- 检查对方墓地是否存在可除外的卡
			local b2=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
			local off=1
			local ops={}
			local opval={}
			if b1 then
				ops[off]=aux.Stringid(49158617,0)  --"从卡组抽1张"
				opval[off-1]=1
				off=off+1
			end
			if b2 then
				ops[off]=aux.Stringid(49158617,1)  --"选墓地1张卡除外"
				opval[off-1]=2
				off=off+1
			end
			ops[off]=aux.Stringid(49158617,2)  --"什么都不做"
			opval[off-1]=3
			-- 提示玩家选择选项
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPTION)  --"请选择一个选项"
			-- 让玩家从选项中选择一个
			local op=Duel.SelectOption(tp,table.unpack(ops))
			local sel=opval[op]
			if sel==1 then
				-- 中断当前效果，使后续处理视为不同时处理
				Duel.BreakEffect()
				-- 让玩家从卡组抽1张卡
				Duel.Draw(tp,1,REASON_EFFECT)
			elseif sel==2 then
				-- 中断当前效果，使后续处理视为不同时处理
				Duel.BreakEffect()
				-- 提示玩家选择要除外的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
				-- 从对方墓地中选择1张可除外的卡
				local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,1,nil)
				if #g>0 then
					-- 将选中的卡除外
					Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
				end
			end
		end
	end
end
