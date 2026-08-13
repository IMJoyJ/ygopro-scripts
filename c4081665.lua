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
	-- 「娱乐法师 高跷射手」的②的效果1回合只能使用1次。②：自己墓地有这张卡以外的「娱乐法师」怪兽存在，给与对方伤害的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。给与对方2000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,4081665)
	e2:SetCondition(c4081665.damcon)
	-- 设置②效果的发动COST：必须把墓地中的这张卡除外才能发动。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c4081665.damtg)
	e2:SetOperation(c4081665.damop)
	c:RegisterEffect(e2)
end
-- ①特殊召唤规则效果的条件判断：若自己怪兽区有空位且全场没有怪兽存在，则这张卡可以从手卡特殊召唤；c为nil时返回true（规则查询时视为可行）。
function c4081665.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己的主要怪兽区是否存在空位，确保特殊召唤后有可用区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查全场（双方怪兽区域）没有怪兽，对应“场上没有怪兽存在的场合”。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)==0
end
-- 特殊召唤成功时给自附加本回合不能通常召唤、不能覆盖怪兽的誓约效果，持续到结束阶段。
function c4081665.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤过的回合，自己不能通常召唤。②：自己墓地有这张卡以外的「娱乐法师」怪兽存在，给与对方伤害的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。给与对方2000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将禁止通常召唤的誓约效果注册给玩家tp，使该玩家本回合不能通常召唤。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 将禁止覆盖怪兽的誓约效果注册给玩家tp，使该玩家本回合不能覆盖怪兽。
	Duel.RegisterEffect(e2,tp)
end
-- 过滤函数：判断卡是否为「娱乐法师」怪兽（0xc6）且为怪兽卡，用于检索墓地中是否含有符合条件的「娱乐法师」怪兽。
function c4081665.cfilter(c)
	return c:IsSetCard(0xc6) and c:IsType(TYPE_MONSTER)
end
-- ②效果的发动条件：自己墓地存在这张卡以外的「娱乐法师」怪兽，并且当前有会对对方造成伤害的魔法·陷阱·怪兽效果发动。
function c4081665.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：自己墓地存在至少1张其他「娱乐法师」怪兽（排除自身），且对方玩家受到伤害的效果发动（由aux.damcon1判定）。
	return Duel.IsExistingMatchingCard(c4081665.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) and aux.damcon1(e,1-tp,eg,ep,ev,re,r,rp)
end
-- ②效果发动时的目标处理：设置伤害对象为对方玩家、伤害值为2000，并登记操作信息为2000点效果伤害。
function c4081665.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果对象玩家设置为对方玩家（1-tp），即伤害目标。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的效果参数设置为2000，作为本次伤害的数值。
	Duel.SetTargetParam(2000)
	-- 登记操作信息：本连锁效果为向对方玩家造成2000点伤害（不取对象），供其他效果联动判定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- ②效果处理：从连锁信息中取得目标玩家和伤害值，对对方执行2000点效果伤害。
function c4081665.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的目标玩家p和伤害数值d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以‘效果’为原因对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
