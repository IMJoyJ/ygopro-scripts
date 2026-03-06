--念動収集機
-- 效果：
-- 自己墓地存在的2星以下的念动力族怪兽任意数量特殊召唤。那之后，自己受到这个效果特殊召唤的怪兽等级合计×300的数值的伤害。
function c28741524.initial_effect(c)
	-- 效果原文：自己墓地存在的2星以下的念动力族怪兽任意数量特殊召唤。那之后，自己受到这个效果特殊召唤的怪兽等级合计×300的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c28741524.sptg)
	e1:SetOperation(c28741524.spop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的墓地念动力族2星以下怪兽，用于特殊召唤。
function c28741524.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤出与当前效果相关的念动力族怪兽，用于后续处理。
function c28741524.opfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsRace(RACE_PSYCHO)
end
-- 设置选择目标的条件：墓地自己控制的怪兽，且满足filter函数条件。
function c28741524.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28741524.filter(chkc,e,tp) end
	-- 判断是否满足发动条件：场上存在空位且墓地存在符合条件的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：墓地存在至少1只符合条件的怪兽。
		and Duel.IsExistingTarget(c28741524.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤目标。
	local g=Duel.SelectTarget(tp,c28741524.filter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置操作信息：特殊召唤目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
	local lv=g:GetSum(Card.GetLevel)
	-- 设置操作信息：对玩家造成伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,lv*300)
end
-- 效果处理函数：获取目标怪兽并执行特殊召唤和伤害处理。
function c28741524.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的目标怪兽，并过滤出与效果相关的怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c28741524.opfilter,nil,e)
	-- 获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft<g:GetCount() or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()>0 then
		-- 将目标怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 获取实际被特殊召唤的怪兽组。
		local og=Duel.GetOperatedGroup()
		local lv=og:GetSum(Card.GetLevel)
		-- 中断当前效果处理，使后续处理视为错时点。
		Duel.BreakEffect()
		-- 对玩家造成等于特殊召唤怪兽等级总和乘以300的伤害。
		Duel.Damage(tp,lv*300,REASON_EFFECT)
	end
end
