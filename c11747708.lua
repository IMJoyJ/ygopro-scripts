--スポーア
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：这张卡在墓地存在的场合，从自己墓地把这张卡以外的1只植物族怪兽除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的等级上升除外的怪兽的等级数值。
function c11747708.initial_effect(c)
	-- 这个卡名的效果在决斗中只能使用1次。①：这张卡在墓地存在的场合，从自己墓地把这张卡以外的1只植物族怪兽除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的等级上升除外的怪兽的等级数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11747708,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,11747708+EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(c11747708.cost)
	e1:SetTarget(c11747708.target)
	e1:SetOperation(c11747708.operation)
	c:RegisterEffect(e1)
end
-- 从自己墓地筛选可作为发动代价除外的植物族怪兽：必须是植物族、等级大于0，且允许作为代价除外（实际选择时会通过额外参数除外“此卡”自身）。
function c11747708.costfilter(c)
	return c:IsRace(RACE_PLANT) and c:GetLevel()>0 and c:IsAbleToRemoveAsCost()
end
-- 支付代价的处理：先检查是否存在符合条件的植物族怪兽，然后提示玩家选择1张（不能选此卡自身），将其表侧表示除外，并把被除外的怪兽的等级记录到效果Label，用于后续提升等级。
function c11747708.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己墓地是否存在“此卡以外”的1只植物族怪兽可以作为代价除外，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c11747708.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家显示“请选择要除外的卡”的选择提示，请求选择将从墓地除外的植物族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张符合条件的植物族怪兽作为发动代价，选择时自动排除此卡自身。
	local g=Duel.SelectMatchingCard(tp,c11747708.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选择的那张植物族怪兽以表侧表示除外，作为效果的发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- 效果发动时的目标检查：确认自己主要怪兽区有空位，且墓地中的此卡能够被特殊召唤；只有满足这些条件时效果才可发动。
function c11747708.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件之一：确认自己场上存在可用的主要怪兽区位置，用于后续特殊召唤此卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向连锁操作信息登记本次效果包含“特殊召唤”分类，对象为此卡，数量为1，供其他卡片（如星尘龙等）进行时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：先确认此卡仍与效果关联；随后将其自身以表侧表示特殊召唤；若特殊召唤成功，则给此卡附加一个等级提升效果，使其等级上升之前除外怪兽的等级数值，并设置离场/无效等条件下的重置。
function c11747708.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 实际将孢子以表侧表示特殊召唤到自己场上；若特殊召唤成功（返回1），才继续设置等级提升效果。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==1 then
		-- 这个效果特殊召唤的这张卡的等级上升除外的怪兽的等级数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
