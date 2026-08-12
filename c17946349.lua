--斬機ダイア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤时，以自己墓地1只电子界族·4星怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果不能发动。
-- ②：场上的这张卡为素材作同调·超量召唤的「斩机」怪兽得到以下效果。
-- ●这张卡特殊召唤的回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
function c17946349.initial_effect(c)
	-- ①：这张卡召唤时，以自己墓地1只电子界族·4星怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17946349,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,17946349)
	e1:SetTarget(c17946349.sptg)
	e1:SetOperation(c17946349.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为素材作同调·超量召唤的「斩机」怪兽得到以下效果。●这张卡特殊召唤的回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCountLimit(1,17946350)
	e2:SetCondition(c17946349.effcon)
	e2:SetOperation(c17946349.effop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的墓地电子界族4星怪兽
function c17946349.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件
function c17946349.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c17946349.spfilter(chkc,e,tp) end
	-- 判断场上是否有特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c17946349.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c17946349.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果
function c17946349.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且进行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使特殊召唤的怪兽效果不能发动
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(17946349,4))  --"「斩机 径武」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断是否为同调或超量召唤素材且为斩机卡组
function c17946349.effcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_SYNCHRO+REASON_XYZ)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():GetReasonCard():IsSetCard(0x132)
end
-- 设置对方效果无效效果
function c17946349.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 对方把魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(17946349,1))  --"对方效果无效（斩机 径武）"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c17946349.discon)
	e1:SetTarget(c17946349.distg)
	e1:SetOperation(c17946349.disop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若怪兽没有效果类型则添加效果类型
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(17946349,2))  --"「斩机 径武」效果适用中"
end
-- 判断是否为对方发动效果且该效果可无效
function c17946349.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动效果且该效果可无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and Duel.IsChainDisablable(ev)
end
-- 设置无效效果的处理信息
function c17946349.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示对方选择了无效效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置无效效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(17946349,3))  --"已发动过效果"
end
-- 处理效果无效
function c17946349.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使效果无效
	Duel.NegateEffect(ev)
end
