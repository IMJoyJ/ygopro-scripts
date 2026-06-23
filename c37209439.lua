--誤封の契約書
-- 效果：
-- ①：1回合1次，自己场上有「DD」怪兽存在的场合才能把这个效果发动。直到回合结束时，这张卡以外的场上的陷阱卡的效果无效化。
-- ②：自己准备阶段发动。自己受到1000伤害。
function c37209439.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己场上有「DD」怪兽存在的场合才能把这个效果发动。直到回合结束时，这张卡以外的场上的陷阱卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37209439,0))  --"效果无效"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCondition(c37209439.negcon)
	e2:SetOperation(c37209439.negop)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段发动。自己受到1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37209439,1))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c37209439.damcon)
	e3:SetTarget(c37209439.damtg)
	e3:SetOperation(c37209439.damop)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查以玩家来看的自己的主要怪兽区是否存在至少1张满足过滤条件的「DD」怪兽
function c37209439.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf)
end
-- 效果条件函数，判断自己场上有「DD」怪兽存在
function c37209439.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家来看的自己的主要怪兽区是否存在至少1张满足过滤条件的「DD」怪兽
	return Duel.IsExistingMatchingCard(c37209439.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果处理函数，使场上的陷阱卡效果无效
function c37209439.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 创建一个字段效果，使场上的陷阱卡效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c37209439.distg)
	e1:SetLabel(fid)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1作为玩家的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
	-- 创建一个持续效果，用于在连锁处理时使陷阱卡效果无效
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c37209439.disop)
	e2:SetLabel(fid)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e2作为玩家的效果注册给全局环境
	Duel.RegisterEffect(e2,tp)
	-- 创建一个字段效果，使场上的陷阱怪兽效果无效
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c37209439.distg)
	e3:SetLabel(fid)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e3作为玩家的效果注册给全局环境
	Duel.RegisterEffect(e3,tp)
end
-- 目标过滤函数，判断卡片是否为陷阱卡且不是当前卡片
function c37209439.distg(e,c)
	return c:GetFieldID()~=e:GetLabel() and c:IsType(TYPE_TRAP)
end
-- 连锁处理时的效果无效函数，判断是否为陷阱卡并使效果无效
function c37209439.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的触发位置
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) and re:GetHandler():GetFieldID()~=e:GetLabel() then
		-- 使连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
-- 伤害效果的触发条件函数，判断是否为自己的准备阶段
function c37209439.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 伤害效果的目标设定函数，设置目标玩家和伤害值
function c37209439.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数（伤害值）
	Duel.SetTargetParam(1000)
	-- 设置连锁处理的操作信息，包含伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 伤害效果的处理函数，对目标玩家造成伤害
function c37209439.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
