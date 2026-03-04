--スポーア
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：这张卡在墓地存在的场合，从自己墓地把这张卡以外的1只植物族怪兽除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的等级上升除外的怪兽的等级数值。
function c11747708.initial_effect(c)
	-- 创建效果，描述为“特殊召唤”，分类为特殊召唤，类型为起动效果，适用区域为墓地，限制决斗中使用次数为1次
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
-- 过滤函数，用于筛选满足条件的植物族怪兽（等级大于0且可作为除外的代价）
function c11747708.costfilter(c)
	return c:IsRace(RACE_PLANT) and c:GetLevel()>0 and c:IsAbleToRemoveAsCost()
end
-- 效果的费用处理函数，检查是否满足除外植物族怪兽的条件
function c11747708.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足除外植物族怪兽的条件，即在自己墓地存在至少1只符合条件的植物族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c11747708.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择1只满足条件的植物族怪兽除外
	local g=Duel.SelectMatchingCard(tp,c11747708.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的怪兽除外作为效果的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- 效果的目标设定函数，判断是否可以特殊召唤此卡
function c11747708.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果的发动处理函数，执行特殊召唤及后续等级提升效果
function c11747708.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==1 then
		-- 这个效果特殊召唤的这张卡的等级上升除外的怪兽的等级数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
