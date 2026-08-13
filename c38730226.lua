--英知の代行者 マーキュリー
-- 效果：
-- ①：对方回合结束时，这张卡在自己的怪兽区域表侧表示存在，自己手卡是0张的场合，下次的自己准备阶段发动。自己从卡组抽1张。
function c38730226.initial_effect(c)
	-- ①：对方回合结束时，这张卡在自己的怪兽区域表侧表示存在，自己手卡是0张的场合，下次的自己准备阶段发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c38730226.con)
	e1:SetOperation(c38730226.op)
	c:RegisterEffect(e1)
end
-- 该效果在对方回合结束阶段进行条件判断：当前回合玩家不是本卡控制者（即对方回合），且控制者的手牌数量为0。
function c38730226.con(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是tp且tp手牌数为0，对应原效果'对方回合结束时...自己手卡是0张的场合'的条件。
	return Duel.GetTurnPlayer()~=tp and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 条件满足后，为这张卡注册一个在下次自己准备阶段发动的抽卡效果，以实现延迟发动。
function c38730226.op(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的自己准备阶段发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(38730226,0))  --"下一个准备阶段时抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c38730226.dtg)
	e1:SetOperation(c38730226.dop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY)
	e:GetHandler():RegisterEffect(e1)
end
-- 设定延迟抽卡效果的目标：以本卡控制者为对象玩家，并声明抽卡数量为1。
function c38730226.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为tp（自己），表示抽卡效果影响的是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息，声明该效果会执行抽卡，抽卡玩家为tp，从卡组抽1张（目标为卡组，因不取对象所以targets传nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡操作：从连锁信息中取出对象玩家和抽卡数量，让该玩家抽对应数量的卡。
function c38730226.dop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和对象参数，分别赋值给p和d，用于后续抽卡。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，实现'自己从卡组抽1张'。
	Duel.Draw(p,d,REASON_EFFECT)
end
