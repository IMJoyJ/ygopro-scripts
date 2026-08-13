--フリック・クラウン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上有这张卡以外的电子界族怪兽2只以上存在，自己手卡是0张的场合，支付1000基本分才能发动。自己从卡组抽1张。
function c209710.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：自己场上有这张卡以外的电子界族怪兽2只以上存在，自己手卡是0张的场合，支付1000基本分才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(209710,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,209710)
	e1:SetCondition(c209710.drcon)
	e1:SetCost(c209710.drcost)
	e1:SetTarget(c209710.drtg)
	e1:SetOperation(c209710.drop)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡为表侧表示且种族为电子界族。
function c209710.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- 发动条件：自己场上有此卡以外的表侧表示电子界族怪兽2只以上，且自己手卡为0张。
function c209710.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少2只满足cfilter条件且不是此卡的电子界族怪兽。
	return Duel.IsExistingMatchingCard(c209710.cfilter,tp,LOCATION_MZONE,0,2,e:GetHandler())
		-- 确认自己手卡张数为0。
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 代价处理：支付1000基本分才能发动。
function c209710.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时的合法性检查：确认当前玩家能否支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- 发动时设定：确认玩家可以抽1张卡，并将抽卡玩家和抽卡数量记录为连锁信息。
function c209710.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认当前玩家可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将连锁的对象玩家设置为当前玩家（抽卡者）。
	Duel.SetTargetPlayer(tp)
	-- 将连锁的对象参数设置为1（抽卡数量）。
	Duel.SetTargetParam(1)
	-- 设置操作信息：效果处理时会有抽1张卡的操作，方便其他卡片进行连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：按照连锁记录的对象玩家和抽卡数量执行抽卡。
function c209710.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设置的对象玩家p和抽卡数量d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
