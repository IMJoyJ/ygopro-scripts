--クリア・エフェクター
-- 效果：
-- ①：这张卡作为同调素材送去墓地的场合发动。自己从卡组抽1张。
-- ②：这张卡为同调素材的同调怪兽不会被效果破坏。
function c58518520.initial_effect(c)
	-- ①：这张卡作为同调素材送去墓地的场合发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58518520,0))  --"自己从卡组抽1张"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c58518520.drcon)
	e1:SetTarget(c58518520.drtg)
	e1:SetOperation(c58518520.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡为同调素材的同调怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c58518520.indcon)
	e2:SetOperation(c58518520.indop)
	c:RegisterEffect(e2)
end
-- 检查发动条件：这张卡作为同调素材送去墓地
function c58518520.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 定义抽卡效果的发动目标和操作信息
function c58518520.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己（tp）
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家tp从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果的具体处理
function c58518520.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 检查是否作为同调素材
function c58518520.indcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 为同调召唤出的怪兽注册不会被效果破坏的效果
function c58518520.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58518520,1))  --"「净化施效者」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
