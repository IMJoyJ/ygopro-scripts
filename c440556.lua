--バハムート・シャーク
-- 效果：
-- 水属性4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从额外卡组把1只3阶以下的水属性超量怪兽特殊召唤。这个效果的发动后，直到回合结束时这张卡不能攻击。
function c440556.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，要求使用满足水属性条件的4星怪兽作为素材，叠放数量为2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从额外卡组把1只3阶以下的水属性超量怪兽特殊召唤。这个效果的发动后，直到回合结束时这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(440556,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c440556.spcost)
	e1:SetTarget(c440556.sptg)
	e1:SetOperation(c440556.spop)
	c:RegisterEffect(e1)
end
-- 支付效果代价，移除自身1个超量素材作为代价
function c440556.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于筛选满足条件的额外卡组怪兽：等级不超过3阶、水属性、可以特殊召唤且场上存在召唤位置
function c440556.filter(c,e,tp)
	return c:IsRankBelow(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查目标怪兽是否满足特殊召唤的场地条件
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置连锁处理信息，表示将要从额外卡组特殊召唤1只怪兽
function c440556.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即在额外卡组中存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c440556.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁处理信息，表示将要从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动时的处理流程：提示选择怪兽并进行特殊召唤，随后为自身添加不能攻击的效果
function c440556.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c440556.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时这张卡不能攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
