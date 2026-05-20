--肆世壊の継承
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把自己场上3只「恐吓爪牙族」怪兽解放才能发动。这个回合，对方不用守备表示不能把怪兽特殊召唤。
-- ②：自己回合，把墓地的这张卡除外才能发动。给与对方为场上的守备表示怪兽数量×100伤害。
local s,id,o=GetID()
-- 初始化卡片效果，注册①号效果（魔法卡发动）和②号效果（墓地即时效果）
function s.initial_effect(c)
	-- ①：把自己场上3只「恐吓爪牙族」怪兽解放才能发动。这个回合，对方不用守备表示不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己回合，把墓地的这张卡除外才能发动。给与对方为场上的守备表示怪兽数量×100伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.damcon)
	-- 把墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上或表侧表示的「恐吓爪牙族」怪兽
function s.cfilter(c,tp)
	return c:IsSetCard(0x17a) and (c:IsControler(tp) or c:IsFaceup())
end
-- ①号效果的发动代价：解放自己场上3只「恐吓爪牙族」怪兽
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少3只可解放的「恐吓爪牙族」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,3,nil) end
	-- 玩家选择3只可解放的「恐吓爪牙族」怪兽
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,3,3,nil)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- ①号效果的发动准备
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否尚未适用过该效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- ①号效果的处理：注册限制对方特殊召唤表示形式的效果，并注册回合标记
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方不用守备表示不能把怪兽特殊召唤。/自己回合，把墓地的这张卡除外才能发动。给与对方为场上的守备表示怪兽数量×100伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制对方特殊召唤表示形式的全局效果
	Duel.RegisterEffect(e1,tp)
	-- 注册本回合已适用该效果的玩家标记
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 限制特殊召唤的表示形式不能为攻击表示
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_ATTACK)>0
end
-- ②号效果的发动条件
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- ②号效果的发动准备
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在守备表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 计算场上守备表示怪兽数量×100的伤害数值
	local dam=Duel.GetMatchingGroupCount(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*100
	-- 设置伤害的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值
	Duel.SetTargetParam(dam)
	-- 设置操作信息为给与对方伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- ②号效果的处理
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算当前场上的守备表示怪兽数量×100的伤害数值
	local dam=Duel.GetMatchingGroupCount(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*100
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
