--シャドー・インパルス
-- 效果：
-- 「暗影脉冲」在1回合只能发动1张。
-- ①：自己场上的同调怪兽被战斗·效果破坏送去墓地时，以那1只怪兽为对象才能发动。和那只怪兽相同等级·种族而卡名不同的1只同调怪兽从额外卡组特殊召唤。
function c35329581.initial_effect(c)
	-- 效果原文内容：「暗影脉冲」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,35329581+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c35329581.target)
	e1:SetOperation(c35329581.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的被破坏送入墓地的同调怪兽
function c35329581.filter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsCanBeEffectTarget(e)
		and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		-- 检查是否存在满足条件的同调怪兽从额外卡组特殊召唤
		and c:IsType(TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(c35329581.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤满足条件的额外卡组同调怪兽
function c35329581.spfilter(c,e,tp,tc)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(tc:GetLevel())
		and c:IsRace(tc:GetRace()) and not c:IsCode(tc:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否有足够的位置特殊召唤该怪兽
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果原文内容：①：自己场上的同调怪兽被战斗·效果破坏送去墓地时，以那1只怪兽为对象才能发动。
function c35329581.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c35329581.filter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c35329581.filter,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,c35329581.filter,1,1,nil,e,tp)
	-- 设置当前连锁的效果对象为所选怪兽
	Duel.SetTargetCard(g)
	-- 设置操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果原文内容：和那只怪兽相同等级·种族而卡名不同的1只同调怪兽从额外卡组特殊召唤。
function c35329581.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的额外卡组同调怪兽
	local sg=Duel.SelectMatchingCard(tp,c35329581.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	if sg:GetCount()>0 then
		-- 将所选怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
