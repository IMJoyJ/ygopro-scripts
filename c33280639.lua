--破壊剣士の揺籃
-- 效果：
-- 「破坏剑士的摇篮」在1回合只能发动1张。
-- ①：从卡组把「破坏剑士的摇篮」以外的1张「破坏剑」卡和1只「破坏之剑士」怪兽送去墓地才能发动。从自己的额外卡组·墓地选1只「破戒蛮龙-破坏龙」特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。
-- ②：把墓地的这张卡除外才能发动。这个回合，自己场上的「破坏剑」卡不会被战斗·效果破坏。
function c33280639.initial_effect(c)
	-- ①：从卡组把「破坏剑士的摇篮」以外的1张「破坏剑」卡和1只「破坏之剑士」怪兽送去墓地才能发动。从自己的额外卡组·墓地选1只「破戒蛮龙-破坏龙」特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,33280639+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c33280639.cost)
	e1:SetTarget(c33280639.target)
	e1:SetOperation(c33280639.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。这个回合，自己场上的「破坏剑」卡不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	-- 将墓地的这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c33280639.immop)
	c:RegisterEffect(e2)
end
-- 过滤函数：满足「破坏剑」卡的条件且不是「破坏剑士的摇篮」，并且可以送去墓地，同时满足cfilter2条件
function c33280639.cfilter1(c,tp)
	return c:IsSetCard(0xd6) and not c:IsCode(33280639) and c:IsAbleToGraveAsCost()
		-- 检查是否存在满足cfilter2条件的卡
		and Duel.IsExistingMatchingCard(c33280639.cfilter2,tp,LOCATION_DECK,0,1,c)
end
-- 过滤函数：满足「破坏之剑士」怪兽的条件且是怪兽卡，可以送去墓地
function c33280639.cfilter2(c)
	return c:IsSetCard(0xd7) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 检索满足条件的「破坏剑」卡和「破坏之剑士」怪兽，将它们送去墓地作为发动cost
function c33280639.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动cost条件
	if chk==0 then return Duel.IsExistingMatchingCard(c33280639.cfilter1,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足cfilter1条件的卡
	local g1=Duel.SelectMatchingCard(tp,c33280639.cfilter1,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足cfilter2条件的卡
	local g2=Duel.SelectMatchingCard(tp,c33280639.cfilter2,tp,LOCATION_DECK,0,1,1,g1:GetFirst())
	g1:Merge(g2)
	-- 将选中的卡送去墓地作为发动cost
	Duel.SendtoGrave(g1,REASON_COST)
end
-- 过滤函数：满足「破戒蛮龙-破坏龙」的条件且可以特殊召唤
function c33280639.filter(c,e,tp)
	return c:IsCode(11790356) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否满足在墓地且场上存在空位
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 检查是否满足在额外卡组且额外卡组存在召唤空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 检查是否存在满足条件的「破戒蛮龙-破坏龙」
function c33280639.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动target条件
	if chk==0 then return Duel.IsExistingMatchingCard(c33280639.filter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 选择满足条件的「破戒蛮龙-破坏龙」进行特殊召唤，并设置其在下个回合结束时被破坏
function c33280639.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「破戒蛮龙-破坏龙」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33280639.filter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:RegisterFlagEffect(33280639,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- 创建一个在结束阶段时破坏特殊召唤怪兽的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCondition(c33280639.descon)
		e1:SetOperation(c33280639.desop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetCountLimit(1)
		-- 记录当前回合数
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetLabelObject(tc)
		-- 注册该效果
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断是否满足破坏条件
function c33280639.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断是否为下个回合且该怪兽仍存在
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(33280639)~=0
end
-- 执行破坏操作
function c33280639.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将该怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 设置效果使自己场上的「破坏剑」卡不会被战斗·效果破坏
function c33280639.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置效果使自己场上的「破坏剑」卡不会被战斗·效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置效果目标为「破坏剑」卡
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd6))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 注册效果
	Duel.RegisterEffect(e2,tp)
end
