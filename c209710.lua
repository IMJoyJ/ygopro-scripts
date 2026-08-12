--フリック・クラウン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上有这张卡以外的电子界族怪兽2只以上存在，自己手卡是0张的场合，支付1000基本分才能发动。自己从卡组抽1张。
function c209710.initial_effect(c)
	-- 创建效果1，设置效果描述、分类为抽卡、类型为起动效果、发动位置为主怪区、限制一回合只能发动1次、条件为drcon、费用为drcost、目标为drtg、效果处理为drop
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
-- 过滤函数，用于判断是否为表侧表示的电子界族怪兽
function c209710.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- 效果条件函数，检查自己场上有2只以上电子界族怪兽且自己手卡为0张
function c209710.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上有至少2只满足cfilter条件的怪兽
	return Duel.IsExistingMatchingCard(c209710.cfilter,tp,LOCATION_MZONE,0,2,e:GetHandler())
		-- 检查自己手卡数量为0张
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 效果费用函数，检查并支付1000基本分
function c209710.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果目标函数，设置目标玩家和抽卡数量，并设置操作信息
function c209710.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的目标玩家为处理效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为抽卡效果，目标为1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数，执行抽卡效果
function c209710.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡，原因效果
	Duel.Draw(p,d,REASON_EFFECT)
end
