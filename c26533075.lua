--セキュリティー・ボール
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。把那1只攻击怪兽的表示形式改变。对方的魔法·陷阱卡的效果把盖放的这张卡破坏送去墓地时，选择场上存在的1只怪兽破坏。
function c26533075.initial_effect(c)
	-- 创建一个永续效果，当对方怪兽攻击宣言时发动，将攻击怪兽变为守备表示
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c26533075.condition)
	e1:SetTarget(c26533075.target)
	e1:SetOperation(c26533075.activate)
	c:RegisterEffect(e1)
	-- 创建一个诱发效果，当此卡因对方魔法·陷阱卡的效果被破坏送去墓地时发动，选择场上一只怪兽破坏
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
-- 效果发动条件：当前回合玩家不是攻击怪兽的控制者
function c26533075.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家是否为攻击怪兽的控制者，若不是则满足条件
	return tp~=Duel.GetTurnPlayer()
end
-- 设置效果目标为攻击怪兽，并设定操作信息为改变表示形式
function c26533075.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击怪兽作为目标
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanChangePosition() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为连锁处理的目标
	Duel.SetTargetCard(tg)
	-- 设置操作信息为改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tg,1,0,0)
end
-- 效果处理函数：将目标怪兽变为守备表示
function c26533075.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		-- 将目标怪兽变为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
-- 破坏时的触发条件：被对方魔法·陷阱卡破坏且此卡原本在场上且为里侧表示
function c26533075.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)~=0 and rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 设置破坏效果的目标为场上任意一只怪兽
function c26533075.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 判断场上是否存在至少一只可以成为目标的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一只怪兽作为破坏目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理函数：将目标怪兽破坏
function c26533075.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
