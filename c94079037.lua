--マイン・モール
-- 效果：
-- 这张卡1回合只有1次不会被战斗破坏。这张卡作为兽族怪兽的同调召唤的素材送去墓地的场合，从自己卡组抽1张卡。这张卡因对方的卡的效果从场上离开的场合，从游戏中除外。
function c94079037.initial_effect(c)
	-- 这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c94079037.valcon)
	c:RegisterEffect(e1)
	-- 这张卡作为兽族怪兽的同调召唤的素材送去墓地的场合，从自己卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94079037,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(c94079037.drcon)
	e2:SetTarget(c94079037.drtg)
	e2:SetOperation(c94079037.drop)
	c:RegisterEffect(e2)
	-- 这张卡因对方的卡的效果从场上离开的场合，从游戏中除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(c94079037.rmcon)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
end
-- 判断破坏原因是否为战斗
function c94079037.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 确认此卡是作为兽族怪兽的同调素材送去墓地
function c94079037.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsRace(RACE_BEAST)
end
-- 设置抽卡效果的目标玩家、抽卡数量及操作信息
function c94079037.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为1
	Duel.SetTargetParam(1)
	-- 向系统宣告该连锁包含抽卡操作，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果的具体操作
function c94079037.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中保存的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行因效果让目标玩家抽卡的操作
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 判断此卡是否在场上表侧表示因对方卡的效果离场
function c94079037.rmcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-c:GetControler()
end
