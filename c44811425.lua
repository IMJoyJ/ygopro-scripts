--ワーム・リンクス
-- 效果：
-- 反转：这张卡在结束阶段时表侧表示存在的场合，自己从卡组抽1张卡。
function c44811425.initial_effect(c)
	-- 反转：
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c44811425.flipop)
	c:RegisterEffect(e1)
	-- 这张卡在结束阶段时表侧表示存在的场合，自己从卡组抽1张卡。
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
-- 翻转时给这张卡自身注册一个标识效果（44811425），标记该卡本回合/本次在场期间发生过反转，后续结束阶段条件判断用。
function c44811425.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(44811425,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 判定条件：检查这张卡是否带有“已反转”的标识效果（44811425），有则满足结束阶段抽卡效果的发动条件。
function c44811425.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(44811425)~=0
end
-- 效果发动时的目标处理：无需选择对象；将对象玩家设为效果发动者，将对象参数设为1（抽卡张数），并设置操作信息为抽卡。
function c44811425.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为tp（效果发动者），即由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息：该效果属于抽卡效果，预定的目标玩家为tp，预计抽1张卡，不取对象。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从连锁信息中取出抽卡玩家和抽卡张数，若这张卡仍表侧表示，则执行抽卡。
function c44811425.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家p和对象参数d，即抽卡玩家与抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if e:GetHandler():IsFaceup() then
		-- 让玩家p以“效果”为原因抽取d张卡。
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
