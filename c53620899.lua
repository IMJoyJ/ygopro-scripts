--雀姉妹
-- 效果：
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转的场合才能发动。自己从卡组抽1张，那之后选1张手卡丢弃。
function c53620899.initial_effect(c)
	-- ②：这张卡反转的场合才能发动。自己从卡组抽1张，那之后选1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53620899,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c53620899.target)
	e1:SetOperation(c53620899.operation)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53620899,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c53620899.postg)
	e2:SetOperation(c53620899.posop)
	c:RegisterEffect(e2)
end
-- 检查玩家是否可以抽卡并设置连锁操作信息，包括抽卡和丢弃手卡。
function c53620899.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足抽卡条件。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作信息，表示将要进行抽卡效果。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 执行抽卡和丢弃手卡的操作，若抽卡成功则继续处理丢弃手卡。
function c53620899.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功抽卡。
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		-- 将玩家手牌洗切。
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理流程。
		Duel.BreakEffect()
		-- 丢弃玩家1张手卡。
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 检查是否可以将怪兽变为里侧守备表示并注册标志位。
function c53620899.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(53620899)==0 end
	c:RegisterFlagEffect(53620899,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁操作信息，表示将要改变怪兽表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 执行将怪兽变为里侧守备表示的操作。
function c53620899.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
