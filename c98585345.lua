--ハネクリボー LV10
-- 效果：
-- 这张卡不能通常召唤。这张卡只能通过「进化之翼」的效果特殊召唤。可以把自己场上表侧表示存在的这张卡作祭品，对方场上攻击表示的怪兽全部破坏，给与对方基本分破坏怪兽的原本的攻击力合计的数值的伤害。这个效果在对方战斗阶段中才能发动。
function c98585345.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。这张卡只能通过「进化之翼」的效果特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制，使这张卡不能被常规特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 可以把自己场上表侧表示存在的这张卡作祭品，对方场上攻击表示的怪兽全部破坏，给与对方基本分破坏怪兽的原本的攻击力合计的数值的伤害。这个效果在对方战斗阶段中才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98585345,0))  --"破坏并伤害"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_BATTLE_PHASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c98585345.descon)
	e2:SetCost(c98585345.descost)
	e2:SetTarget(c98585345.destg)
	e2:SetOperation(c98585345.desop)
	c:RegisterEffect(e2)
end
c98585345.lvdn={33776734,48486809}
-- 定义效果发动条件：必须在对方回合的战斗阶段
function c98585345.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合的战斗阶段（从战斗阶段开始到战斗阶段结束）
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 定义发动代价：解放自身
function c98585345.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：筛选攻击表示的怪兽
function c98585345.dfilter(c)
	return c:IsAttackPos()
end
-- 定义发动目标：检查对方场上是否存在攻击表示怪兽，并注册破坏与伤害的操作信息
function c98585345.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查对方场上是否存在至少1只攻击表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c98585345.dfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的攻击表示怪兽
	local g=Duel.GetMatchingGroup(c98585345.dfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏操作信息，包含要破坏的怪兽组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害操作信息，目标为对方玩家
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 定义效果处理：破坏对方场上所有攻击表示怪兽，并给与对方相当于这些怪兽原本攻击力合计数值的伤害
function c98585345.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的攻击表示怪兽
	local g=Duel.GetMatchingGroup(c98585345.dfilter,tp,0,LOCATION_MZONE,nil)
	-- 因效果破坏筛选出的怪兽
	Duel.Destroy(g,REASON_EFFECT)
	-- 获取本次操作中实际被破坏的怪兽卡片组
	local dg=Duel.GetOperatedGroup()
	local tc=dg:GetFirst()
	local dam=0
	while tc do
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		dam=dam+atk
		tc=dg:GetNext()
	end
	-- 给与对方相当于被破坏怪兽原本攻击力合计数值的伤害
	Duel.Damage(1-tp,dam,REASON_EFFECT)
end
