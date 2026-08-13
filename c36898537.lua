--メタファイズ・ホルス・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤成功的场合，那些作为同调素材的除调整以外的怪兽种类的以下效果各能发动。
-- ●通常怪兽：这个回合这张卡不受自身以外的卡的效果影响。
-- ●效果怪兽：以这张卡以外的场上1张表侧表示的卡为对象才能发动。那个效果无效。
-- ●灵摆怪兽：对方场上1只怪兽由对方选出，自己得到那个控制权。这个回合那只怪兽不能攻击。
function c36898537.initial_effect(c)
	-- 为这张卡注册同调召唤手续：调整怪兽1只 + 调整以外的怪兽1只以上（不限定具体条件）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 那些作为同调素材的除调整以外的怪兽种类
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c36898537.valcheck)
	c:RegisterEffect(e1)
	-- ●通常怪兽：这个回合这张卡不受自身以外的卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36898537,0))  --"效果耐性"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c36898537.immcon)
	e2:SetOperation(c36898537.immop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ●效果怪兽：以这张卡以外的场上1张表侧表示的卡为对象才能发动。那个效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36898537,1))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(c36898537.negcon)
	e3:SetTarget(c36898537.negtg)
	e3:SetOperation(c36898537.negop)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
	-- ●灵摆怪兽：对方场上1只怪兽由对方选出，自己得到那个控制权。这个回合那只怪兽不能攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(36898537,2))  --"得到控制权"
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c36898537.ctcon)
	e4:SetTarget(c36898537.cttg)
	e4:SetOperation(c36898537.ctop)
	e4:SetLabelObject(e1)
	c:RegisterEffect(e4)
end
-- 遍历同调素材，将除调整以外的怪兽的类型标志（通常/效果/灵摆等）按位或后存入效果的label，作为后续判断素材种类的依据。
function c36898537.valcheck(e,c)
	local g=c:GetMaterial()
	local tpe=0
	local tc=g:GetFirst()
	while tc do
		if not tc:IsSynchroType(TYPE_TUNER) then
			tpe=bit.bor(tpe,tc:GetSynchroType())
		end
		tc=g:GetNext()
	end
	e:SetLabel(tpe)
end
-- 判定通常怪兽分支的发动条件：这张卡同调召唤成功，且作为素材的除调整怪兽外包含通常怪兽。
function c36898537.immcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		and bit.band(e:GetLabelObject():GetLabel(),TYPE_NORMAL)~=0
end
-- 若这张卡仍表侧且与效果关联，则给它赋予本回合内不受其他卡效果影响的免疫效果，持续到回合结束。
function c36898537.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这个回合这张卡不受自身以外的卡的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c36898537.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 免疫过滤条件：只免疫由这张卡以外的卡发动的效果。
function c36898537.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 判定效果怪兽分支的发动条件：这张卡同调召唤成功，且素材中除调整外包含效果怪兽。
function c36898537.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		and bit.band(e:GetLabelObject():GetLabel(),TYPE_EFFECT)~=0
end
-- 筛选场上表侧表示且不是通常怪兽的卡（即有效果的卡）作为可无效的对象。
function c36898537.negfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_NORMAL)
end
-- 取对象效果的目标处理：检查场上是否有本卡以外表侧表示且非通常怪兽的卡，若有则选择1张作为对象，并设置无效该卡的操作信息。
function c36898537.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c36898537.negfilter(chkc) end
	-- 确认场上是否存在至少1张满足条件的表侧表示非通常怪兽且不是本卡的卡，以决定是否能发动。
	if chk==0 then return Duel.IsExistingTarget(c36898537.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择1张表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从符合条件的表侧表示非通常怪兽卡中选择1张作为效果对象，并自动登记为对象。
	local g=Duel.SelectTarget(tp,c36898537.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置本次连锁的操作信息：将选择的卡设为无效效果的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理时，若对象仍表侧且与效果关联，则给它赋予“怪兽效果无效”和“效果无效化”两个无效状态，使那张卡的效果无效。
function c36898537.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发起时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那个效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那个效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 判定灵摆怪兽分支的发动条件：这张卡同调召唤成功，且素材中除调整外包含灵摆怪兽。
function c36898537.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		and bit.band(e:GetLabelObject():GetLabel(),TYPE_PENDULUM)~=0
end
-- 目标处理：确认对方场上有可改变控制权的怪兽，并设置改变控制权且数量为1的操作信息（具体对象由对方在处理时选择）。
function c36898537.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认对方场上是否存在至少1只控制权可以被改变的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置本次连锁的操作信息为改变控制权，数量1，且对象不预先确定（处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
-- 效果处理：由对方选择1只其场上的怪兽，若成功获得其控制权，则给该怪兽附加“不能攻击”的效果直到回合结束。
function c36898537.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示对方玩家选择1只要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 由对方从其场上选择1只可以被改变控制权的怪兽（不取对象，由对方选出）。
	local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToChangeControler,1-tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 尝试获得所选怪兽的控制权，若成功（返回值非0）则继续处理。
	if Duel.GetControl(tc,tp)~=0 then
		-- 这个回合那只怪兽不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
