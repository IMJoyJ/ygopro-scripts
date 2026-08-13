--ゴブリン陽動部隊
-- 效果：
-- 这张卡给与对方基本分战斗伤害时，可以从自己卡组抽1张卡。这张卡攻击的场合，战斗阶段结束时变成守备表示，直到下次的自己回合的结束阶段时不能把表示形式改变。
function c18960169.initial_effect(c)
	-- 这张卡给与对方基本分战斗伤害时，可以从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18960169,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c18960169.condition)
	e1:SetTarget(c18960169.target)
	e1:SetOperation(c18960169.operation)
	c:RegisterEffect(e1)
	-- 这张卡攻击的场合，战斗阶段结束时变成守备表示，直到下次的自己回合的结束阶段时不能把表示形式改变。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c18960169.poscon)
	e2:SetOperation(c18960169.posop)
	c:RegisterEffect(e2)
end
-- 判定本次战斗伤害的对象是否为对方玩家，即“给与对方基本分战斗伤害时”的触发条件。
function c18960169.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 抽卡效果发动前的处理：确认符合发动时点、设置对象玩家与抽卡参数，并登记操作信息。
function c18960169.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：当前玩家是否能够抽1张卡，若不能则不能发动本效果。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本连锁的对象玩家设置为效果发动者tp，也就是抽卡玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置本连锁的对象参数为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 将当前连锁登记为抽卡效果（CATEGORY_DRAW），供后续相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理阶段：从连锁信息中取出玩家与抽卡数量，执行抽卡操作。
function c18960169.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁保存的对象玩家和对象参数，即抽卡玩家与抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，完成实际抽卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 判定条件：这张卡本回合攻击过（攻击次数大于0），满足“这张卡攻击的场合”。
function c18960169.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 战斗阶段结束时，将这张卡变更为表侧守备表示，并附加直到下次自己回合结束阶段不能改变表示形式的限制效果。
function c18960169.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡从当前表示形式变更为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 直到下次的自己回合的结束阶段时不能把表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
	c:RegisterEffect(e1)
end
