--スピリッツ・オブ・ファラオ
-- 效果：
-- 这张卡不能进行通常召唤。这张卡只能通过「第一之棺」的效果进行特殊召唤。这张卡特殊召唤成功时，可以从自己的墓地里特殊召唤至多4只2星以下的不死族通常怪兽上场。
function c25343280.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文：这张卡不能进行通常召唤。这张卡只能通过「第一之棺」的效果进行特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡特殊召唤成功时，可以从自己的墓地里特殊召唤至多4只2星以下的不死族通常怪兽上场。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25343280,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c25343280.target)
	e2:SetOperation(c25343280.operation)
	c:RegisterEffect(e2)
end
-- 检索满足条件的2星以下不死族通常怪兽（可特殊召唤）
function c25343280.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(2) and c:IsRace(RACE_ZOMBIE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置选择目标的条件：墓地里控制者为自己的不死族通常怪兽，等级不超过2
function c25343280.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25343280.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c25343280.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>4 then ft=4 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c25343280.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 处理特殊召唤操作：获取目标怪兽并进行特殊召唤
function c25343280.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 筛选出与当前效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 判断场上是否还有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) and g:GetCount()>1 then return end
	-- 将目标怪兽特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
