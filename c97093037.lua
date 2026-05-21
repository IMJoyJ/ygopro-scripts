--創世者の化身
-- 效果：
-- 可以把这张卡作祭品，从手卡特殊召唤1只「创世神」。
function c97093037.initial_effect(c)
	-- 可以把这张卡作祭品，从手卡特殊召唤1只「创世神」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97093037,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c97093037.spcost)
	e1:SetTarget(c97093037.sptg)
	e1:SetOperation(c97093037.spop)
	c:RegisterEffect(e1)
end
-- 发动代价：检查自身是否可以解放，并将自身解放
function c97093037.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡名为「创世神」且可以特殊召唤的怪兽
function c97093037.filter(c,e,tp)
	return c:IsCode(61505339) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件与目标检查：检查怪兽区域空位以及手牌中是否存在可特殊召唤的「创世神」
function c97093037.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用空位（因为自身作为代价解放，所以空位数大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手牌中是否存在至少1只满足条件的「创世神」
		and Duel.IsExistingMatchingCard(c97093037.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手牌特殊召唤1只「创世神」
function c97093037.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有可用空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只「创世神」
	local g=Duel.SelectMatchingCard(tp,c97093037.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
