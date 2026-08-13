--破壊剣士の揺籃
-- 效果：
-- 「破坏剑士的摇篮」在1回合只能发动1张。
-- ①：从卡组把「破坏剑士的摇篮」以外的1张「破坏剑」卡和1只「破坏之剑士」怪兽送去墓地才能发动。从自己的额外卡组·墓地选1只「破戒蛮龙-破坏龙」特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。
-- ②：把墓地的这张卡除外才能发动。这个回合，自己场上的「破坏剑」卡不会被战斗·效果破坏。
function c33280639.initial_effect(c)
	-- 「破坏剑士的摇篮」在1回合只能发动1张。①：从卡组把「破坏剑士的摇篮」以外的1张「破坏剑」卡和1只「破坏之剑士」怪兽送去墓地才能发动。从自己的额外卡组·墓地选1只「破戒蛮龙-破坏龙」特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。
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
	-- 设置②效果的发动代价：把墓地中的这张卡除外（aux.bfgcost封装了从墓地除外作为cost的检测与执行）。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c33280639.immop)
	c:RegisterEffect(e2)
end
-- 定义第1个检索过滤条件：从卡组选1张「破坏剑士的摇篮」以外的「破坏剑」系列卡，且可作为代价送去墓地；同时要求卡组中存在另1只满足cfilter2的「破坏之剑士」怪兽，确保两张卡能同时凑齐。
function c33280639.cfilter1(c,tp)
	return c:IsSetCard(0xd6) and not c:IsCode(33280639) and c:IsAbleToGraveAsCost()
		-- 追加判定：卡组中还存在至少1只可作代价的「破坏之剑士」怪兽，用于配合第1张「破坏剑」卡一起作为发动代价。
		and Duel.IsExistingMatchingCard(c33280639.cfilter2,tp,LOCATION_DECK,0,1,c)
end
-- 定义第2个过滤条件：选择卡组中1只「破坏之剑士」系列怪兽，类型为怪兽且可作为代价送去墓地。
function c33280639.cfilter2(c)
	return c:IsSetCard(0xd7) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 代价处理函数：在可以发动时，分别从卡组选择1张「破坏剑」卡和1只「破坏之剑士」怪兽，将它们合并后送入墓地作为发动①的代价。
function c33280639.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段（chk==0）：确认卡组中至少存在一组满足条件的「破坏剑」卡和「破坏之剑士」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c33280639.cfilter1,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 显示选择提示，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张「破坏剑士的摇篮」以外的「破坏剑」系列卡，作为代价的第1部分。
	local g1=Duel.SelectMatchingCard(tp,c33280639.cfilter1,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 再次显示选择提示，提示玩家选择要送去墓地的「破坏之剑士」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只「破坏之剑士」怪兽，排除已选的第1张卡，作为代价的第2部分。
	local g2=Duel.SelectMatchingCard(tp,c33280639.cfilter2,tp,LOCATION_DECK,0,1,1,g1:GetFirst())
	g1:Merge(g2)
	-- 将选出的「破坏剑」卡和「破坏之剑士」怪兽一起送入墓地，完成代价支付。
	Duel.SendtoGrave(g1,REASON_COST)
end
-- 定义特殊召唤对象的过滤条件：必须是「破戒蛮龙-破坏龙」，且能被当前效果特殊召唤；若在墓地则需有可用怪兽区，若在额外卡组则需有可供额外卡组怪兽特殊召唤的空位。
function c33280639.filter(c,e,tp)
	return c:IsCode(11790356) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若候选怪兽在墓地，则要求我方场上当前有空余的怪兽区才能特殊召唤。
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 若候选怪兽在额外卡组，则要求有可让额外卡组怪兽特殊召唤出来的空位（考虑额外怪兽区域等条件）。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 目标函数：在发动时检查墓地·额外卡组是否存在符合条件的「破戒蛮龙-破坏龙」，并设置本效果为特殊召唤1只该怪兽的操作信息。
function c33280639.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检测阶段（chk==0）：确认墓地或额外卡组存在至少1只满足filter的「破戒蛮龙-破坏龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(c33280639.filter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将进行1只怪兽的特殊召唤，候选来源为墓地或额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 效果处理函数：实际选择并特殊召唤「破戒蛮龙-破坏龙」，若成功则给它注册标记以及在下个结束阶段破坏的延迟效果，最后完成特殊召唤。
function c33280639.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地或额外卡组选择1只「破戒蛮龙-破坏龙」（使用NecroValleyFilter以正确应对王家长眠之谷等影响墓地卡的效果）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33280639.filter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功通过SpecialSummonStep进行特殊召唤步骤，则给该怪兽注册本卡标记，并设置在下个结束阶段破坏的延迟效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:RegisterFlagEffect(33280639,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- 这个效果特殊召唤的怪兽在下个回合的结束阶段破坏。②：把墓地的这张卡除外才能发动。这个回合，自己场上的「破坏剑」卡不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCondition(c33280639.descon)
		e1:SetOperation(c33280639.desop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetCountLimit(1)
		-- 记录当前回合数，用于判断“下个回合的结束阶段”——只有回合数发生变化后的结束阶段才满足破坏条件。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetLabelObject(tc)
		-- 将延迟破坏效果注册到场上，使其在结束阶段时点被检测并触发。
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成特殊召唤流程，将之前通过SpecialSummonStep累积的怪兽正式特殊召唤出场。
	Duel.SpecialSummonComplete()
end
-- 破坏效果的发动条件：仅在特殊召唤后的下一个结束阶段，且该怪兽仍带有本效果标记时才允许破坏，避免当回合结束阶段就立即破坏。
function c33280639.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断条件：当前回合数不等于记录的回合数（说明已经进入下个回合），且该怪兽仍拥有本效果标记（表示它仍是由本效果特殊召唤的对象）。
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(33280639)~=0
end
-- 破坏效果的处理函数：取出标记怪兽并将其破坏。
function c33280639.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果破坏该「破戒蛮龙-破坏龙」。
	Duel.Destroy(tc,REASON_EFFECT)
end
-- ②效果的处理：给己方场上的「破坏剑」系列卡附加本回合不会被效果破坏和不会被战斗破坏的持续抗性。
function c33280639.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，自己场上的「破坏剑」卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置不会被效果破坏的保护对象：限定为己方场上所有「破坏剑」系列卡。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd6))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果破坏抗性效果注册到场上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 将战斗破坏抗性效果（e1的克隆）也注册到场上，使「破坏剑」卡本回合也不会被战斗破坏。
	Duel.RegisterEffect(e2,tp)
end
