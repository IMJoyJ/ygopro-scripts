--ワーム・リンクス
-- 效果：
-- 反转：这张卡在结束阶段时表侧表示存在的场合，自己从卡组抽1张卡。
function c44811425.initial_effect(c)
	-- 反转：这张卡在结束阶段时表侧表示存在的场合，自己从卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c44811425.flipop)
	c:RegisterEffect(e1)
	-- 反转：这张卡在结束阶段时表侧表示存在的场合，自己从卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44811425,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(c44811425.drcon)
	e2:SetTarget(c44811425.drtg)
	e2:SetOperation(c44811425.drop)
	c:RegisterEffect(e2)
end
-- 在卡片翻转时，为该卡片注册一个标记flag，用于后续判断是否满足抽卡条件。
function c44811425.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(44811425,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 判断该卡片是否拥有标记flag，若存在则触发抽卡效果。
function c44811425.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(44811425)~=0
end
-- 设置抽卡效果的目标玩家和抽卡数量，并注册操作信息。
function c44811425.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁操作的目标玩家为效果发动者。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁操作的目标参数为抽卡数量1。
	Duel.SetTargetParam(1)
	-- 设置当前连锁操作为抽卡效果，目标玩家为效果发动者，抽卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡操作，若卡片表侧表示则从卡组抽1张卡。
function c44811425.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁操作的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if e:GetHandler():IsFaceup() then
		-- 让指定玩家从卡组抽指定数量的卡，原因设为效果。
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
