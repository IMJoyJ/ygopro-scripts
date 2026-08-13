--ベアルクティ・スライダー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以1只「北极天熊」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。这张卡的发动后，直到回合结束时自己若非持有等级的怪兽则不能特殊召唤。
function c53865474.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己墓地的怪兽以及除外的自己怪兽之中以1只「北极天熊」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。这张卡的发动后，直到回合结束时自己若非持有等级的怪兽则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,53865474+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c53865474.target)
	e1:SetOperation(c53865474.activate)
	c:RegisterEffect(e1)
end
-- 定义可被选择的对象筛选条件：该怪兽必须是「北极天熊」怪兽，位于自己墓地或表侧表示的除外状态，并且能够被特殊召唤。
function c53865474.filter(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x163) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义取对象处理：若检查连锁中的对象，则要求该卡在自己墓地/除外区且满足筛选条件；若发动时检查，则判定场上是否有空位以及是否存在至少1只符合条件的对象。
function c53865474.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c53865474.filter(chkc,e,tp) end
	-- 发动时判定：自己主要怪兽区是否有空余的格子可以特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时判定：自己墓地与除外区中是否存在至少1只满足筛选条件且可以作为效果对象的「北极天熊」怪兽。
		and Duel.IsExistingTarget(c53865474.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向操作者发出“请选择要特殊召唤的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地和除外区选择1只满足筛选条件的「北极天熊」怪兽，并将其设为这张卡的效果对象。
	local g=Duel.SelectTarget(tp,c53865474.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 登记本次操作信息：将1只对象怪兽通过效果进行特殊召唤，供后续连锁/效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若对象仍与效果关联则将其特殊召唤；召唤成功后再对那只怪兽附加不能攻击和结束阶段破坏的效果，随后给这张卡的发动者附加直到回合结束不能特殊召唤非持有等级怪兽的自肃。
function c53865474.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的效果对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍然与效果关联，并且以表侧表示特殊召唤成功（返回值不为0）时，才进行后续的附加效果处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		tc:RegisterFlagEffect(53865474,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 结束阶段破坏。这张卡的发动后，直到回合结束时自己若非持有等级的怪兽则不能特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabelObject(tc)
		e2:SetCondition(c53865474.descon)
		e2:SetOperation(c53865474.desop)
		-- 将“结束阶段破坏那只特殊召唤怪兽”的诱发效果注册到场上，使其在结束阶段时点进行判定与处理。
		Duel.RegisterEffect(e2,tp)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己若非持有等级的怪兽则不能特殊召唤。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetTargetRange(1,0)
		e3:SetTarget(c53865474.splimit)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将“不能特殊召唤非持有等级怪兽”的自肃效果注册到场上，效果持续到回合结束。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 结束阶段破坏效果的发动条件：若被特殊召唤的怪兽仍带有对应标记（仍在场上且未被重置），则满足条件发动破坏；否则重置该效果且不发动。
function c53865474.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(53865474)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段破坏效果的处理：取出标记对象并执行破坏。
function c53865474.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果原因破坏该怪兽，将其送去墓地。
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 自肃效果的判定条件：若怪兽星级为0（即不持有等级），则不能将其特殊召唤。
function c53865474.splimit(e,c)
	return c:IsLevel(0)
end
