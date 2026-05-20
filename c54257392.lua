--Live☆Twin キスキル・フロスト
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「璃拉」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：对方用卡的效果从卡组把卡加入手卡的场合，若自己场上有「邪恶★双子」怪兽存在，把墓地的这张卡除外才能发动。自己抽1张。
function c54257392.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「璃拉」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54257392,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,54257392+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c54257392.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：对方用卡的效果从卡组把卡加入手卡的场合，若自己场上有「邪恶★双子」怪兽存在，把墓地的这张卡除外才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54257392,1))  --"除外并抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCountLimit(1,54257393)
	e2:SetRange(LOCATION_GRAVE)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c54257392.drcon)
	e2:SetTarget(c54257392.drtg)
	e2:SetOperation(c54257392.drop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「璃拉」怪兽
function c54257392.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x153)
end
-- 特殊召唤规则的判定条件
function c54257392.spcon(e,c)
	if c==nil then return true end
	-- 检查自身控制者的怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己场上是否存在表侧表示的「璃拉」怪兽
		Duel.IsExistingMatchingCard(c54257392.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：因卡的效果从卡组加入手牌的卡
function c54257392.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_EFFECT)
end
-- 过滤条件：场上表侧表示的「邪恶★双子」怪兽
function c54257392.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2151)
end
-- 效果②的发动条件判定
function c54257392.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c54257392.cfilter,1,nil,1-tp) and rp==1-tp
		-- 检查自己场上是否存在表侧表示的「邪恶★双子」怪兽
		and Duel.IsExistingMatchingCard(c54257392.drfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动准备与目标确认
function c54257392.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理
function c54257392.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果：目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
