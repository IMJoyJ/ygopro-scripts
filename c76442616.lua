--HERO’S ボンド
-- 效果：
-- 场上有名字带有「英雄」的怪兽存在时才能发动。从手卡特殊召唤2只4星以下的名字带有「元素英雄」的怪兽。
function c76442616.initial_effect(c)
	-- 场上有名字带有「英雄」的怪兽存在时才能发动。从手卡特殊召唤2只4星以下的名字带有「元素英雄」的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c76442616.condition)
	e1:SetTarget(c76442616.target)
	e1:SetOperation(c76442616.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「英雄」怪兽
function c76442616.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8)
end
-- 发动条件：检查场上是否存在「英雄」怪兽
function c76442616.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1只表侧表示的「英雄」怪兽
	return Duel.IsExistingMatchingCard(c76442616.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤条件：手卡中等级4以下且可以特殊召唤的「元素英雄」怪兽
function c76442616.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的检测：包含青眼精灵龙的限制、怪兽区域空格数以及手卡中可特召怪兽数量的检测
function c76442616.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自身场上的怪兽区域空位数是否大于1（因为需要特殊召唤2只怪兽）
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查手卡中是否存在至少2只满足条件的「元素英雄」怪兽
		and Duel.IsExistingMatchingCard(c76442616.filter,tp,LOCATION_HAND,0,2,nil,e,tp) end
	-- 设置效果处理信息：从手卡特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 效果处理：从手卡特殊召唤2只4星以下的「元素英雄」怪兽
function c76442616.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时，若自身场上的怪兽区域空位数小于等于1，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	-- 获取手卡中所有满足条件的「元素英雄」怪兽
	local g=Duel.GetMatchingGroup(c76442616.filter,tp,LOCATION_HAND,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
