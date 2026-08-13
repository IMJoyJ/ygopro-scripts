--磁石の戦士ε
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，从卡组把「磁石战士ε」以外的1只4星以下的「磁石战士」怪兽送去墓地才能发动。这张卡直到结束阶段当作和送去墓地的怪兽同名卡使用。那之后，可以从自己墓地选同名卡不在自己场上存在的1只「磁石战士」怪兽特殊召唤。
function c52566270.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合，从卡组把「磁石战士ε」以外的1只4星以下的「磁石战士」怪兽送去墓地才能发动。这张卡直到结束阶段当作和送去墓地的怪兽同名卡使用。那之后，可以从自己墓地选同名卡不在自己场上存在的1只「磁石战士」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52566270,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,52566270)
	e1:SetCost(c52566270.cost)
	e1:SetOperation(c52566270.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 定义cost筛选条件：从卡组选择1张「磁石战士ε」以外的、4星以下的「磁石战士」怪兽，且可作为代价送去墓地。
function c52566270.costfilter(c)
	return c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsAbleToGraveAsCost() and not c:IsCode(52566270)
end
-- 代价处理：确认可以支付后，从卡组选择1张满足costfilter的「磁石战士」怪兽送去墓地，并将其卡号记录在效果标签中，供后续变更卡名使用。
function c52566270.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 支付代价判定：检查卡组中是否存在至少1张满足costfilter的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c52566270.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家发送选择提示消息，提示内容为‘请选择要送去墓地的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足costfilter的卡作为代价。
	local cg=Duel.SelectMatchingCard(tp,c52566270.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡以‘代价’（REASON_COST）方式送去墓地。
	Duel.SendtoGrave(cg,REASON_COST)
	e:SetLabel(cg:GetFirst():GetCode())
end
-- 定义同名卡检测函数：判断场上是否存在表侧表示且与指定卡卡名相同的怪兽，用于排除特殊召唤同名卡。
function c52566270.cfilter(c,oc)
	return c:IsFaceup() and c:IsCode(oc:GetCode())
end
-- 定义墓地特殊召唤筛选条件：选择1只属于「磁石战士」字段的怪兽（0x2066/0xe9），可被特殊召唤，且自己场上不存在同名卡。
function c52566270.spfilter(c,e,tp)
	return c:IsSetCard(0x2066,0xe9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 排除条件：自己场上不存在与候选墓地怪兽同名的表侧表示怪兽，以满足‘同名卡不在自己场上存在’的要求。
		and not Duel.IsExistingMatchingCard(c52566270.cfilter,tp,LOCATION_ONFIELD,0,1,nil,c)
end
-- 效果处理：先将此卡变为与cost送去墓地的怪兽同名卡直到结束阶段；之后若墓地存在符合条件的「磁石战士」且主要怪兽区有空位，则询问玩家是否特殊召唤，选择后从墓地特殊召唤1只。
function c52566270.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这张卡直到结束阶段当作和送去墓地的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
	-- 检查墓地是否存在满足特殊召唤条件的「磁石战士」怪兽（排除王家长眠之谷影响）。
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c52566270.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己主要怪兽区是否有空余区域，用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否从墓地特殊召唤另一只怪兽。
		and Duel.SelectYesNo(tp,aux.Stringid(52566270,1)) then  --"是否从墓地特殊召唤另一只怪兽？"
		-- 中断当前效果链，使后续的特殊召唤处理与前面的变名处理错开时点（对应‘那之后’）。
		Duel.BreakEffect()
		-- 向玩家发送选择提示消息，提示内容为‘请选择要特殊召唤的卡’。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从墓地选择1只满足特殊召唤条件的「磁石战士」怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c52566270.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选择的怪兽表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
