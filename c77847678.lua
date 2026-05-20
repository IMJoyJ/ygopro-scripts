--紫炎の計略
-- 效果：
-- 自己场上存在的名字带有「六武众」的怪兽被战斗破坏的场合才能发动。从手卡把名字带有「六武众」的怪兽最多2只特殊召唤。
function c77847678.initial_effect(c)
	-- 自己场上存在的名字带有「六武众」的怪兽被战斗破坏的场合才能发动。从手卡把名字带有「六武众」的怪兽最多2只特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c77847678.condition)
	e1:SetTarget(c77847678.target)
	e1:SetOperation(c77847678.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查卡片是否是原本由自己控制且名字带有「六武众」的怪兽。
function c77847678.cfilter(c,tp)
	return c:IsSetCard(0x103d) and c:IsPreviousControler(tp)
end
-- 发动条件：检查被战斗破坏的怪兽中是否存在原本由自己控制的名字带有「六武众」的怪兽。
function c77847678.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c77847678.cfilter,1,nil,tp)
end
-- 过滤条件：检查卡片是否是手卡中可以特殊召唤的名字带有「六武众」的怪兽。
function c77847678.filter(c,e,tp)
	return c:IsSetCard(0x103d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动准备：在发动阶段检查怪兽区域是否有空位，且手卡中是否存在可特殊召唤的「六武众」怪兽，并设置特殊召唤的操作信息。
function c77847678.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段检查手卡中是否存在至少1只可以特殊召唤的名字带有「六武众」的怪兽。
		and Duel.IsExistingMatchingCard(c77847678.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：向系统宣告此效果包含从手卡特殊召唤怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理：计算可特殊召唤的数量（受怪兽区域空格及「青眼精灵龙」等效果限制），从手卡选择最多2只「六武众」怪兽特殊召唤。
function c77847678.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1到ft张（最多2张）满足条件的名字带有「六武众」的怪兽。
	local g=Duel.SelectMatchingCard(tp,c77847678.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
