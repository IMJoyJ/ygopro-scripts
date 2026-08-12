--E-HERO トキシック・バブル
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是「英雄」怪兽不能特殊召唤。
-- ②：这张卡特殊召唤的场合，若「暗黑融合」的效果才能特殊召唤的融合怪兽在自己场上存在则能发动。自己抽2张。
local s,id,o=GetID()
-- 初始化卡片效果，注册手牌特殊召唤和抽卡效果
function s.initial_effect(c)
	-- 记录该卡与「暗黑融合」的关联
	aux.AddCodeList(c,94820406)
	-- ①：这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是「英雄」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合，若「暗黑融合」的效果才能特殊召唤的融合怪兽在自己场上存在则能发动。自己抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 判断特殊召唤条件是否满足，检查场上是否有空位
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家场上主怪兽区是否还有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 执行特殊召唤后的处理，设置不能特殊召唤非英雄怪兽的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 设置不能特殊召唤非英雄怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非英雄怪兽
function s.splimit(e,c)
	return not c:IsSetCard(0x8)
end
-- 过滤场上存在的「暗黑融合」效果的融合怪兽
function s.cfilter(c)
	return c:IsFaceup() and c.dark_calling
end
-- 设置抽卡效果的目标和参数
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足抽卡发动条件，即场上存在融合怪兽且玩家可以抽2张卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,2) end
	-- 设置抽卡效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的抽卡数量为2
	Duel.SetTargetParam(2)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行抽卡操作
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，从牌组抽2张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
