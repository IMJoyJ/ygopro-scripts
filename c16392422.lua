--トゥーン・仮面魔道士
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤的回合不能攻击。场上的「卡通世界」被破坏时这张卡也破坏。自己场上有「卡通世界」且对方不控制卡通的场合，这张卡可以直接攻击对方玩家。这张卡造成对方伤害时，这张卡的持有者抽1张卡。
function c16392422.initial_effect(c)
	-- 记录该卡具有「卡通世界」这张卡的卡片密码
	aux.AddCodeList(c,15259703)
	-- 这张卡召唤·反转召唤·特殊召唤的回合不能攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c16392422.atklimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 场上的「卡通世界」被破坏时这张卡也破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c16392422.sdescon)
	e4:SetOperation(c16392422.sdesop)
	c:RegisterEffect(e4)
	-- 自己场上有「卡通世界」且对方不控制卡通的场合，这张卡可以直接攻击对方玩家
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(c16392422.dircon)
	c:RegisterEffect(e5)
	-- 这张卡造成对方伤害时，这张卡的持有者抽1张卡
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(16392422,0))  --"抽卡"
	e6:SetCategory(CATEGORY_DRAW)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_BATTLE_DAMAGE)
	e6:SetCondition(c16392422.condition)
	e6:SetTarget(c16392422.target)
	e6:SetOperation(c16392422.operation)
	c:RegisterEffect(e6)
end
-- 创建一个使该卡在召唤·反转召唤·特殊召唤的回合不能攻击的效果
function c16392422.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 设置该效果为永续型且在回合结束时重置
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤函数，用于判断离场的卡是否为正面表示破坏且原卡名为「卡通世界」
function c16392422.sfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 判断离场的卡中是否存在满足sfilter条件的卡
function c16392422.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16392422.sfilter,1,nil)
end
-- 将该卡以效果原因破坏
function c16392422.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏该卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 过滤函数，用于判断自己场上是否存在正面表示的「卡通世界」
function c16392422.dirfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤函数，用于判断自己场上是否存在正面表示的卡通怪兽
function c16392422.dirfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 判断是否满足直接攻击条件：自己场上存在「卡通世界」且对方场上不存在卡通怪兽
function c16392422.dircon(e)
	-- 判断自己场上是否存在正面表示的「卡通世界」
	return Duel.IsExistingMatchingCard(c16392422.dirfilter1,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
		-- 判断对方场上是否存在正面表示的卡通怪兽
		and not Duel.IsExistingMatchingCard(c16392422.dirfilter2,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 判断造成战斗伤害的玩家是否为对方
function c16392422.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 设置抽卡效果的目标玩家和抽卡数量
function c16392422.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置效果的操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果，从当前玩家的牌组抽1张卡
function c16392422.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从其牌组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
