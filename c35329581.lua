--シャドー・インパルス
-- 效果：
-- 「暗影脉冲」在1回合只能发动1张。
-- ①：自己场上的同调怪兽被战斗·效果破坏送去墓地时，以那1只怪兽为对象才能发动。和那只怪兽相同等级·种族而卡名不同的1只同调怪兽从额外卡组特殊召唤。
function c35329581.initial_effect(c)
	-- 「暗影脉冲」在1回合只能发动1张。①：自己场上的同调怪兽被战斗·效果破坏送去墓地时，以那1只怪兽为对象才能发动。和那只怪兽相同等级·种族而卡名不同的1只同调怪兽从额外卡组特殊召唤。
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
-- 该函数判断被送去墓地的怪兽能否成为本卡效果的对象：要求其在墓地、之前在自己场上、由战斗或效果破坏送去墓地、是同调怪兽且能成为效果对象，并且额外卡组存在可被特殊召唤的候选怪兽。
function c35329581.filter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsCanBeEffectTarget(e)
		and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		-- 额外要求对象属于同调怪兽，并检查额外卡组中至少存在1张满足spfilter条件（同等级、同种族、卡名不同且能特殊召唤）的同调怪兽，确保效果处理时能成功特殊召唤。
		and c:IsType(TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(c35329581.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 该函数筛选额外卡组中可被特殊召唤的同调怪兽：必须与对象怪兽等级相同、种族相同、卡名不同，且能够被当前效果正常特殊召唤，同时额外卡组怪兽有可用区域。
function c35329581.spfilter(c,e,tp,tc)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(tc:GetLevel())
		and c:IsRace(tc:GetRace()) and not c:IsCode(tc:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查从额外卡组特殊召唤该怪兽时，自己场上是否存在可用的额外怪兽区/主怪兽区空格（GetLocationCountFromEx>0）。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时的目标选择处理：先在本次被送去墓地的怪兽集合中检查是否存在符合filter的对象，若存在则让玩家选择其中1只作为对象，并设置操作信息为从额外卡组特殊召唤。
function c35329581.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c35329581.filter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c35329581.filter,1,nil,e,tp) end
	-- 向玩家发送选择提示：HINTMSG_TARGET表示“请选择效果的对象”，用于在后续选择卡时显示对应提示文本。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,c35329581.filter,1,1,nil,e,tp)
	-- 将选择的那只怪兽设置为当前连锁的效果对象，使效果处理时可以正确获取该怪兽（取对象效果）。
	Duel.SetTargetCard(g)
	-- 设置本次效果处理的操作信息：效果类别为特殊召唤，预计从额外卡组特殊召唤1只怪兽给自己，用于连锁时点检测等。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：取得对象怪兽，若对象仍与效果关联，则从额外卡组选择1只符合条件的同调怪兽特殊召唤；若对象失去关联则处理不适用。
function c35329581.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽，即被战斗/效果破坏送去墓地的那只同调怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 向玩家发送选择提示：HINTMSG_SPSUMMON表示“请选择要特殊召唤的卡”，在后续从额外卡组选择怪兽时显示提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的额外卡组中选择1张满足spfilter条件的同调怪兽（与对象等级相同、种族相同、卡名不同且能特殊召唤）。
	local sg=Duel.SelectMatchingCard(tp,c35329581.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	if sg:GetCount()>0 then
		-- 将选择的同调怪兽以表侧表示特殊召唤到自己场上；参数0表示不额外附加召唤方式，同时检查其召唤条件与苏生限制。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
