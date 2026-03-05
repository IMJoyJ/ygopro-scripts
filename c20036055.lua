--旅人の到彼岸
-- 效果：
-- 「旅人之到彼岸」在1回合只能发动1张。
-- ①：以自己墓地的这个回合被送去墓地的「彼岸」怪兽任意数量为对象才能发动。那些怪兽守备表示特殊召唤。
function c20036055.initial_effect(c)
	-- 效果原文内容：「旅人之到彼岸」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,20036055+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c20036055.sptg)
	e1:SetOperation(c20036055.spop)
	c:RegisterEffect(e1)
end
-- 效果作用：检索满足条件的「彼岸」怪兽（在墓地、本回合被送去墓地、不是因返回墓地的原因、可以特殊召唤）
function c20036055.filter(c,e,tp,id)
	return c:IsSetCard(0xb1) and c:GetTurnID()==id and not c:IsReason(REASON_RETURN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果作用：判断是否满足发动条件（场上有空位、墓地有符合条件的怪兽）
function c20036055.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 效果作用：作为目标选择函数，判断所选卡片是否满足条件（在墓地、是自己控制的、是「彼岸」怪兽、是本回合被送去墓地的、不是因返回墓地的原因）
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20036055.filter(chkc,e,tp,Duel.GetTurnCount()) end
	-- 效果作用：判断是否满足发动条件（场上有空位）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断是否满足发动条件（墓地有符合条件的怪兽）
		and Duel.IsExistingTarget(c20036055.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetTurnCount()) end
	-- 效果作用：获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c20036055.filter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp,Duel.GetTurnCount())
	-- 效果作用：设置连锁操作信息，确定要特殊召唤的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果原文内容：①：以自己墓地的这个回合被送去墓地的「彼岸」怪兽任意数量为对象才能发动。那些怪兽守备表示特殊召唤。
function c20036055.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 效果作用：获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 效果作用：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 效果作用：将目标怪兽以守备表示特殊召唤到场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
