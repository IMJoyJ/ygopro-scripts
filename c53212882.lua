--ふわんだりぃず×すのーる
-- 效果：
-- ①：上级召唤的这张卡存在的场合，1回合1次，可以发动。这个回合自己可以进行通常召唤最多3次。
-- ②：只要上级召唤的这张卡在怪兽区域存在，自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：对方回合1次，把1张手卡除外才能发动。对方场上的特殊召唤的怪兽全部变成里侧守备表示。
function c53212882.initial_effect(c)
	-- ①：上级召唤的这张卡存在的场合，1回合1次，可以发动。这个回合自己可以进行通常召唤最多3次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53212882,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c53212882.sumcon)
	e1:SetTarget(c53212882.sumtg)
	e1:SetOperation(c53212882.sumop)
	c:RegisterEffect(e1)
	-- ②：只要上级召唤的这张卡在怪兽区域存在，自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c53212882.sumcon)
	c:RegisterEffect(e2)
	-- ③：对方回合1次，把1张手卡除外才能发动。对方场上的特殊召唤的怪兽全部变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53212882,1))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(c53212882.poscon)
	e3:SetCost(c53212882.poscost)
	e3:SetTarget(c53212882.postg)
	e3:SetOperation(c53212882.posop)
	c:RegisterEffect(e3)
end
-- 判断此卡是否为上级召唤方式特殊召唤到场上的
function c53212882.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 检测当前玩家是否可以进行额外通常召唤（最多3次）
function c53212882.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=0
		-- 获取当前玩家受影响的召唤次数限制效果
		local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
		for _,te in ipairs(ce) do
			ct=math.max(ct,te:GetValue())
		end
		return ct<3
	end
end
-- 设置当前玩家在本回合可进行最多3次通常召唤
function c53212882.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册一个影响全场玩家的召唤次数限制效果，使该玩家本回合可进行3次通常召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(3)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册到玩家tp的全局环境中
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否为对方回合
function c53212882.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是自己时（即为对方回合）
	return Duel.GetTurnPlayer()==1-tp
end
-- 支付发动效果所需的代价：从手牌中除外1张卡
function c53212882.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可作为代价除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张手牌作为除外的代价
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将所选的卡以正面表示形式除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义用于检测目标怪兽是否满足效果发动条件的过滤函数
function c53212882.posfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsFaceup() and c:IsCanTurnSet()
end
-- 设置效果的目标：对方场上的特殊召唤怪兽变为里侧守备表示
function c53212882.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在满足条件的特殊召唤怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c53212882.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取所有满足条件的对方场上的特殊召唤怪兽
	local g=Duel.GetMatchingGroup(c53212882.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，表明将要改变这些怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 执行效果操作：将符合条件的怪兽变为里侧守备表示
function c53212882.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足条件的对方场上的特殊召唤怪兽
	local g=Duel.GetMatchingGroup(c53212882.posfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将目标怪兽全部变为里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
