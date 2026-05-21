--焔聖騎士－アストルフォ
-- 效果：
-- 这个卡名的①②的效果在决斗中各能使用1次。
-- ①：从自己的手卡·墓地把1只战士族·炎属性怪兽除外才能发动。这张卡从手卡特殊召唤。那之后，可以把这张卡的等级变成和除外的怪兽相同。
-- ②：把墓地的这张卡除外才能发动。发动后第2次的自己准备阶段，除外的这张卡特殊召唤。那之后，可以从自己墓地的怪兽以及除外的自己怪兽之中选1只战士族·炎属性怪兽特殊召唤。
function c95953557.initial_effect(c)
	-- ①：从自己的手卡·墓地把1只战士族·炎属性怪兽除外才能发动。这张卡从手卡特殊召唤。那之后，可以把这张卡的等级变成和除外的怪兽相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95953557,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,95953557+EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(c95953557.cost)
	e1:SetTarget(c95953557.target)
	e1:SetOperation(c95953557.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。发动后第2次的自己准备阶段，除外的这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95953557,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,95953558+EFFECT_COUNT_CODE_DUEL)
	-- 把墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c95953557.spop)
	c:RegisterEffect(e2)
end
-- 过滤手卡·墓地中可以作为代价除外的战士族·炎属性怪兽
function c95953557.costfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- ①效果的发动代价处理：从手卡·墓地将1只战士族·炎属性怪兽除外，并记录其等级
function c95953557.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·墓地是否存在除这张卡以外的战士族·炎属性怪兽可以除外
	if chk==0 then return Duel.IsExistingMatchingCard(c95953557.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1只手卡·墓地的战士族·炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,c95953557.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,e:GetHandler())
	e:SetLabel(g:GetFirst():GetLevel())
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的发动准备：检查自身是否能特殊召唤以及怪兽区域是否有空位
function c95953557.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：特殊召唤自身，并可以改变自身等级
function c95953557.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local lv=e:GetLabel()
	-- 成功将这张卡特殊召唤
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==1
		-- 检查除外怪兽的等级是否大于0且与自身当前等级不同，并询问玩家是否选择改变等级
		and lv>0 and c:GetLevel()~=lv and Duel.SelectYesNo(tp,aux.Stringid(95953557,2)) then  --"是否改变等级？"
		-- 中断效果处理，使后续的等级改变处理不与特殊召唤同时进行
		Duel.BreakEffect()
		-- 可以把这张卡的等级变成和除外的怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动处理：注册一个在除外状态下、在准备阶段触发的延迟特殊召唤效果，并初始化回合计数器
function c95953557.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 发动后第2次的自己准备阶段，除外的这张卡特殊召唤。那之后，可以从自己墓地的怪兽以及除外的自己怪兽之中选1只战士族·炎属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	-- 检查当前是否已经是自己的准备阶段，以决定延迟效果的重置回合数
	if Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
	else
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	end
	e1:SetCountLimit(1)
	e1:SetCondition(c95953557.spcon2)
	e1:SetOperation(c95953557.spop2)
	c:RegisterEffect(e1)
	c:SetTurnCounter(0)
end
-- 延迟效果的触发条件：必须是自己的回合
function c95953557.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤自己墓地或除外状态下的战士族·炎属性怪兽
function c95953557.spfilter(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 延迟效果的处理：在第2个自己准备阶段特殊召唤自身，并可以追加特殊召唤墓地或除外的1只战士族·炎属性怪兽
function c95953557.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	-- 当回合计数器达到2时，将除外的这张卡特殊召唤
	if ct==2 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己场上是否有可用的怪兽区域以进行追加特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地或除外的怪兽中是否存在可特殊召唤的战士族·炎属性怪兽（受王家长眠之谷影响）
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c95953557.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		-- 询问玩家是否选择追加特殊召唤另一只怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(95953557,3)) then  --"是否特殊召唤另一只怪兽？"
		-- 中断效果处理，使后续的追加特殊召唤不与自身的特殊召唤同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从自己墓地或除外的怪兽中选择1只战士族·炎属性怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c95953557.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
