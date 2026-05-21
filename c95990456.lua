--陰魔羅鬼
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被对方的效果破坏送去墓地的场合或者从墓地的特殊召唤成功的场合才能发动。自己从卡组抽1张。
function c95990456.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡被对方的效果破坏送去墓地的场合才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,95990456)
	e1:SetCondition(c95990456.drcon1)
	e1:SetTarget(c95990456.drtg)
	e1:SetOperation(c95990456.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c95990456.drcon2)
	c:RegisterEffect(e2)
end
-- 检测此卡是否在自己场上被对方的效果破坏并送去墓地
function c95990456.drcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY)
		and c:IsReason(REASON_EFFECT) and rp==1-tp
end
-- 检测此卡是否是从墓地特殊召唤成功
function c95990456.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- 抽卡效果的发动准备，确认玩家是否可以抽卡，并设置抽卡的目标玩家、张数和操作信息
function c95990456.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检测自己是否可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数（抽卡张数）设置为1
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为“让玩家tp抽1张卡”
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的处理，获取目标玩家和抽卡张数并执行抽卡
function c95990456.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
