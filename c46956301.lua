--白闘気砂滑
-- 效果：
-- 水属性调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己的手卡·墓地把1只4星以下的鱼族怪兽守备表示特殊召唤。那之后，可以把那1只同名怪兽从自己墓地特殊召唤。
-- ②：这张卡被对方破坏送去墓地的场合，从自己墓地把1只其他的水属性怪兽除外才能发动。这张卡当作调整使用特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册：为这张卡设置同调召唤手续（水属性调整＋调整以外怪兽1只以上），并注册①的同调召唤成功时特殊召唤鱼族怪兽的效果和②被对方破坏后除外水属性怪兽特殊召唤并当作调整的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：素材要求为水属性调整1只＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),aux.NonTuner(nil),1)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡同调召唤的场合才能发动。从自己的手卡·墓地把1只4星以下的鱼族怪兽守备表示特殊召唤。那之后，可以把那1只同名怪兽从自己墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的场合，从自己墓地把1只其他的水属性怪兽除外才能发动。这张卡当作调整使用特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.treat_itself_tuner=true
-- 发动条件：只有当这张卡以同调召唤方式特殊召唤成功时，①效果才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 特招对象过滤：选择等级4以下、鱼族、且可以被玩家以表侧守备表示特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动时合法性检测：确认自己主怪兽区有空位，且手卡·墓地存在满足特招条件的鱼族怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在满足条件的可特殊召唤鱼族怪兽（不取对象，仅检查存在）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：声明本次效果涉及特殊召唤，来源区域为手卡·墓地，预计处理1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 同名怪兽过滤：用于选取墓地中与第一次特招的怪兽相同卡号且可特殊召唤的怪兽。
function s.spfilter2(c,code,e,tp)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果处理：先守备表示特殊召唤1只4星以下鱼族怪兽；成功后再询问玩家是否将墓地中的同名怪兽表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主怪兽区有空位，若没有则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示：请玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只符合条件的鱼族怪兽，过滤时排除受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 获取墓地中与该怪兽同卡名的可特殊召唤怪兽群（同样排除王家长眠之谷影响）。
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,nil,g:GetFirst():GetCode(),e,tp)
		-- 判断是否存在同名怪兽且主怪兽区有空位，以决定是否继续第二次特殊召唤。
		if g2:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问玩家是否把该同名怪兽也特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再把同名怪兽特殊召唤？"
			-- 中断当前效果处理，使后续特殊召唤作为独立处理，避免错过时点。
			Duel.BreakEffect()
			-- 显示选择提示：请玩家选择要特殊召唤的同名怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g2:Select(tp,1,1,nil)
			-- 将选中的同名怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果触发条件：这张卡被对方玩家以战斗或效果破坏并送去墓地。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 代价过滤：从墓地选择1只水属性怪兽作为除外代价（cost）。
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ②效果代价：从墓地除外1只水属性怪兽（不能选自身）作为发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检测：墓地是否存在可除外的水属性怪兽（排除自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 显示选择提示：请玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张墓地中的水属性怪兽（排除这张卡自身）作为代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选择的卡表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标检测：确认主怪兽区有空位且这张卡可以被特殊召唤，并设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将特殊召唤这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将这张卡特殊召唤，并赋予其‘当作调整使用’的效果，最后完成特殊召唤处理。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联后，以表侧表示进行特殊召唤步骤（不检查召唤条件与苏生限制）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这张卡当作调整使用特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	-- 结束特殊召唤步骤，正式完成特殊召唤的结算。
	Duel.SpecialSummonComplete()
end
