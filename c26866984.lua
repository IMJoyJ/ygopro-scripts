--トリアス・ヒエラルキア
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，自己·对方的主要阶段，把自己场上最多3只天使族怪兽解放才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。并且，再让为这个效果发动而解放的怪兽数量的以下效果各能适用。
-- ●2只以上：对方场上1张卡破坏。
-- ●3只：自己抽2张。
function c26866984.initial_effect(c)
	-- 创建效果，设置效果描述、分类、类型、代码、适用区域、时点提示、使用次数限制、发动条件、费用、目标、效果处理
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26866984,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,26866984)
	e1:SetCondition(c26866984.spcon)
	e1:SetCost(c26866984.spcost)
	e1:SetTarget(c26866984.sptg)
	e1:SetOperation(c26866984.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：当前阶段为自己的主要阶段1或主要阶段2
function c26866984.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为自己的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤条件：卡片为天使族且为己方控制或表侧表示
function c26866984.cfilter(c,tp)
	return c:IsRace(RACE_FAIRY) and (c:IsControler(tp) or c:IsFaceup())
end
-- 设置发动费用：选择1~3只可解放的天使族怪兽并解放
function c26866984.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家可解放的怪兽组并筛选出天使族怪兽
	local rg=Duel.GetReleaseGroup(tp):Filter(c26866984.cfilter,nil,tp)
	-- 检查是否满足解放条件（1~3只怪兽）
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,1,3,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的怪兽数量
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,1,3,tp)
	-- 使用代替解放次数
	aux.UseExtraReleaseCount(g,tp)
	-- 实际执行解放操作并记录解放数量
	e:SetLabel(Duel.Release(g,REASON_COST))
end
-- 设置效果目标：判断是否可以特殊召唤，并根据解放数量设置抽卡效果
function c26866984.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local ct=e:GetLabel()
	local cat=CATEGORY_SPECIAL_SUMMON
	if ct==3 then
		cat=cat+CATEGORY_DRAW
		-- 设置抽卡操作信息
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	end
	e:SetCategory(cat)
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：特殊召唤自身并设置离开场上的处理方式，再根据解放数量决定是否发动后续效果
function c26866984.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否还在场上并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 特殊召唤的这张卡从场上离开的场合除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
		local ct=e:GetLabel()
		-- 获取对方场上的所有卡
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if (ct>=2 and g:GetCount()>0) or ct==3 then
			-- 当解放数量大于等于2且对方场上存在卡时，询问是否破坏对方场上1张卡
			if ct>=2 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(26866984,1)) then  --"是否选对方场上1张卡破坏？"
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 提示玩家选择要破坏的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				local dg=g:Select(tp,1,1,nil)
				-- 显示被选为对象的卡
				Duel.HintSelection(dg)
				-- 破坏选中的卡
				Duel.Destroy(dg,REASON_EFFECT)
			end
			-- 当解放数量为3且自己可以抽2张卡时，询问是否抽2张卡
			if ct==3 and Duel.IsPlayerCanDraw(tp,2) and Duel.SelectYesNo(tp,aux.Stringid(26866984,2)) then  --"是否从卡组抽2张？"
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 执行抽2张卡的效果
				Duel.Draw(tp,2,REASON_EFFECT)
			end
		end
	end
end
