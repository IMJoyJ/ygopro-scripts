--正義の味方 カイバーマン
-- 效果：
-- 把这张卡解放才能发动。从手卡把1只「青眼白龙」特殊召唤。
function c34627841.initial_effect(c)
	-- 记录此卡具有「青眼白龙」的卡名信息
	aux.AddCodeList(c,89631139)
	-- 把这张卡解放才能发动。从手卡把1只「青眼白龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34627841,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c34627841.spcost)
	e1:SetTarget(c34627841.sptg)
	e1:SetOperation(c34627841.spop)
	c:RegisterEffect(e1)
end
-- 检查是否可以解放此卡作为效果的代价
function c34627841.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选手卡中的「青眼白龙」
function c34627841.filter(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断效果发动时是否满足条件，即手卡有「青眼白龙」且场上存在召唤空间
function c34627841.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有召唤怪兽的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡中是否存在满足条件的「青眼白龙」
		and Duel.IsExistingMatchingCard(c34627841.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行效果的处理流程，选择并特殊召唤「青眼白龙」
function c34627841.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有召唤怪兽的空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只「青眼白龙」作为特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,c34627841.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「青眼白龙」特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
