--セキュリティー・ボール
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。把那1只攻击怪兽的表示形式改变。对方的魔法·陷阱卡的效果把盖放的这张卡破坏送去墓地时，选择场上存在的1只怪兽破坏。
function c26533075.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。把那1只攻击怪兽的表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c26533075.condition)
	e1:SetTarget(c26533075.target)
	e1:SetOperation(c26533075.activate)
	c:RegisterEffect(e1)
	-- 对方的魔法·陷阱卡的效果把盖放的这张卡破坏送去墓地时，选择场上存在的1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26533075,0))  --"场上一只怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c26533075.descon)
	e2:SetTarget(c26533075.destg)
	e2:SetOperation(c26533075.desop)
	c:RegisterEffect(e2)
end
-- 此函数为第1效果的发动条件：当前是对方的回合（效果控制者不是回合玩家），确保只在对方怪兽攻击宣言时才能发动。
function c26533075.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回“效果控制者不是当前回合玩家”的布尔值，用于限定只有对方回合才满足条件。
	return tp~=Duel.GetTurnPlayer()
end
-- 此函数为第1效果的发动时选择对象：将攻击宣言的怪兽作为对象，并设置改变表示形式的操作信息。
function c26533075.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前正在攻击宣言的怪兽，作为效果处理的对象候选。
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanChangePosition() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击宣言的怪兽设置为当前连锁的效果对象（广义对象）。
	Duel.SetTargetCard(tg)
	-- 设置操作信息：将改变表示形式的动作登记为“改变表示形式”类别，对象为攻击怪兽，数量为1，供后续连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tg,1,0,0)
end
-- 此函数为第1效果处理时，若对象怪兽仍与效果关联、可以攻击且攻击未被取消，则将其改为表侧守备表示。
function c26533075.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个效果对象，即攻击宣言的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		-- 将对象怪兽的表示形式改变为表侧守备表示，从而使其攻击中止。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
-- 此函数为第2效果的发动条件：这张卡因对方的魔法·陷阱卡的效果被破坏并送去墓地，且破坏前在场上里侧表示。
function c26533075.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0 and rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 此函数为第2效果的发动时选择对象：选择场上存在的1只怪兽作为破坏对象。
function c26533075.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 发动时确认场上（双方怪兽区）存在至少1只可以成为效果对象的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方怪兽区选择1只怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明将破坏所选择的怪兽，破坏类别、对象为所选怪兽、数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 此函数为第2效果处理时，将选择的对象怪兽破坏。
function c26533075.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的效果对象，即被选择要破坏的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以卡片效果的原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
