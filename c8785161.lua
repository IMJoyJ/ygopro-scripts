--RR－ワイルド・ヴァルチャー
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段把这张卡解放才能发动。等级合计直到变成6星为止，从自己的手卡·墓地选2只「急袭猛禽」怪兽特殊召唤。
function c8785161.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段把这张卡解放才能发动。等级合计直到变成6星为止，从自己的手卡·墓地选2只「急袭猛禽」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c8785161.spcon)
	e1:SetCost(c8785161.spcost)
	e1:SetTarget(c8785161.sptg)
	e1:SetOperation(c8785161.spop)
	c:RegisterEffect(e1)
	if not c8785161.global_check then
		c8785161.global_check=true
		-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段把这张卡解放才能发动。等级合计直到变成6星为止，从自己的手卡·墓地选2只「急袭猛禽」怪兽特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(8785161)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置全局效果的操作为：给召唤成功的怪兽注册召唤回合标记（用于检测“召唤成功的回合”）。
		ge1:SetOperation(aux.sumreg)
		-- 注册全局效果：用于记录怪兽通常召唤成功的玩家回合。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(8785161)
		-- 注册全局效果：用于记录怪兽特殊召唤成功的玩家回合。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 效果发动条件：自身具有召唤·特殊召唤成功的回合的标记（即在召唤·特殊召唤成功的回合）。
function c8785161.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(8785161)>0
end
-- 效果发动代价：解放自身。
function c8785161.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件1：手卡·墓地中等级在5星以下、可以特殊召唤的「急袭猛禽」怪兽，且手卡·墓地中存在另一只等级与其合计为6星、可以特殊召唤的「急袭猛禽」怪兽。
function c8785161.spfilter1(c,e,tp)
	local lv=c:GetLevel()
	return c:IsLevelBelow(5) and c:IsSetCard(0xba) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手卡·墓地中是否存在另一只等级为（6 - 第一只怪兽等级）的、可以特殊召唤的「急袭猛禽」怪兽。
		and Duel.IsExistingMatchingCard(c8785161.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp,6-lv)
end
-- 过滤条件2：手卡·墓地中等级为指定数值（lv）、可以特殊召唤的「急袭猛禽」怪兽。
function c8785161.spfilter2(c,e,tp,lv)
	return c:IsSetCard(0xba) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标：检查自己场上是否有空位，且手卡·墓地中是否存在满足条件的怪兽，并设置特殊召唤的操作信息。
function c8785161.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位（因为解放了自身，此时至少需要1个空位，但由于要特召2只，后续处理会检查是否至少有2个空位）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地中是否存在至少1只满足过滤条件1的「急袭猛禽」怪兽。
		and Duel.IsExistingMatchingCard(c8785161.spfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡·墓地特殊召唤怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：从手卡·墓地选择2只等级合计为6星的「急袭猛禽」怪兽特殊召唤。
function c8785161.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域空位是否小于2个，若小于2个则不处理（因为必须特殊召唤2只）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·墓地选择1只满足过滤条件1的「急袭猛禽」怪兽（受王家长眠之谷影响）。
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c8785161.spfilter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc1=g1:GetFirst()
	if not tc1 then return end
	-- 再次提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·墓地选择第2只「急袭猛禽」怪兽，其等级必须为（6 - 第一只怪兽的等级）（受王家长眠之谷影响）。
	local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c8785161.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,tc1,e,tp,6-tc1:GetLevel())
	g1:Merge(g2)
	-- 将选中的2只怪兽以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
end
