--王者の鼓動
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●对方战斗阶段才能发动。对方回复1000基本分。那之后，战斗阶段结束。
-- ●对方场上的卡数量比自己场上的卡多，对方把怪兽的效果发动时才能发动。从自己的额外卡组·墓地把1只「红莲魔龙」或「琰魔龙 红莲魔」特殊召唤，那个发动的效果无效并破坏。
local s,id,o=GetID()
-- 创建卡的效果，注册发动条件和处理函数
function s.initial_effect(c)
	-- 记录该卡与「红莲魔龙」和「琰魔龙 红莲魔」的关联
	aux.AddCodeList(c,39765958,70902743)
	-- 设置效果描述为发动，分类为特殊召唤+回复+无效+破坏，类型为发动效果，触发时机为自由连锁，限制每回合只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER+CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_CHAIN_END)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤过滤函数，检查是否为指定卡名且可特殊召唤，且满足场上怪兽数量或额外卡组召唤条件
function s.spfilter(c,e,tp)
	return c:IsCode(39765958,70902743) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡片是否在墓地且场上怪兽区有空位
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 检查卡片是否在额外卡组且有足够召唤空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 设置效果目标处理函数，判断是否满足两个发动条件并选择发动选项
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否为对方的战斗阶段
	local b1=Duel.GetTurnPlayer()~=tp and Duel.IsBattlePhase()
	-- 获取当前连锁序号
	local ch=Duel.GetCurrentChain()
	local b2=false
	local og=Group.CreateGroup()
	local tsp=-1
	local tse=nil
	if e:GetHandler():IsStatus(STATUS_CHAINING) then ch=ch-1 end
	if ch>0 then
		-- 获取当前连锁的触发玩家和效果
		tsp,tse=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
		og:AddCard(tse:GetHandler())
		-- 判断连锁是否为对方怪兽发动且效果可无效
		if tsp==1-tp and tse:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev) then
			-- 判断对方场上的卡数量是否多于己方
			b2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
				-- 判断己方墓地或额外卡组是否存在符合条件的怪兽
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp)
		end
	end
	if chk==0 then return b1 or b2 end
	-- 让玩家选择发动选项
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"战斗阶段结束"
		{b2,aux.Stringid(id,2),2})  --"特殊召唤"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_RECOVER)
		-- 设置操作信息为对方回复1000基本分
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_DESTROY)
		-- 设置操作信息为从墓地或额外卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
		-- 设置操作信息为使效果无效
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,og,1,0,0)
		if tse and tse:GetHandler():IsDestructable() and tse:GetHandler():IsRelateToEffect(tse) then
			-- 设置操作信息为破坏发动的效果卡
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,og,1,0,0)
		end
	end
end
-- 设置效果发动处理函数，根据选择的选项执行不同效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 使对方回复1000基本分
		if Duel.Recover(1-tp,1000,REASON_EFFECT)>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 跳过对方的战斗阶段
			Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		end
	else
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
		-- 执行特殊召唤并判断是否成功
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 获取当前连锁序号
			local ch=Duel.GetCurrentChain()
			-- 获取上一个连锁的效果
			local tse=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT)
			-- 判断是否能无效该效果且效果卡存在
			if Duel.NegateEffect(ch-1) and tse:GetHandler():IsRelateToEffect(tse) then
				-- 破坏该效果卡
				Duel.Destroy(tse:GetHandler(),REASON_EFFECT)
			end
		end
	end
end
