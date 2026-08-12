--ジャック・ワイバーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上1只机械族怪兽和这张卡除外，以自己墓地1只暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
function c23850421.initial_effect(c)
	-- 创建效果1，设置效果描述、分类、类型、属性、适用区域、使用次数限制、费用、目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23850421,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,23850421)
	e1:SetCost(c23850421.spcost)
	e1:SetTarget(c23850421.sptg)
	e1:SetOperation(c23850421.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否有满足条件的机械族怪兽（正面表示且可作为除外费用）
function c23850421.costfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAbleToRemoveAsCost()
end
-- 效果费用处理函数，检查是否满足除外条件并选择除外的卡片
function c23850421.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查场上是否存在满足条件的机械族怪兽作为除外费用
		and Duel.IsExistingMatchingCard(c23850421.costfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上满足条件的机械族怪兽作为除外费用
	local rg=Duel.SelectMatchingCard(tp,c23850421.costfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	rg:AddCard(e:GetHandler())
	-- 将选中的卡片除外作为效果的费用
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于判断墓地是否有满足条件的暗属性怪兽（可特殊召唤）
function c23850421.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标选择函数，设置目标为己方墓地的暗属性怪兽
function c23850421.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23850421.spfilter(chkc,e,tp) end
	-- 检查己方墓地是否存在满足条件的暗属性怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c23850421.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择己方墓地满足条件的暗属性怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c23850421.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，确定特殊召唤的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，将选中的墓地怪兽特殊召唤到场上
function c23850421.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
