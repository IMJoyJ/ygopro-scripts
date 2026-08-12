--機皇統制
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「机皇」怪兽为对象才能发动。那只怪兽的攻击力变成自己场上的「机皇」怪兽的原本攻击力合计数值，直到回合结束时那只怪兽的战斗发生的对对方的战斗伤害变成0。
-- ②：自己场上的「机皇」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c66594927.initial_effect(c)
	-- ①：以自己场上1只「机皇」怪兽为对象才能发动。那只怪兽的攻击力变成自己场上的「机皇」怪兽的原本攻击力合计数值，直到回合结束时那只怪兽的战斗发生的对对方的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66594927,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,66594927+EFFECT_COUNT_CODE_OATH)
	-- 设置效果在伤害步骤中只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c66594927.target)
	e1:SetOperation(c66594927.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「机皇」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c66594927.reptg)
	e2:SetValue(c66594927.repval)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「机皇」怪兽
function c66594927.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13)
end
-- 过滤自己场上表侧表示且当前攻击力不等于合计原本攻击力的「机皇」怪兽
function c66594927.filter(c,atk)
	return c66594927.atkfilter(c) and not c:IsAttack(atk)
end
-- 效果①的发动准备，检查场上是否存在符合条件的「机皇」怪兽并进行选择
function c66594927.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上所有表侧表示的「机皇」怪兽
	local g=Duel.GetMatchingGroup(c66594927.atkfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()<=0 then return false end
	local atk=g:GetSum(Card.GetBaseAttack)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c66594927.filter(chkc,atk) end
	-- 在效果发动时，检查自己场上是否存在至少1只攻击力不等于合计原本攻击力的「机皇」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c66594927.filter,tp,LOCATION_MZONE,0,1,nil,atk) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「机皇」怪兽作为效果对象
	Duel.SelectTarget(tp,c66594927.filter,tp,LOCATION_MZONE,0,1,1,nil,atk)
end
-- 效果①的处理，使作为对象的怪兽攻击力变成合计原本攻击力，并使其对对方造成的战斗伤害变成0
function c66594927.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=0
		-- 在效果处理时，重新获取自己场上所有表侧表示的「机皇」怪兽
		local g=Duel.GetMatchingGroup(c66594927.atkfilter,tp,LOCATION_MZONE,0,nil)
		if g:GetCount()>0 then atk=g:GetSum(Card.GetBaseAttack) end
		-- 那只怪兽的攻击力变成自己场上的「机皇」怪兽的原本攻击力合计数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 直到回合结束时那只怪兽的战斗发生的对对方的战斗伤害变成0。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e2:SetCondition(c66594927.damcon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetOwnerPlayer(tp)
		tc:RegisterEffect(e2,true)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e3:SetCondition(c66594927.damcon2)
		e3:SetValue(1)
		tc:RegisterEffect(e3,true)
	end
end
-- 判定是否为该卡控制者（自己）进行攻击或被攻击时产生的战斗伤害
function c66594927.damcon(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 判定是否为对方进行攻击或被攻击时产生的战斗伤害
function c66594927.damcon2(e)
	return 1-e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 过滤自己场上因战斗或效果而被破坏的表侧表示「机皇」怪兽
function c66594927.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x13)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的准备，检查墓地的此卡是否可以除外，以及是否有「机皇」怪兽被破坏
function c66594927.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c66594927.repfilter,1,nil,tp) end
	-- 询问玩家是否使用墓地的此卡代替破坏
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 将墓地的此卡除外
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
-- 用于代替破坏的价值判定，确定被破坏的怪兽是否符合代替条件
function c66594927.repval(e,c)
	return c66594927.repfilter(c,e:GetHandlerPlayer())
end
