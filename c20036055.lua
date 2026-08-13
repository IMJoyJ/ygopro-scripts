--旅人の到彼岸
-- 效果：
-- 「旅人之到彼岸」在1回合只能发动1张。
-- ①：以自己墓地的这个回合被送去墓地的「彼岸」怪兽任意数量为对象才能发动。那些怪兽守备表示特殊召唤。
function c20036055.initial_effect(c)
	-- 对应效果原文：「旅人之到彼岸」在1回合只能发动1张。①：以自己墓地的这个回合被送去墓地的「彼岸」怪兽任意数量为对象才能发动。那些怪兽守备表示特殊召唤。
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
-- 筛选可特殊召唤的「彼岸」怪兽：属于0xb1系列、本回合被送去墓地、不是因回到手牌/卡组等理由而进入墓地，并且可以被特殊召唤为表侧守备表示。
function c20036055.filter(c,e,tp,id)
	return c:IsSetCard(0xb1) and c:GetTurnID()==id and not c:IsReason(REASON_RETURN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的发动条件和对象选择：在主要怪兽区有空位且墓地存在符合条件对象时，从自己墓地选择1至上限数量的「彼岸」怪兽作为对象。
function c20036055.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取对象合法性检查：当连锁中需要确认对象是否仍合法时，检查该卡是否在自己墓地、控制者为自己且满足筛选条件。
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20036055.filter(chkc,e,tp,Duel.GetTurnCount()) end
	-- 发动前检查：自己场上主要怪兽区是否有至少1个可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动前检查：自己墓地是否存在至少1只满足筛选条件的「彼岸」怪兽。
		and Duel.IsExistingTarget(c20036055.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetTurnCount()) end
	-- 获取自己场上主要怪兽区的可用空格数量，作为特殊召唤数量的上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 显示“请选择要特殊召唤的卡”的选择提示，供玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1至ft张满足条件的「彼岸」怪兽，并将其设为当前连锁的取对象。
	local g=Duel.SelectTarget(tp,c20036055.filter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp,Duel.GetTurnCount())
	-- 将本次效果处理信息设为特殊召唤，目标为已选择的g，数量为g的卡数，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果处理：取出对象并过滤仍与效果关联的卡；若「青眼精灵龙」效果导致不能同时特殊召唤2只以上且对象多于1只，则不处理；若对象数量超过可用区域，则选择可用区域数量的卡；最后将它们以表侧守备表示特殊召唤。
function c20036055.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上主要怪兽区的可用空格数量，用于判断可特殊召唤的数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取当前连锁处理的对象卡组，即发动时选择的那组「彼岸」怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 当可特殊召唤数量受可用区域限制时，再次显示选择提示，让玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将最终确定的一组「彼岸」怪兽以表侧守备表示特殊召唤到自己场上。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
