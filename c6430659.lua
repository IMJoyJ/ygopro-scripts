--ウィルスメール
-- 效果：
-- 1回合1次，选择自己场上表侧表示存在的1只4星以下的怪兽才能发动。这个回合，选择的怪兽可以直接攻击对方玩家。那只怪兽在战斗阶段结束时送去墓地。
function c6430659.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，选择自己场上表侧表示存在的1只4星以下的怪兽才能发动。这个回合，选择的怪兽可以直接攻击对方玩家。那只怪兽在战斗阶段结束时送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6430659,0))  --"直接攻击"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c6430659.atcon)
	e2:SetTarget(c6430659.attg)
	e2:SetOperation(c6430659.atop)
	c:RegisterEffect(e2)
end
-- 判定效果发动条件：当前回合玩家能否进入战斗阶段。
function c6430659.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段（若不能进入战斗阶段，则无法发动此效果）。
	return Duel.IsAbleToEnterBP()
end
-- 过滤条件：自己场上表侧表示、4星以下、可以攻击、且未拥有直接攻击或无法直接攻击效果的怪兽。
function c6430659.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsAttackable()
		and not c:IsHasEffect(EFFECT_DIRECT_ATTACK) and not c:IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK)
end
-- 效果发动时的目标选择：选择1只符合条件的怪兽作为效果对象。
function c6430659.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c6430659.filter(chkc) end
	-- 检查场上是否存在至少1只符合条件的怪兽作为可选对象。
	if chk==0 then return Duel.IsExistingTarget(c6430659.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息：请选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只符合条件的怪兽并将其作为效果对象。
	Duel.SelectTarget(tp,c6430659.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使选择的怪兽在这个回合可以直接攻击，并注册一个在战斗阶段结束时将其送去墓地的效果。
function c6430659.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果处理的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这个回合，选择的怪兽可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetCondition(c6430659.dircon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(6430659,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 那只怪兽在战斗阶段结束时送去墓地。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCountLimit(1)
		e2:SetLabelObject(tc)
		e2:SetCondition(c6430659.tgcon)
		e2:SetOperation(c6430659.tgop)
		-- 注册全局延迟效果，用于在战斗阶段结束时将目标怪兽送去墓地。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判定直接攻击效果的适用条件：该怪兽的控制者必须是效果的发动者。
function c6430659.dircon(e)
	return e:GetHandler():GetControler()==e:GetOwnerPlayer()
end
-- 判定送去墓地效果的发动条件：目标怪兽身上仍带有此效果的标记（未离场或改变状态），否则重置此效果。
function c6430659.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(6430659)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 执行送去墓地的操作。
function c6430659.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 用效果将目标怪兽送去墓地。
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
