--EMヒックリカエル
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时交换。
-- 【怪兽效果】
-- ①：自己战斗阶段1次，以自己场上1只怪兽为对象才能发动。那只怪兽的表示形式变更，那个攻击力·守备力直到回合结束时交换。
function c4239451.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时交换。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4239451,0))  --"攻守交换"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c4239451.adtg1)
	e2:SetOperation(c4239451.adop1)
	c:RegisterEffect(e2)
	-- ①：自己战斗阶段1次，以自己场上1只怪兽为对象才能发动。那只怪兽的表示形式变更，那个攻击力·守备力直到回合结束时交换。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4239451,1))  --"攻守交换"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c4239451.adcon2)
	e3:SetTarget(c4239451.adtg2)
	e3:SetOperation(c4239451.adop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选场上表侧表示且守备力大于0的怪兽
function c4239451.filter(c)
	return c:IsFaceup() and c:IsDefenseAbove(0)
end
-- 设置效果目标，选择场上1只表侧表示的怪兽作为效果对象
function c4239451.adtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4239451.filter(chkc) end
	-- 判断是否满足效果发动条件，检查场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c4239451.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c4239451.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数，交换目标怪兽的攻击力和守备力
function c4239451.adop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 创建一个临时改变攻击力的效果，并将其注册到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end
-- 判断效果发动条件，确保当前为自己的战斗阶段且无连锁处理
function c4239451.adcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为效果持有者，且当前阶段为战斗阶段开始到战斗结束之间，且当前无连锁处理
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and Duel.GetCurrentChain()==0
end
-- 设置效果目标，选择自己场上1只守备力大于0的怪兽作为效果对象
function c4239451.adtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsDefenseAbove(0) end
	-- 判断是否满足效果发动条件，检查自己场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefenseAbove,tp,LOCATION_MZONE,0,1,nil,0) end
	-- 向玩家发送提示信息，提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsDefenseAbove,tp,LOCATION_MZONE,0,1,1,nil,0)
end
-- 效果处理函数，变更目标怪兽表示形式并交换其攻击力和守备力
function c4239451.adop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)
		-- 将目标怪兽变为表侧守备表示，并判断是否成功变更
		and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 创建一个临时改变攻击力的效果，并将其注册到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end
