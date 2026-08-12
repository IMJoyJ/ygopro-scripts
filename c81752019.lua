--花札衛－松－
-- 效果：
-- 「花札卫-松-」的①的效果1回合只能使用1次。
-- ①：这张卡召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽以外的场合，那张卡送去墓地。
-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。自己从卡组抽1张。
function c81752019.initial_effect(c)
	-- 「花札卫-松-」的①的效果1回合只能使用1次。①：这张卡召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽以外的场合，那张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,81752019)
	e1:SetTarget(c81752019.drtg1)
	e1:SetOperation(c81752019.drop1)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(c81752019.drcon2)
	e2:SetTarget(c81752019.drtg2)
	e2:SetOperation(c81752019.drop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备：因为是必发效果，直接返回true，并设置抽卡相关的操作信息
function c81752019.drtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 注册当前连锁的操作信息：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果的效果处理：执行抽卡，给对方确认，若不是「花札卫」怪兽则送去墓地，最后洗牌
function c81752019.drop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，若实际抽卡张数为0则结束处理
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	-- 获取刚刚通过抽卡操作加入手牌的卡片
	local tc=Duel.GetOperatedGroup():GetFirst()
	-- 给对方玩家确认抽到的卡片
	Duel.ConfirmCards(1-tp,tc)
	if not (tc:IsSetCard(0xe6) and tc:IsType(TYPE_MONSTER)) then
		-- 将该卡片送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
end
-- ②效果的发动条件：这张卡被战斗破坏送去墓地，或者在自己场上被对方的效果破坏送去墓地
function c81752019.drcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
end
-- ②效果的发动准备：确认自己是否可以抽卡，并设置抽卡相关的操作信息
function c81752019.drtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：若为发动检查，则判断自己当前是否可以执行抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 注册当前连锁的操作信息：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的效果处理：获取设定的参数并执行抽卡
function c81752019.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
