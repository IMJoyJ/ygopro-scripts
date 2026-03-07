--グリード・グラード
-- 效果：
-- 自己把对方场上表侧表示存在的同调怪兽战斗或者卡的效果破坏的回合才能发动。从自己卡组抽2张卡。
function c3972721.initial_effect(c)
	-- 效果原文：自己把对方场上表侧表示存在的同调怪兽战斗或者卡的效果破坏的回合才能发动。从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCondition(c3972721.condition)
	e1:SetTarget(c3972721.target)
	e1:SetOperation(c3972721.activate)
	c:RegisterEffect(e1)
	if not c3972721.global_check then
		c3972721.global_check=true
		-- 效果原文：自己把对方场上表侧表示存在的同调怪兽战斗或者卡的效果破坏的回合才能发动。从自己卡组抽2张卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(c3972721.checkop)
		-- 将效果注册到全局环境，使该效果在场上的所有卡状态变化时触发
		Duel.RegisterEffect(ge1,0)
	end
end
-- 遍历被破坏的卡片，判断是否满足条件（同调怪兽、在主要怪兽区被破坏、是正面表示、破坏者与原控制者不同）
function c3972721.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	while tc do
		if tc:IsType(TYPE_SYNCHRO) and tc:IsPreviousLocation(LOCATION_MZONE)
			and ((tc:IsReason(REASON_BATTLE) and bit.band(tc:GetBattlePosition(),POS_FACEUP)~=0)
			or (not tc:IsReason(REASON_BATTLE) and tc:IsPreviousPosition(POS_FACEUP)))
			and tc:GetPreviousControler()~=tc:GetReasonPlayer() then
			if tc:GetReasonPlayer()==0 then p1=true else p2=true end
		end
		tc=eg:GetNext()
	end
	-- 若满足条件的卡片属于玩家0，则为玩家0注册标识效果
	if p1 then Duel.RegisterFlagEffect(0,3972721,RESET_PHASE+PHASE_END,0,1) end
	-- 若满足条件的卡片属于玩家1，则为玩家1注册标识效果
	if p2 then Duel.RegisterFlagEffect(1,3972721,RESET_PHASE+PHASE_END,0,1) end
end
-- 效果原文：自己把对方场上表侧表示存在的同调怪兽战斗或者卡的效果破坏的回合才能发动。从自己卡组抽2张卡。
function c3972721.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否拥有标识效果，用于判断是否满足发动条件
	return Duel.GetFlagEffect(tp,3972721)~=0
end
-- 效果原文：自己把对方场上表侧表示存在的同调怪兽战斗或者卡的效果破坏的回合才能发动。从自己卡组抽2张卡。
function c3972721.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁的目标玩家为当前处理的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的目标参数为2
	Duel.SetTargetParam(2)
	-- 设置连锁的操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果原文：自己把对方场上表侧表示存在的同调怪兽战斗或者卡的效果破坏的回合才能发动。从自己卡组抽2张卡。
function c3972721.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家以效果原因抽目标数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
