--パケットリンク
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段2才能发动。选自己的手卡·卡组·墓地的2星以下的怪兽任意数量在作为场上的连接怪兽所连接区的自己场上特殊召唤（同名卡最多1张）。
function c78859567.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的主要阶段2才能发动。选自己的手卡·卡组·墓地的2星以下的怪兽任意数量在作为场上的连接怪兽所连接区的自己场上特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,78859567+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c78859567.condition)
	e1:SetTarget(c78859567.target)
	e1:SetOperation(c78859567.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查当前是否为主要阶段2
function c78859567.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤条件：2星以下且可以特殊召唤的怪兽
function c78859567.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的准备：检查是否有可用的连接区域以及手卡、卡组、墓地是否有可特召的怪兽，并设置操作信息
function c78859567.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自身场上所有连接怪兽所连接的区域
		local zone=Duel.GetLinkedZone(tp)
		-- 计算连接区域内可用于特殊召唤的空闲怪兽区域数量
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
		-- 检查连接区域是否有空位，且手卡、卡组、墓地是否存在至少1只满足条件的怪兽
		return ct>0 and Duel.IsExistingMatchingCard(c78859567.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 设置特殊召唤的操作信息，预计从手卡、卡组、墓地特殊召唤至少1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：在连接区域特殊召唤手卡、卡组、墓地的2星以下怪兽（同名卡最多1张）
function c78859567.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自身场上所有连接怪兽所连接的区域
	local zone=Duel.GetLinkedZone(tp)
	-- 计算连接区域内可用于特殊召唤的空闲怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if ct<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 获取手卡、卡组、墓地中所有满足条件且不受王家之谷影响的怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c78859567.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家选择1到ct张卡名各不相同的怪兽
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
		-- 将选中的怪兽以表侧表示特殊召唤到指定的连接区域
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
