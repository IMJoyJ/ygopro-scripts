--デプス・アミュレット
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。把1张手卡丢弃去墓地，让1只对方怪兽的攻击无效。这张卡在发动后第3次的对方的结束阶段时破坏。
function c8279188.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。把1张手卡丢弃去墓地，让1只对方怪兽的攻击无效。这张卡在发动后第3次的对方的结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c8279188.target1)
	e1:SetOperation(c8279188.activate)
	c:RegisterEffect(e1)
	-- 对方怪兽的攻击宣言时才能发动。把1张手卡丢弃去墓地，让1只对方怪兽的攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8279188,1))  --"攻击无效"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(c8279188.condition)
	e2:SetTarget(c8279188.target2)
	e2:SetOperation(c8279188.activate)
	c:RegisterEffect(e2)
end
-- 检查是否满足效果发动条件（对方怪兽的攻击宣言时）
function c8279188.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return tp~=Duel.GetTurnPlayer()
end
-- 卡片发动时的效果处理，注册自毁效果，并判断是否在发动卡片的同时直接发动无效攻击的效果
function c8279188.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前宣告攻击的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return true end
	e:GetHandler():SetTurnCounter(0)
	-- 这张卡在发动后第3次的对方的结束阶段时破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c8279188.descon)
	e1:SetOperation(c8279188.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	e:GetHandler():RegisterEffect(e1)
	-- 检查当前是否是对方怪兽的攻击宣言时，且该怪兽在场上并能成为效果对象
	if Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and tp~=Duel.GetTurnPlayer() and tg:IsOnField() and tg:IsCanBeEffectTarget(e)
		-- 检查手牌数量是否不为0，并询问玩家是否在卡片发动时直接发动无效攻击的效果
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0 and Duel.SelectYesNo(tp,aux.Stringid(8279188,0)) then  --"是否现在使用「深渊护符」的效果？"
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 将攻击怪兽设为效果的对象
		Duel.SetTargetCard(tg)
	else e:SetProperty(0) end
end
-- 已在场上表侧表示存在的此卡发动效果时的对象选择与可行性检查
function c8279188.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前宣告攻击的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检查手牌数量是否不为0，且攻击怪兽在场上并能成为效果对象
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0 and tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设为效果的对象
	Duel.SetTargetCard(tg)
end
-- 无效攻击效果的实际处理函数
function c8279188.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的攻击怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用此效果、是否表侧表示，以及自身手牌是否不为0
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0 then
		-- 从手牌中选择1张卡丢弃去墓地
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)
		-- 无效此次攻击
		Duel.NegateAttack()
	end
end
-- 自毁效果的触发条件判断（对方回合的结束阶段）
function c8279188.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 自毁效果的实际处理，每次对方结束阶段使计数器加1，达到3次时破坏此卡
function c8279188.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 将此卡破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
