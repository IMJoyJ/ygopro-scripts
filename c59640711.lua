--SR電々大公
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把墓地的这张卡除外才能发动。从自己的手卡·墓地选「疾行机人 电电大公」以外的1只「疾行机人」调整特殊召唤。
function c59640711.initial_effect(c)
	-- ①：把墓地的这张卡除外才能发动。从自己的手卡·墓地选「疾行机人 电电大公」以外的1只「疾行机人」调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,59640711)
	-- 把墓地的这张卡除外作为发动成本（Cost）
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c59640711.sptg)
	e1:SetOperation(c59640711.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡·墓地中「疾行机人 电电大公」以外的「疾行机人」调整怪兽，且可以被特殊召唤
function c59640711.spfilter(c,e,tp)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_TUNER) and not c:IsCode(59640711) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测（Target阶段）
function c59640711.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在至少1只满足特殊召唤条件的「疾行机人」调整怪兽
		and Duel.IsExistingMatchingCard(c59640711.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从手卡或墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的效果处理（Operation阶段）
function c59640711.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡或墓地选择1只满足条件的「疾行机人」调整怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c59640711.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
