--Emスティルツ・シューター
-- 效果：
-- 「娱乐法师 高跷射手」的②的效果1回合只能使用1次。
-- ①：场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不能通常召唤。
-- ②：自己墓地有这张卡以外的「娱乐法师」怪兽存在，给与对方伤害的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。给与对方2000伤害。
function c4081665.initial_effect(c)
	-- ①：场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c4081665.spcon)
	e1:SetOperation(c4081665.spop)
	c:RegisterEffect(e1)
	-- ②：自己墓地有这张卡以外的「娱乐法师」怪兽存在，给与对方伤害的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。给与对方2000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,4081665)
	e2:SetCondition(c4081665.damcon)
	-- 将墓地的这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c4081665.damtg)
	e2:SetOperation(c4081665.damop)
	c:RegisterEffect(e2)
end
-- 检查手卡特殊召唤的条件：场上没有怪兽存在且有可用怪兽区域
function c4081665.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否有可用怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否没有怪兽
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)==0
end
-- 特殊召唤成功后，使自己在该回合不能通常召唤和覆盖召唤
function c4081665.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 使自己在该回合不能通常召唤和覆盖召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册不能通常召唤的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 注册不能覆盖召唤的效果
	Duel.RegisterEffect(e2,tp)
end
-- 过滤函数，用于判断墓地是否存在「娱乐法师」怪兽
function c4081665.cfilter(c)
	return c:IsSetCard(0xc6) and c:IsType(TYPE_MONSTER)
end
-- 判断是否满足②效果的发动条件：墓地存在其他「娱乐法师」怪兽且对方受到伤害
function c4081665.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查墓地是否存在其他「娱乐法师」怪兽，并判断对方是否受到伤害
	return Duel.IsExistingMatchingCard(c4081665.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) and aux.damcon1(e,1-tp,eg,ep,ev,re,r,rp)
end
-- 设置效果的目标玩家和伤害值
function c4081665.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的伤害值为2000
	Duel.SetTargetParam(2000)
	-- 设置连锁操作信息为造成2000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- 执行伤害效果
function c4081665.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
