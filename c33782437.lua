--一時休戦
-- 效果：
-- ①：双方玩家各自从卡组抽1张。直到下次的对方回合结束时，双方受到的全部伤害变成0。
function c33782437.initial_effect(c)
	-- ①：双方玩家各自从卡组抽1张。直到下次的对方回合结束时，双方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c33782437.target)
	e1:SetOperation(c33782437.activate)
	c:RegisterEffect(e1)
end
-- 作为效果发动时的合法性与目标检查函数：判断双方玩家是否都能抽1张卡，若满足则设定操作信息，以便后续效果处理时执行抽卡。
function c33782437.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查双方玩家是否各能抽1张卡，只要有一方不能抽卡则效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 将本次连锁效果的操作信息设定为“双方玩家各抽1张卡”（分类为抽卡，对象为双方玩家，数量为1），用于效果处理、连锁判定及相关卡片的对应。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 效果处理时让双方玩家各抽1张卡；若双方都成功抽卡，则为双方附加“受到的全部伤害变成0”的持续效果，持续到下次对方回合结束。
function c33782437.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让发动玩家以效果原因从卡组抽1张卡，返回实际抽到的卡数。
	local d1=Duel.Draw(tp,1,REASON_EFFECT)
	-- 让对方玩家以效果原因从卡组抽1张卡，返回实际抽到的卡数。
	local d2=Duel.Draw(1-tp,1,REASON_EFFECT)
	if d1==0 or d2==0 then return end
	-- 直到下次的对方回合结束时，双方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将改变伤害数值为0的永续效果注册给当前玩家，使其影响双方玩家（EFFECT_FLAG_PLAYER_TARGET），持续2个结束阶段后重置。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将复制出的“效果伤害无效化”标记效果注册给当前玩家，用于表示效果伤害已被降为0的状态，同样持续2个结束阶段后重置。
	Duel.RegisterEffect(e2,tp)
end
