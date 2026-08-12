--Evil★Twin キスキル・ディール
-- 效果：
-- 「姬丝基勒」怪兽1只
-- 自己对「邪恶★双子 姬丝基勒·交易」1回合只能有1次连接召唤。这个卡名的效果1回合只能使用1次。
-- ①：从卡组·额外卡组把1只「璃拉」怪兽送去墓地才能发动。这个回合中，以下效果适用。
-- ●每次对方连锁自己的「姬丝基勒」怪兽或「璃拉」怪兽的效果的发动把效果发动，自己抽1张。
local s,id,o=GetID()
-- 定义卡片效果：设置连接召唤手续，注册连接召唤成功时限制后续同名卡连接召唤的辅助效果，以及注册从卡组·额外卡组送墓「璃拉」怪兽来适用抽卡效果的起动效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：需要1只怪兽作为素材，过滤条件为s.matfilter。
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	-- 自己对「邪恶★双子 姬丝基勒·交易」1回合只能有1次连接召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- 这个卡名的效果1回合只能使用1次。①：从卡组·额外卡组把1只「璃拉」怪兽送去墓地才能发动。这个回合中，以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动效果"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 连接素材过滤：必须是「姬丝基勒」怪兽。
function s.matfilter(c)
	return c:IsLinkSetCard(0x152)
end
-- 连接召唤成功时效果的发动条件：自身是通过连接召唤特殊召唤的。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 连接召唤成功时的处理：注册一个持续到回合结束的玩家效果，限制同名卡的连接召唤。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己对「邪恶★双子 姬丝基勒·交易」1回合只能有1次连接召唤。这个卡名的效果1回合只能使用1次。①：从卡组·额外卡组把1只「璃拉」怪兽送去墓地才能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	-- 注册限制特殊召唤的玩家效果。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：限制本回合不能再连接召唤同名卡。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 代价过滤：卡组·额外卡组的「璃拉」怪兽。
function s.costfilter(c)
	return c:IsSetCard(0x153) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果发动代价：从卡组·额外卡组把1只「璃拉」怪兽送去墓地。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：检查卡组或额外卡组是否存在可送去墓地的「璃拉」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组或额外卡组选择1只「璃拉」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	-- 将选择的怪兽作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理：注册一个持续到回合结束的全局效果，在连锁处理完毕时触发抽卡。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ●每次对方连锁自己的「姬丝基勒」怪兽或「璃拉」怪兽的效果的发动把效果发动，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetCondition(s.drcon)
	e1:SetOperation(s.drop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册回合内适用的抽卡效果。
	Duel.RegisterEffect(e1,tp)
end
-- 抽卡效果的触发条件：对方连锁了自己的「姬丝基勒」或「璃拉」怪兽效果的发动而发动效果。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁（对方的效果）是否可以被无效（用于确认是否是对应效果发动的连锁）。
	if not Duel.IsChainDisablable(ev) then return false end
	-- 获取前一个连锁（即被对方连锁的我方效果）的效果和发动玩家。
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local tc=te:GetHandler()
	return te and tc:IsSetCard(0x152,0x153) and te:IsActiveType(TYPE_MONSTER) and p==tp and rp==1-tp
end
-- 抽卡效果的具体处理：展示卡片并让自身抽1张卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 在决斗界面展示该卡，提示效果适用。
	Duel.Hint(HINT_CARD,0,id)
	-- 自己从卡组抽1张卡。
	Duel.Draw(tp,1,REASON_EFFECT)
end
