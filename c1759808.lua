--幻魔の肖像
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。把1只那只怪兽的同名怪兽从自己的卡组·额外卡组特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段回到持有者卡组。这张卡的发动后，直到回合结束时自己不能从卡组·额外卡组把怪兽特殊召唤。
function c1759808.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方场上1只表侧表示怪兽为对象才能发动。把1只那只怪兽的同名怪兽从自己的卡组·额外卡组特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段回到持有者卡组。这张卡的发动后，直到回合结束时自己不能从卡组·额外卡组把怪兽特殊召唤。
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
-- 定义对象筛选函数：检查对方场上是否存在表侧表示怪兽，并且自己的卡组·额外卡组中有该怪兽的同名卡且可以特殊召唤。
function c1759808.cfilter(c,e,tp)
	-- 筛选条件：对象怪兽为表侧表示，且自己的卡组·额外卡组中存在至少1张同名且可特殊召唤的怪兽。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c1759808.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode())
end
-- 定义候选特殊召唤怪兽的筛选函数：要求与对象怪兽同名、可以被特殊召唤，且根据所在位置（卡组或额外卡组）有足够的可用怪兽区。
function c1759808.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 对于在卡组中的候选怪兽，额外确认自己场上有可用的主怪兽区。
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 对于在额外卡组中的候选怪兽，额外确认自己场上有可用的额外怪兽区（或可容纳额外怪兽的格子）。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 定义效果发动时的处理：检查发动合法性，选择对方场上的1只表侧表示怪兽为对象，并设置特殊召唤的操作信息。
function c1759808.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c1759808.cfilter(chkc,e,tp) end
	-- 无卡时点检查：确认场上存在符合条件的对象怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c1759808.cfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的1只表侧表示怪兽作为效果对象（同时与当前连锁建立关联）。
	local g=Duel.SelectTarget(tp,c1759808.cfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将从自己的卡组·额外卡组特殊召唤1只怪兽，用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 定义效果解决时的处理：获取对象怪兽，从卡组·额外卡组特殊召唤同名怪兽，并赋予其下个结束阶段返回卡组的效果；同时给自己附加从卡组·额外卡组不能特殊召唤的自肃。
function c1759808.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 弹出选择提示，让玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的卡组·额外卡组选择1只与对象怪兽同名的怪兽。
		local g=Duel.SelectMatchingCard(tp,c1759808.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetCode())
		local sc=g:GetFirst()
		-- 若选中卡且满足特殊召唤条件，则以表侧表示进行特殊召唤（分步召唤的一步）。
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			sc:RegisterFlagEffect(1759808,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
			-- 这个效果特殊召唤的怪兽在下个回合的结束阶段回到持有者卡组。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			-- 记录当前回合数，作为下个回合结束阶段的判定基准。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetLabelObject(sc)
			e1:SetCondition(c1759808.tdcon)
			e1:SetOperation(c1759808.tdop)
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			-- 将这个返回卡组的延迟效果注册给当前玩家，使其在满足条件时自动触发。
			Duel.RegisterEffect(e1,tp)
		end
		-- 完成特殊召唤的分步处理，正式将怪兽特殊召唤到场上。
		Duel.SpecialSummonComplete()
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不能从卡组·额外卡组把怪兽特殊召唤。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetTarget(c1759808.splimit)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将自肃效果注册给当前玩家，使其在本回合内生效。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 定义返回卡组延迟效果的触发条件：必须已经进入下个回合，且被特殊召唤的怪兽仍留在场上并带有标记。
function c1759808.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 触发条件判定：当前回合数不等于记录回合数，且怪兽仍持有返回卡组的标记。
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(1759808)~=0
end
-- 定义返回卡组延迟效果的处理：将标记怪兽返回持有者卡组。
function c1759808.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将怪兽返回持有者卡组，并洗切卡组。
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 定义自肃的限制目标：只限制从卡组或额外卡组进行的特殊召唤。
function c1759808.splimit(e,c)
	return c:IsLocation(LOCATION_DECK) or c:IsLocation(LOCATION_EXTRA)
end
