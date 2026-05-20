--氷結界の番人 ブリズド
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合发动。自己抽1张。
function c60161788.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地的场合发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60161788,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c60161788.condition)
	e1:SetTarget(c60161788.target)
	e1:SetOperation(c60161788.operation)
	c:RegisterEffect(e1)
end
-- 确认这张卡是否在墓地，且是否因战斗而被破坏
function c60161788.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 设置抽卡效果的对象玩家和抽卡数量，并声明抽卡的操作信息
function c60161788.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果，获取之前设定的玩家和张数并进行抽卡
function c60161788.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
