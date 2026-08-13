--双天の調伏
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「双天」怪兽和对方场上1张卡为对象才能发动。那些卡破坏。这个效果把自己场上的「双天」融合怪兽破坏的场合，可以再从以下效果选1个适用。
-- ●自己从卡组抽1张。
-- ●从对方墓地选1张卡除外。
function c49158617.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「双天」怪兽和对方场上1张卡为对象才能发动。那些卡破坏。这个效果把自己场上的「双天」融合怪兽破坏的场合，可以再从以下效果选1个适用。●自己从卡组抽1张。●从对方墓地选1张卡除外。
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
-- 过滤条件：检查卡是否为表侧表示且属于「双天」系列（0x14f），用于选择自己场上的「双天」怪兽。
function c49158617.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14f)
end
-- 过滤条件：检查被破坏的卡是否曾为我方场上表侧表示的「双天」融合怪兽（以离场前信息判定），用于触发追加效果。
function c49158617.ffilter(c,tp)
	return c:IsPreviousSetCard(0x14f) and c:IsPreviousControler(tp) and c:GetPreviousTypeOnField()&TYPE_FUSION~=0
		and c:IsPreviousPosition(POS_FACEUP)
end
-- target函数开头：进行对象合法性检查和发动条件检查；chkc非空时直接返回false（不处理对象确认），chk==0时确认场上存在合法对象。
function c49158617.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：确认自己主要怪兽区存在至少1张表侧表示且属于「双天」系列、能成为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c49158617.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 发动条件检查：确认对方场上存在至少1张能成为效果对象的卡。
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示“请选择要破坏的卡”的提示，作为第一张对象的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只满足cfilter的「双天」怪兽作为对象，并登记为连锁对象。
	local g1=Duel.SelectTarget(tp,c49158617.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向玩家显示“请选择要破坏的卡”的提示，作为第二张对象的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张任意卡作为对象，并登记为连锁对象。
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：本次连锁将破坏两张对象卡，用于连锁判定（如星尘龙）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	-- 设置操作信息：本次连锁可能进行除外操作，对象暂不固定，预定从对方墓地除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
-- activate函数整体效果处理：取得连锁对象中仍与效果相关的卡并破坏；若实际破坏了我方场上表侧表示存在的「双天」融合怪兽，则让玩家选择追加“抽1张”或“从对方墓地除外1张”，否则仅执行破坏。
function c49158617.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁登记的对象卡组（发动时选择的两张对象）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将仍与效果相关的对象卡破坏，原因标记为效果。
		Duel.Destroy(tg,REASON_EFFECT)
		-- 获取刚才破坏操作实际被破坏的卡片组，用于判断是否破坏了「双天」融合怪兽。
		local og=Duel.GetOperatedGroup()
		if og:IsExists(c49158617.ffilter,1,nil,tp) then
			-- 检查发动者是否可以抽1张卡，用于判定“从卡组抽1张”分支是否可选。
			local b1=Duel.IsPlayerCanDraw(tp,1)
			-- 检查对方墓地是否存在至少1张可除外的卡，用于判定“从对方墓地除外1张”分支是否可选。
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
			-- 向玩家显示“请选择一个选项”的提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPTION)  --"请选择一个选项"
			-- 让玩家从可选项（抽卡/除外/什么都不做）中选择一个，返回选项序号。
			local op=Duel.SelectOption(tp,table.unpack(ops))
			local sel=opval[op]
			if sel==1 then
				-- 中断当前效果处理，使后续抽卡另开时点处理，避免错过时点。
				Duel.BreakEffect()
				-- 执行追加效果：发动者从卡组抽1张卡。
				Duel.Draw(tp,1,REASON_EFFECT)
			elseif sel==2 then
				-- 中断当前效果处理，使后续除外另开时点处理，避免错过时点。
				Duel.BreakEffect()
				-- 向玩家显示“请选择要除外的卡”的提示。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
				-- 从对方墓地选择1张可除外且不受“王家长眠之谷”效果影响的卡。
				local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,1,nil)
				if #g>0 then
					-- 将选择的卡以表侧表示除外，原因标记为效果。
					Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
				end
			end
		end
	end
end
