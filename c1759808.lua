--幻魔の肖像
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。把1只那只怪兽的同名怪兽从自己的卡组·额外卡组特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段回到持有者卡组。这张卡的发动后，直到回合结束时自己不能从卡组·额外卡组把怪兽特殊召唤。
function c1759808.initial_effect(c)
	-- 创建效果，设置为魔陷发动，自由时点，取对象效果，发动次数限制为1次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,1759808+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c1759808.target)
	e1:SetOperation(c1759808.activate)
	c:RegisterEffect(e1)
end
-- 检查对方场上是否存在表侧表示的怪兽，并且自己卡组或额外卡组存在同名怪兽可以特殊召唤
function c1759808.cfilter(c,e,tp)
	-- 检查对方场上是否存在表侧表示的怪兽，并且自己卡组或额外卡组存在同名怪兽可以特殊召唤
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c1759808.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode())
end
-- 过滤函数，用于筛选可以特殊召唤的同名怪兽，需满足位置和召唤条件
function c1759808.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若怪兽在卡组中，则检查是否有足够的怪兽区
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若怪兽在额外卡组中，则检查是否有足够的额外召唤区域
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 设置效果目标，选择对方场上表侧表示的怪兽
function c1759808.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c1759808.cfilter(chkc,e,tp) end
	-- 判断是否满足发动条件，即对方场上存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c1759808.cfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c1759808.cfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理函数，执行特殊召唤和后续处理
function c1759808.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组或额外卡组选择同名怪兽进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,c1759808.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetCode())
		local sc=g:GetFirst()
		-- 执行特殊召唤步骤，若成功则注册返回效果
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			sc:RegisterFlagEffect(1759808,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
			-- 创建一个在结束阶段触发的效果，用于将特殊召唤的怪兽送回卡组
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			-- 记录当前回合数，用于判断是否是下个回合
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetLabelObject(sc)
			e1:SetCondition(c1759808.tdcon)
			e1:SetOperation(c1759808.tdop)
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			-- 将该效果注册到场上
			Duel.RegisterEffect(e1,tp)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 创建一个禁止自己从卡组或额外卡组特殊召唤怪兽的效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetTarget(c1759808.splimit)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将该效果注册到场上
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断是否满足将怪兽送回卡组的条件
function c1759808.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断是否是下个回合且怪兽仍具有标记效果
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(1759808)~=0
end
-- 将怪兽送回卡组
function c1759808.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将怪兽送回卡组并洗牌
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 限制效果，禁止从卡组或额外卡组特殊召唤怪兽
function c1759808.splimit(e,c)
	return c:IsLocation(LOCATION_DECK) or c:IsLocation(LOCATION_EXTRA)
end
