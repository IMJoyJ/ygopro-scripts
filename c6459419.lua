--アマゾネス転生術
-- 效果：
-- 自己场上表侧表示存在的名字带有「亚马逊」的怪兽全部破坏。那之后，可以把最多和破坏数量相同数量的自己墓地存在的4星以下的名字带有「亚马逊」的怪兽表侧守备表示特殊召唤。
function c6459419.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「亚马逊」的怪兽全部破坏。那之后，可以把最多和破坏数量相同数量的自己墓地存在的4星以下的名字带有「亚马逊」的怪兽表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c6459419.target)
	e1:SetOperation(c6459419.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示存在的「亚马逊」怪兽
function c6459419.dfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4)
end
-- 过滤条件：自己墓地存在的4星以下、可以表侧守备表示特殊召唤的「亚马逊」怪兽
function c6459419.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标过滤与操作信息设置：检查自己场上是否存在表侧表示的「亚马逊」怪兽，并设置破坏这些怪兽的操作信息
function c6459419.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否存在至少1只表侧表示的「亚马逊」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c6459419.dfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有表侧表示的「亚马逊」怪兽
	local g=Duel.GetMatchingGroup(c6459419.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置当前连锁的操作信息为破坏这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：破坏自己场上所有表侧表示的「亚马逊」怪兽，之后根据破坏数量和怪兽区域空位数，选择并特殊召唤自己墓地中对应数量的4星以下「亚马逊」怪兽
function c6459419.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「亚马逊」怪兽
	local g=Duel.GetMatchingGroup(c6459419.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 破坏获取到的怪兽，并记录实际被破坏的数量
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>ct then ft=ct end
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取自己墓地中满足特殊召唤条件且不受「王家长眠之谷」影响的4星以下「亚马逊」怪兽
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c6459419.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 如果墓地有符合条件的怪兽，询问玩家是否进行特殊召唤
	if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(6459419,0)) then  --"是否要特殊召唤？"
		-- 中断当前效果，使破坏和特殊召唤视为不同时处理（错时点）
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local fg=sg:Select(tp,ft,ft,nil)
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(fg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
