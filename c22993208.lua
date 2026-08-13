--炎王の急襲
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：只有对方场上才有怪兽存在的场合才能发动。从卡组把1只兽族·兽战士族·鸟兽族的炎属性怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
function c22993208.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：只有对方场上才有怪兽存在的场合才能发动。从卡组把1只兽族·兽战士族·鸟兽族的炎属性怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22993208+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c22993208.condition)
	e1:SetTarget(c22993208.target)
	e1:SetOperation(c22993208.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：只有对方场上才有怪兽存在的场合才能发动，即对方怪兽区有怪兽且自己怪兽区没有怪兽。
function c22993208.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方怪兽区是否存在怪兽，数量需大于0。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己怪兽区是否存在怪兽，数量需为0（自己场上没有怪兽）。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 筛选可特殊召唤的怪兽：须为炎属性，且种族属于兽族、兽战士族或鸟兽族，同时满足特殊召唤条件。
function c22993208.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时进行合法性检查：自己主要怪兽区有空位，且卡组中存在符合条件的（炎属性/指定种族/可特殊召唤）怪兽。
function c22993208.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动判定阶段（chk==0）确认自己主要怪兽区是否有空余区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中存在至少1张满足spfilter过滤条件的候选怪兽。
		and Duel.IsExistingMatchingCard(c22993208.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次效果的操作信息登记为从卡组特殊召唤1只怪兽，供规则/时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的炎属性兽族/兽战士族/鸟兽族怪兽特殊召唤，并对其附加‘效果无效化’和‘结束阶段破坏’的处理。
function c22993208.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区有空位，若没有则直接终止本次效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选出1张满足spfilter条件的怪兽卡作为特殊召唤对象（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c22993208.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	-- 将选中的怪兽以表侧表示特殊召唤到自己场上（作为特殊召唤连续处理的一步，并检查召唤条件/苏生限制）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc:RegisterFlagEffect(22993208,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 结束阶段破坏。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetLabelObject(tc)
		e3:SetCondition(c22993208.descon)
		-- 设置结束阶段破坏的操作函数，使标记的怪兽在结束阶段被效果破坏。
		e3:SetOperation(aux.EPDestroyOperation)
		-- 将该结束阶段破坏的延迟效果注册到当前玩家，确保该回合结束阶段时执行。
		Duel.RegisterEffect(e3,tp)
	end
	-- 完成所有特殊召唤步骤，结束本次特殊召唤处理。
	Duel.SpecialSummonComplete()
end
-- 结束阶段破坏效果的发动条件：若被特殊召唤的怪兽仍带有标记（未离场/未被重置），则执行破坏；否则重置延迟效果并取消破坏。
function c22993208.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(22993208)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
