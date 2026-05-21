--極超の竜輝巧
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己若非不能通常召唤的怪兽则不能特殊召唤。
-- ①：从卡组把1只「龙辉巧」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c94187078.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己若非不能通常召唤的怪兽则不能特殊召唤。①：从卡组把1只「龙辉巧」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,94187078+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c94187078.cost)
	e1:SetTarget(c94187078.target)
	e1:SetOperation(c94187078.activate)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于检测玩家在当前回合是否特殊召唤过可以通常召唤的怪兽
	Duel.AddCustomActivityCounter(94187078,ACTIVITY_SPSUMMON,c94187078.counterfilter)
end
-- 过滤函数，筛选出不能通常召唤的怪兽（即如果特殊召唤了可以通常召唤的怪兽，计数器会增加）
function c94187078.counterfilter(c)
	return not c:IsSummonableCard()
end
-- 发动代价处理函数，检查并适用本回合不能特殊召唤可以通常召唤的怪兽的限制
function c94187078.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查本回合玩家是否未曾特殊召唤过可以通常召唤的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(94187078,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己若非不能通常召唤的怪兽则不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	-- 设置不能特殊召唤的限制对象为可以通常召唤的怪兽
	e1:SetTarget(Auxiliary.DrytronSpSummonLimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册该特殊召唤限制效果，持续到回合结束
	Duel.RegisterEffect(e1,tp)
	-- 这张卡发动的回合，自己若非不能通常召唤的怪兽则不能特殊召唤。①：从卡组把1只「龙辉巧」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(97148796)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册龙辉巧特有的特殊召唤限制标记效果（代号97148796），持续到回合结束
	Duel.RegisterEffect(e2,tp)
end
-- 过滤函数，筛选卡组中可以被特殊召唤的「龙辉巧」怪兽
function c94187078.filter(c,e,tp)
	-- 检查卡片是否属于「龙辉巧」系列，且在当前状态下可以被特殊召唤（根据是否为主卡组特召怪兽决定是否忽略苏生限制）
	return c:IsSetCard(0x154) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DrytronSpSummonType(c))
end
-- 效果发动时的目标选择与检测函数
function c94187078.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并在发动前检查卡组中是否存在至少1只满足条件的「龙辉巧」怪兽
		and Duel.IsExistingMatchingCard(c94187078.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表明此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行从卡组特殊召唤「龙辉巧」怪兽并注册结束阶段破坏的效果
function c94187078.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，如果自己场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「龙辉巧」怪兽
	local g=Duel.SelectMatchingCard(tp,c94187078.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 如果成功选择怪兽，则尝试将其以表侧表示特殊召唤（根据是否为主卡组特召怪兽决定是否忽略苏生限制）
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,aux.DrytronSpSummonType(tc),POS_FACEUP) then
		tc:RegisterFlagEffect(94187078,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c94187078.descon)
		e1:SetOperation(c94187078.desop)
		-- 注册全局延迟效果，用于在结束阶段执行破坏操作
		Duel.RegisterEffect(e1,tp)
		-- 如果特殊召唤的是主卡组的「龙辉巧」特殊召唤怪兽，则完成其正规召唤程序
		if aux.DrytronSpSummonType(tc) then
			tc:CompleteProcedure()
		end
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
-- 结束阶段破坏效果的触发条件函数，检查被特殊召唤的怪兽是否仍带有标记
function c94187078.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(94187078)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段破坏效果的执行函数，将目标怪兽破坏
function c94187078.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将目标怪兽破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
