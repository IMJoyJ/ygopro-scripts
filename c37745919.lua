--ジャンクBOX
-- 效果：
-- ①：以自己墓地1只4星以下的「变形斗士」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
function c37745919.initial_effect(c)
	-- ①：以自己墓地1只4星以下的「变形斗士」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c37745919.target)
	e1:SetOperation(c37745919.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为对象的怪兽：必须是「变形斗士」字段、4星以下且满足特殊召唤条件。
function c37745919.filter(c,e,tp)
	return c:IsSetCard(0x26) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时处理：若检查对象则验证该卡在墓地且为自己控制且符合筛选；若为发动合法性检查，则确认自己主要怪兽区有空位且墓地存在符合条件的对象。
function c37745919.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37745919.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在1只满足条件的「变形斗士」怪兽（且能成为对象）。
		and Duel.IsExistingTarget(c37745919.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c37745919.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置处理信息：将进行特殊召唤，对象为所选卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时：若仍有空位，取回对象，若对象仍关联且特殊召唤成功，则给该怪兽登记标记，并注册一个结束阶段破坏它的效果。
function c37745919.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的主要怪兽区则效果处理不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取效果处理时选择的作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与此效果关联后，将那只怪兽表侧攻击表示特殊召唤到自己场上。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(37745919,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c37745919.descon)
		e1:SetOperation(c37745919.desop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 将结束阶段破坏怪兽的效果注册到场上（供回合结束时触发）。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 破坏效果的条件：判断该怪兽仍持有与本次特殊召唤对应的标记，确保只破坏这次效果召唤的怪兽。
function c37745919.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(37745919)==e:GetLabel()
end
-- 破坏效果处理：破坏标记对应的怪兽。
function c37745919.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏该怪兽。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
