--Vain－裏切りの嘲笑
-- 效果：
-- 对方场上的超量怪兽攻击宣言时，选择那1只怪兽才能发动。选择的怪兽不能攻击，效果无效化。只要选择的怪兽在场上存在，每次对方的结束阶段从对方卡组上面把3张卡送去墓地。选择的怪兽从场上离开时，这张卡破坏。
function c94933468.initial_effect(c)
	-- 对方场上的超量怪兽攻击宣言时，选择那1只怪兽才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c94933468.target)
	e1:SetOperation(c94933468.operation)
	c:RegisterEffect(e1)
	-- 选择的怪兽从场上离开时，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c94933468.descon)
	e2:SetOperation(c94933468.desop)
	c:RegisterEffect(e2)
	-- 只要选择的怪兽在场上存在，每次对方的结束阶段从对方卡组上面把3张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94933468,0))  --"卡组破坏"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c94933468.deckcon)
	e3:SetTarget(c94933468.decktg)
	e3:SetOperation(c94933468.deckop)
	c:RegisterEffect(e3)
	-- 效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e5)
end
-- 检查发动条件，并将进行攻击宣言的对方超量怪兽作为效果的对象。
function c94933468.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	if chkc then return false end
	if chk==0 then return at:IsControler(1-tp) and at:IsType(TYPE_XYZ) and at:IsOnField() and at:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设为当前效果的处理对象。
	Duel.SetTargetCard(at)
	-- 设置操作信息，表示该效果包含使该怪兽效果无效的操作。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,at,1,0,0)
end
-- 效果处理时，将此卡与作为对象的怪兽建立持续的靶向关系。
function c94933468.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 检查离场的怪兽是否是此卡当前选择的对象，且此卡未处于预定破坏状态。
function c94933468.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 执行破坏此卡的操作。
function c94933468.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将此卡破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 检查当前是否为对方的回合，且此卡当前存在选择的对象。
function c94933468.deckcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方，且此卡当前存在选择的对象。
	return tp~=Duel.GetTurnPlayer() and e:GetHandler():GetFirstCardTarget()~=nil
end
-- 结束阶段卡组破坏效果的靶向处理，设置送去墓地的操作信息。
function c94933468.decktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将对方卡组最上方的3张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,3)
end
-- 结束阶段卡组破坏效果的实际处理，将对方卡组最上方的3张卡送去墓地。
function c94933468.deckop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 将对方卡组最上方的3张卡送去墓地。
	Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
end
