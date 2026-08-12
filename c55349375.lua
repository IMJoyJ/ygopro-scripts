--海造賊－青髭の海技士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「海造贼-蓝胡子海技士」以外的「海造贼」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从手卡·怪兽区域送去墓地的场合，丢弃1张手卡才能发动。自己从卡组抽1张。
function c55349375.initial_effect(c)
	-- ①：自己场上有「海造贼-蓝胡子海技士」以外的「海造贼」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55349375,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,55349375)
	e1:SetCondition(c55349375.spcon)
	e1:SetTarget(c55349375.sptg)
	e1:SetOperation(c55349375.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·怪兽区域送去墓地的场合，丢弃1张手卡才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55349375,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,55349376)
	e2:SetCondition(c55349375.drcon)
	e2:SetCost(c55349375.drcost)
	e2:SetTarget(c55349375.drtg)
	e2:SetOperation(c55349375.drop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示存在的「海造贼-蓝胡子海技士」以外的「海造贼」怪兽
function c55349375.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f) and not c:IsCode(55349375)
end
-- 效果①的发动条件：检查自己场上是否存在「海造贼-蓝胡子海技士」以外的「海造贼」怪兽
function c55349375.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的、且卡名不是「海造贼-蓝胡子海技士」的「海造贼」怪兽
	return Duel.IsExistingMatchingCard(c55349375.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备：检查自身能否特殊召唤以及怪兽区域是否有空位，并注册特殊召唤的操作信息
function c55349375.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己场上是否有可用的怪兽区域空格，且手卡中的这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：将自身特殊召唤（数量为1）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将手卡中的这张卡特殊召唤
function c55349375.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到发动效果的玩家场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动条件：检查这张卡是否是从手卡或怪兽区域送去墓地
function c55349375.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) or c:IsPreviousLocation(LOCATION_HAND)
end
-- 效果②的发动代价：丢弃1张手卡
function c55349375.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并以丢弃和代价为原因丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 效果②的发动准备：检查玩家是否可以抽卡，并设置抽卡的目标玩家、抽卡数量及操作信息
function c55349375.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查玩家当前是否可以效果抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的效果处理对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数（抽卡数量）为1
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理：自己从卡组抽1张卡
function c55349375.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
