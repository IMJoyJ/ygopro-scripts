--P.U.N.K.JAMエクストリーム・セッション
-- 效果：
-- 这个卡名的②的效果1回合可以使用最多2次。
-- ①：1回合1次，从自己墓地把1张「朋克」卡除外才能发动。从手卡把1只「朋克」怪兽特殊召唤。
-- ②：自己场上的念动力族怪兽为让效果发动而支付基本分的场合才能发动。自己抽1张。
function c49370016.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，从自己墓地把1张「朋克」卡除外才能发动。从手卡把1只「朋克」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c49370016.spcost)
	e2:SetTarget(c49370016.sptg)
	e2:SetOperation(c49370016.spop)
	c:RegisterEffect(e2)
	-- ②：自己场上的念动力族怪兽为让效果发动而支付基本分的场合才能发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PAY_LPCOST)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(2,49370016)
	e3:SetCondition(c49370016.drcon)
	e3:SetTarget(c49370016.drtg)
	e3:SetOperation(c49370016.drop)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查满足条件的「朋克」卡是否存在于墓地
function c49370016.costfilter(c)
	return c:IsSetCard(0x171) and c:IsAbleToRemoveAsCost()
end
-- 效果处理：检索满足条件的卡片组并除外
function c49370016.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家来看的指定位置是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c49370016.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足过滤条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c49370016.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将目标卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，检查满足条件的「朋克」怪兽是否存在于手牌
function c49370016.spfilter(c,e,tp)
	return c:IsSetCard(0x171) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：判断是否可以发动并设置处理信息
function c49370016.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查以玩家来看的指定位置是否存在至少1张满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c49370016.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前处理的连锁的操作信息，确定要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：检索满足条件的卡片组并特殊召唤
function c49370016.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足过滤条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c49370016.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将目标怪兽特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断是否满足发动条件，即自己场上的念动力族怪兽为让效果发动而支付基本分
function c49370016.drcon(e,tp,eg,ep,ev,re,r,rp)
	if not (tp==ep and re and re:IsActivated() and re:GetActivateLocation()==LOCATION_MZONE) then return false end
	local rc=re:GetHandler()
	return rc:IsRelateToEffect(re) and rc:IsRace(RACE_PSYCHO)
		or not rc:IsRelateToEffect(re) and rc:GetPreviousRaceOnField()&RACE_PSYCHO~=0
end
-- 效果处理：设置抽卡操作信息
function c49370016.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前正在处理的连锁的对象玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前正在处理的连锁的对象参数
	Duel.SetTargetParam(1)
	-- 设置当前处理的连锁的操作信息，确定要抽卡的数量和对象
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：执行抽卡操作
function c49370016.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
