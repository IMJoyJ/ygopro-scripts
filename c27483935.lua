--古代の機械司令
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从自己的手卡·卡组·场上（表侧表示）把1只「古代的机械巨人」送去墓地才能发动。进行1只「古代的机械」怪兽的召唤。
-- ②：自己把「古代的机械巨人」召唤·特殊召唤的场合才能发动。从自己的手卡·墓地把1只「古代的机械巨人」无视召唤条件特殊召唤。
-- ③：把墓地的这张卡除外才能发动。从手卡把1张「古代的机械」永续陷阱卡在自己场上表侧表示放置。
function c27483935.initial_effect(c)
	-- 记录此卡与「古代的机械巨人」的关联
	aux.AddCodeList(c,83104731)
	-- ①：从自己的手卡·卡组·场上（表侧表示）把1只「古代的机械巨人」送去墓地才能发动。进行1只「古代的机械」怪兽的召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27483935,0))  --"进行召唤"
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,27483935)
	e1:SetCost(c27483935.scost)
	e1:SetTarget(c27483935.stg)
	e1:SetOperation(c27483935.sop)
	c:RegisterEffect(e1)
	-- ②：自己把「古代的机械巨人」召唤·特殊召唤的场合才能发动。从自己的手卡·墓地把1只「古代的机械巨人」无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27483935,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,27483936)
	e2:SetCondition(c27483935.spcon)
	e2:SetTarget(c27483935.sptg)
	e2:SetOperation(c27483935.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外才能发动。从手卡把1张「古代的机械」永续陷阱卡在自己场上表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27483935,2))  --"放置永续陷阱"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,27483937)
	-- 将此卡除外作为费用
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c27483935.tftg)
	e4:SetOperation(c27483935.tfop)
	c:RegisterEffect(e4)
end
-- 检查是否满足送去墓地的条件：拥有「古代的机械巨人」的卡，且手牌或场上存在可召唤的「古代的机械」怪兽
function c27483935.costfilter(c,tp)
	return c:IsCode(83104731) and c:IsAbleToGraveAsCost()
		-- 确保手牌或场上存在可召唤的「古代的机械」怪兽
		and Duel.IsExistingMatchingCard(c27483935.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c)
end
-- 检索满足条件的「古代的机械巨人」卡并将其送去墓地作为费用
function c27483935.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的「古代的机械巨人」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c27483935.costfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「古代的机械巨人」卡
	local g=Duel.SelectMatchingCard(tp,c27483935.costfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置召唤效果的目标信息
function c27483935.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可召唤的「古代的机械」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27483935.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置召唤效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 定义「古代的机械」怪兽的过滤条件
function c27483935.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsSetCard(0x7)
end
-- 选择并进行「古代的机械」怪兽的召唤
function c27483935.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的「古代的机械」怪兽
	local g=Duel.SelectMatchingCard(tp,c27483935.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行召唤操作
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 定义「古代的机械巨人」的过滤条件
function c27483935.cfilter(c)
	return c:IsFaceup() and c:IsCode(83104731)
end
-- 判断是否满足特殊召唤的条件：己方有「古代的机械巨人」被召唤或特殊召唤
function c27483935.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27483935.cfilter,1,nil)
end
-- 定义「古代的机械巨人」的特殊召唤过滤条件
function c27483935.filter1(c,e,tp)
	return c:IsCode(83104731) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置特殊召唤效果的目标信息
function c27483935.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在可特殊召唤的「古代的机械巨人」
		and Duel.IsExistingMatchingCard(c27483935.filter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行特殊召唤操作
function c27483935.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「古代的机械巨人」卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27483935.filter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 定义「古代的机械」永续陷阱卡的过滤条件
function c27483935.pfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP) and c:IsSetCard(0x7)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 设置放置永续陷阱的目标信息
function c27483935.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否存在可放置的「古代的机械」永续陷阱卡
		and Duel.IsExistingMatchingCard(c27483935.pfilter,tp,LOCATION_HAND,0,1,nil,tp) end
end
-- 执行放置永续陷阱的操作
function c27483935.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的「古代的机械」永续陷阱卡
	local tc=Duel.SelectMatchingCard(tp,c27483935.pfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	-- 将选中的卡放置到场上
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
