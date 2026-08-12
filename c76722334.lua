--カプシェル
-- 效果：
-- 这个卡名的①②③的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡被解放的场合才能发动。自己抽1张。
-- ②：这张卡成为融合·同调·连接召唤的素材，被送去墓地的场合或者被除外的场合才能发动。自己抽1张。
-- ③：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。自己抽1张。
function c76722334.initial_effect(c)
	-- ①：这张卡被解放的场合才能发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76722334,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_RELEASE)
	e1:SetCountLimit(1,76722334)
	e1:SetTarget(c76722334.drtg)
	e1:SetOperation(c76722334.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c76722334.drcon1)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c76722334.drcon2)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EVENT_REMOVE)
	e4:SetCondition(c76722334.drcon2)
	c:RegisterEffect(e4)
end
-- 判断是否作为融合·同调·连接召唤的素材而被送去墓地或除外
function c76722334.drcon1(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_FUSION+REASON_SYNCHRO+REASON_LINK)~=0 and not e:GetHandler():IsReason(REASON_RETURN)
end
-- 判断作为超量素材的这张卡是否为发动超量怪兽的效果而被取除并送去墓地或除外
function c76722334.drcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 抽卡效果的目标判断与操作信息设置
function c76722334.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家当前是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡张数为1
	Duel.SetTargetParam(1)
	-- 设置操作信息为：让玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的具体操作：让目标玩家抽1张卡
function c76722334.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标玩家和抽卡张数参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
