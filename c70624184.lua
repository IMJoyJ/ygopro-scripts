--セイクリッド・ハワー
-- 效果：
-- 把这张卡解放才能发动。从自己的手卡·墓地把「星圣·候」以外的1只名字带有「星圣」的怪兽表侧守备表示特殊召唤。
function c70624184.initial_effect(c)
	-- 把这张卡解放才能发动。从自己的手卡·墓地把「星圣·候」以外的1只名字带有「星圣」的怪兽表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70624184,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c70624184.spcost)
	e1:SetTarget(c70624184.sptg)
	e1:SetOperation(c70624184.spop)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理：检查自身是否可以解放，并在发动时将自身解放
function c70624184.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：手卡·墓地中「星圣·候」以外的名字带有「星圣」且可以表侧守备表示特殊召唤的怪兽
function c70624184.filter(c,e,tp)
	return c:IsSetCard(0x53) and not c:IsCode(70624184) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动准备（Target）处理：检查怪兽区域空位以及是否存在可特殊召唤的怪兽
function c70624184.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（由于自身作为代价解放，所以可用格子数大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或墓地中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c70624184.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理（Operation）：从手卡·墓地选择1只「星圣」怪兽表侧守备表示特殊召唤
function c70624184.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c70624184.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选中的怪兽表侧守备表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
