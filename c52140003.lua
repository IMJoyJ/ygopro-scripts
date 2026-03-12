--爆弾ウニ－ボム・アーチン－
-- 效果：
-- 对方把陷阱卡发动时才能发动。自己的准备阶段时，对方场上有陷阱卡表侧表示存在的场合，给与对方基本分1000分伤害。发动后第3次的自己的结束阶段时这张卡送去墓地。
function c52140003.initial_effect(c)
	-- 发动条件：对方把陷阱卡发动时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c52140003.condition)
	e1:SetTarget(c52140003.target)
	c:RegisterEffect(e1)
	-- 效果发动后第3次的自己的结束阶段时这张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52140003,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c52140003.damcon)
	e2:SetTarget(c52140003.damtg)
	e2:SetOperation(c52140003.damop)
	c:RegisterEffect(e2)
end
-- 效果发动时的条件判断，确保是对方发动的陷阱卡且为表侧表示。
function c52140003.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==1-tp
end
-- 设置连锁处理后的触发效果，用于记录发动次数并决定何时将卡送入墓地。
function c52140003.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 用于记录发动次数的效果，在每次结束阶段时增加计数器。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c52140003.tgcon)
	e1:SetOperation(c52140003.tgop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	c:SetTurnCounter(0)
end
-- 过滤函数：检查场上是否有表侧表示的陷阱卡。
function c52140003.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP)
end
-- 伤害效果触发条件：在自己的准备阶段且对方场上有陷阱卡存在时触发。
function c52140003.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为使用者，以及对方场地上是否存在陷阱卡。
	return tp==Duel.GetTurnPlayer() and Duel.IsExistingMatchingCard(c52140003.cfilter,tp,0,LOCATION_ONFIELD,1,nil)
end
-- 设置伤害效果的目标玩家和伤害值。
function c52140003.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的伤害值为1000。
	Duel.SetTargetParam(1000)
	-- 设置操作信息，表明本次效果将造成1000点伤害给对方。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 执行伤害效果的操作函数。
function c52140003.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 若对方场上不存在陷阱卡则不执行伤害效果。
	if not Duel.IsExistingMatchingCard(c52140003.cfilter,tp,0,LOCATION_ONFIELD,1,nil) then return end
	-- 获取连锁中设定的目标玩家和目标参数（即伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定的伤害值。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判断是否为使用者的回合，用于触发结束阶段计数器增加。
function c52140003.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家等于效果持有者时触发。
	return Duel.GetTurnPlayer()==tp
end
-- 处理发动次数计数器增加及墓地送卡逻辑。
function c52140003.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	c:SetTurnCounter(ct+1)
	if ct+1>=3 then
		-- 将自身送去墓地
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
