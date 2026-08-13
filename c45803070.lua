--ティオの蟲惑魔
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，以自己墓地1只「虫惑魔」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：这张卡特殊召唤成功时，以自己墓地1张「洞」通常陷阱卡或者「落穴」通常陷阱卡为对象才能发动。那张卡在自己场上盖放。那张卡在下次的自己回合的结束阶段除外。
-- ③：这张卡不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
function c45803070.initial_effect(c)
	-- ③：这张卡不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c45803070.efilter)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时，以自己墓地1只「虫惑魔」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45803070,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c45803070.sptg)
	e2:SetOperation(c45803070.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤成功时，以自己墓地1张「洞」通常陷阱卡或者「落穴」通常陷阱卡为对象才能发动。那张卡在自己场上盖放。那张卡在下次的自己回合的结束阶段除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45803070,1))  --"盖放"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCategory(CATEGORY_SSET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,45803070)
	e3:SetTarget(c45803070.settg)
	e3:SetOperation(c45803070.setop)
	c:RegisterEffect(e3)
end
-- 免疫判定函数：检查效果来源卡是否为「洞」或「落穴」系列的通常陷阱卡，若是则该卡发动的效果对这张卡无效。
function c45803070.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 特殊召唤候选过滤：选择自己墓地的「虫惑魔」怪兽，且该怪兽可以被玩家tp以表侧守备表示特殊召唤。
function c45803070.filter(c,e,tp)
	return c:IsSetCard(0x108a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动条件与对象选择：在主要怪兽区有空位且墓地存在满足条件的「虫惑魔」怪兽时，选择其中1只为对象。
function c45803070.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45803070.filter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否有空位，若无空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足特殊召唤条件的「虫惑魔」怪兽作为对象。
		and Duel.IsExistingTarget(c45803070.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「虫惑魔」怪兽，并设为效果对象。
	local g=Duel.SelectTarget(tp,c45803070.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次操作包含特殊召唤，处理时会将所选怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将对象怪兽以表侧守备表示特殊召唤到自己场上。
function c45803070.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时仍关联的对象卡（即之前选择的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将那只怪兽以表侧守备表示特殊召唤到控制者场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 盖放候选过滤：选择自己墓地的「洞」或「落穴」系列通常陷阱卡，且该卡可以被盖放到魔陷区。
function c45803070.setfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89) and c:IsSSetable()
end
-- ②效果的发动条件与对象选择：在魔陷区有空位且墓地存在符合条件的通常陷阱卡时，选择其中1张为对象。
function c45803070.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c45803070.setfilter(chkc) end
	-- 检查自己魔陷区是否有空位，若无空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在至少1张可以盖放的「洞」或「落穴」通常陷阱卡作为对象。
		and Duel.IsExistingTarget(c45803070.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示“请选择要盖放的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己墓地选择1张符合条件的通常陷阱卡，并设为效果对象。
	local g=Duel.SelectTarget(tp,c45803070.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记该操作涉及从墓地离开的效果（用于「王家长眠之谷」等干涉墓地的卡）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果处理：若对象卡仍关联且成功盖放到自己魔陷区，则为其设置“在下次自己的回合结束阶段除外”的延迟效果。
function c45803070.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时仍关联的对象卡（即之前选择的墓地陷阱卡）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡与效果仍有关联，并尝试将其盖放到自己场上；若盖放成功则继续设置除外效果。
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		local fid=e:GetHandler():GetFieldID()
		-- 那张卡在下次的自己回合的结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 判断当前回合玩家是否为自己：若是，则记录当前回合数，使除外的时点确定为“下次自己的回合”结束阶段。
		if Duel.GetTurnPlayer()==tp then
			-- 记录当前回合数，用于和下一回合的回合数进行比较，确保只在下次自己的结束阶段才除外。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetLabel(0)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		end
		e1:SetLabelObject(tc)
		e1:SetValue(fid)
		e1:SetCondition(c45803070.rmcon)
		e1:SetOperation(c45803070.rmop)
		-- 将延迟除外效果注册到场上，使其持续监测结束阶段。
		Duel.RegisterEffect(e1,tp)
		tc:RegisterFlagEffect(45803070,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	end
end
-- 除外效果的条件判定：当前已经经过了一整个自己的回合（回合数不等于记录值），并且现在是自己的结束阶段。
function c45803070.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否到了“下次自己的回合的结束阶段”：回合数已经改变且当前回合玩家是自己。
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()==tp
end
-- 除外效果的处理：若盖放的那张陷阱卡没有离开过场上或改变状态（通过标志值确认），则将其表侧表示除外。
function c45803070.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(45803070)==e:GetValue() then
		-- 将盖放的那张陷阱卡以表侧表示除外，原因是效果造成（REASON_EFFECT）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
