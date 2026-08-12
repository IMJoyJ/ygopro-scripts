--磁石の戦士ε
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，从卡组把「磁石战士ε」以外的1只4星以下的「磁石战士」怪兽送去墓地才能发动。这张卡直到结束阶段当作和送去墓地的怪兽同名卡使用。那之后，可以从自己墓地选同名卡不在自己场上存在的1只「磁石战士」怪兽特殊召唤。
function c52566270.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，从卡组把「磁石战士ε」以外的1只4星以下的「磁石战士」怪兽送去墓地才能发动。这张卡直到结束阶段当作和送去墓地的怪兽同名卡使用。那之后，可以从自己墓地选同名卡不在自己场上存在的1只「磁石战士」怪兽特殊召唤。
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
-- 过滤函数，用于筛选满足条件的卡：属于磁石战士卡组、等级4以下、可以作为cost送去墓地且不是磁石战士ε本身
function c52566270.costfilter(c)
	return c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsAbleToGraveAsCost() and not c:IsCode(52566270)
end
-- 效果处理函数，检查是否满足发动条件并选择一张符合条件的卡送去墓地，同时将该卡的卡号记录到效果标签中
function c52566270.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：在自己卡组中是否存在至少1张满足costfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c52566270.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组中选择一张满足costfilter条件的卡
	local cg=Duel.SelectMatchingCard(tp,c52566270.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地作为效果的代价
	Duel.SendtoGrave(cg,REASON_COST)
	e:SetLabel(cg:GetFirst():GetCode())
end
-- 过滤函数，用于判断场上是否存在与指定卡同名且正面表示的怪兽
function c52566270.cfilter(c,oc)
	return c:IsFaceup() and c:IsCode(oc:GetCode())
end
-- 过滤函数，用于筛选可以特殊召唤的磁石战士怪兽：属于磁石战士卡组、可以特殊召唤、且场上不存在同名怪兽
function c52566270.spfilter(c,e,tp)
	return c:IsSetCard(0x2066,0xe9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否已存在同名怪兽，若存在则不能再次特殊召唤该同名怪兽
		and not Duel.IsExistingMatchingCard(c52566270.cfilter,tp,LOCATION_ONFIELD,0,1,nil,c)
end
-- 效果处理函数，将自身变为与送去墓地的怪兽同名卡，并询问是否从墓地特殊召唤一只同名怪兽
function c52566270.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 创建一个使自身卡名改变的效果，使其在结束阶段前变为与送去墓地的怪兽同名
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
	-- 检查自己墓地中是否存在满足spfilter条件的怪兽
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c52566270.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己场上是否有足够的位置进行特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否要从墓地特殊召唤一只怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(52566270,1)) then  --"是否从墓地特殊召唤另一只怪兽？"
		-- 中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地中选择一张满足spfilter条件的卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c52566270.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选中的卡以特殊召唤方式加入场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
