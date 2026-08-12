--DDD剋竜王ベオウルフ
-- 效果：
-- 「DDD」怪兽＋「DD」怪兽
-- ①：只要这张卡在怪兽区域存在，自己的「DD」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：自己准备阶段才能发动。双方的魔法与陷阱区域的卡全部破坏。
function c8463720.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「DDD」怪兽和「DD」怪兽，并允许使用替代素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10af),aux.FilterBoolFunction(Card.IsFusionSetCard,0xaf),true)
	-- ①：只要这张卡在怪兽区域存在，自己的「DD」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置贯通效果的影响对象为自己场上的「DD」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xaf))
	c:RegisterEffect(e1)
	-- ②：自己准备阶段才能发动。双方的魔法与陷阱区域的卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8463720,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c8463720.descon)
	e2:SetTarget(c8463720.destg)
	e2:SetOperation(c8463720.desop)
	c:RegisterEffect(e2)
end
-- 定义效果②的发动条件函数：必须在自己的回合
function c8463720.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 定义过滤函数：筛选魔法与陷阱区域的卡（格子编号小于5，即不含场地区）
function c8463720.filter(c)
	return c:GetSequence()<5
end
-- 定义效果②的发动目标函数：确认双方魔陷区有卡可破坏，并注册破坏的操作信息
function c8463720.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，判断双方魔法与陷阱区域是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(c8463720.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	-- 获取双方魔法与陷阱区域的所有卡
	local g=Duel.GetMatchingGroup(c8463720.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 设置破坏操作信息，包含要破坏的卡片组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果②的运行操作函数：将双方魔法与陷阱区域的卡全部破坏
function c8463720.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方魔法与陷阱区域的所有卡
	local g=Duel.GetMatchingGroup(c8463720.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 以效果原因破坏这些卡
	Duel.Destroy(g,REASON_EFFECT)
end
