--斬機ダイア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤时，以自己墓地1只电子界族·4星怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果不能发动。
-- ②：场上的这张卡为素材作同调·超量召唤的「斩机」怪兽得到以下效果。
-- ●这张卡特殊召唤的回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
function c17946349.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤时，以自己墓地1只电子界族·4星怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果不能发动。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：场上的这张卡为素材作同调·超量召唤的「斩机」怪兽得到以下效果。●这张卡特殊召唤的回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCountLimit(1,17946350)
	e2:SetCondition(c17946349.effcon)
	e2:SetOperation(c17946349.effop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地中满足电子界族、4星、且可以被效果特殊召唤的怪兽。
function c17946349.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动时点：先验证连锁对象是否合法（墓地且自己控制的电子界族4星可特召怪兽），再检查发动条件（场上是否有空位、是否存在满足条件的对象）。
function c17946349.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c17946349.spfilter(chkc,e,tp) end
	-- 发动条件检查：自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己墓地是否存在至少1只满足条件且能成为效果对象的电子界族·4星怪兽。
		and Duel.IsExistingTarget(c17946349.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象，并将其登记为连锁对象（取对象）。
	local g=Duel.SelectTarget(tp,c17946349.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将进行1张卡的特殊召唤，对象为已选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽特殊召唤；若特殊召唤成功，给它附加‘效果不能发动’的无效化效果。
function c17946349.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象卡（即发动时选择的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联后，以表侧攻击表示将其作为特殊召唤步骤进行召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(17946349,4))  --"「斩机 径武」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤处理，触发特殊召唤成功后的时点。
	Duel.SpecialSummonComplete()
end
-- ②效果的触发条件：这张卡在场上作为同调或超量素材被使用，且召唤出的怪兽是「斩机」怪兽。
function c17946349.effcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_SYNCHRO+REASON_XYZ)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():GetReasonCard():IsSetCard(0x132)
end
-- ②效果处理：给被召唤的「斩机」怪兽赋予‘对方效果无效’的效果；若该怪兽原本不是效果怪兽，则附加效果怪兽类型；并显示效果适用提示。
function c17946349.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡特殊召唤的回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
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
		-- ②：场上的这张卡为素材作同调·超量召唤的「斩机」怪兽得到以下效果。●这张卡特殊召唤的回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(17946349,2))  --"「斩机 径武」效果适用中"
end
-- 这个无效效果的发动条件：持有者未被战斗破坏；效果由对方玩家发动；且该连锁效果可以被无效。
function c17946349.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定：效果怪兽不在战斗破坏状态、对方发动效果、且当前连锁的效果能够被无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and Duel.IsChainDisablable(ev)
end
-- 无效效果的发动时点：确认可以发动后，向对方提示选择了该效果，并设置操作信息；同时给自己标记已发动过效果的标志。
function c17946349.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示‘对方选择了要发动无效效果’。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次效果将无效对方发动的那个效果（对象为发动中的连锁中的卡）。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(17946349,3))  --"已发动过效果"
end
-- 效果处理：使对方发动的那个连锁的效果无效。
function c17946349.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效操作，将连锁ev的效果无效。
	Duel.NegateEffect(ev)
end
