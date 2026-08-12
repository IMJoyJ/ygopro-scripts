--サイバーデーモン
-- 效果：
-- 自己的抽卡阶段开始时，若自己手卡为0张的场合，经过通常抽卡后可以再抽1张。自己的结束阶段时手卡有1张以上的场合，这张卡破坏。
function c59907935.initial_effect(c)
	-- 自己的抽卡阶段开始时，若自己手卡为0张的场合
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	ge1:SetOperation(c59907935.drchk)
	-- 把全局环境下的抽卡阶段开始时手卡数量检测效果注册给全局环境
	Duel.RegisterEffect(ge1,0)
	-- 经过通常抽卡后可以再抽1张
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59907935,0))  --"抽卡"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c59907935.drcon)
	e1:SetTarget(c59907935.drtg)
	e1:SetOperation(c59907935.drop)
	c:RegisterEffect(e1)
	-- 自己的结束阶段时手卡有1张以上的场合，这张卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59907935,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(c59907935.descon)
	e2:SetTarget(c59907935.destg)
	e2:SetOperation(c59907935.desop)
	c:RegisterEffect(e2)
end
-- 抽卡阶段开始时检测手卡数量的函数
function c59907935.drchk(e,tp,eg,ep,ev,re,r,rp,c)
	-- 判断当前回合玩家的手卡数量是否为0
	if Duel.GetFieldGroupCount(ep,LOCATION_HAND,0)==0 then
		-- 为当前回合玩家注册标识效果，持续到回合结束
		Duel.RegisterFlagEffect(ep,59907935,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 再抽1张卡效果的发动条件
function c59907935.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否已注册手卡为0的标识、是否为自己抽卡且该抽卡为规则抽卡（通常抽卡）
	return Duel.GetFlagEffect(ep,59907935)~=0 and ep==tp and r&REASON_RULE==REASON_RULE
end
-- 再抽1张卡效果的发动准备（设置对象与操作信息）
function c59907935.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前效果的对象参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置效果处理的操作信息为玩家tp抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 再抽1张卡效果的执行函数
function c59907935.drop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取当前连锁的对象玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 自身破坏效果的发动条件
function c59907935.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的回合且自己的手卡在1张以上
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
end
-- 自身破坏效果的发动准备（设置操作信息）
function c59907935.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的操作信息为破坏这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 自身破坏效果的执行函数
function c59907935.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 因效果破坏这张卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
