--EMエクストラ・シューター
-- 效果：
-- ←6 【灵摆】 6→
-- 「娱乐伙伴 额外射手」的灵摆效果1回合只能使用1次，这个效果发动的回合，自己不能灵摆召唤。
-- ①：自己主要阶段才能发动。给与对方为自己的额外卡组的表侧表示的灵摆怪兽数量×300伤害。
-- 【怪兽效果】
-- ①：1回合1次，从自己的额外卡组把1只怪兽除外，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡破坏，给与对方300伤害。
function c45591967.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。给与对方为自己的额外卡组的表侧表示的灵摆怪兽数量×300伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45591967,0))  --"效果伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,45591967)
	e1:SetCost(c45591967.dmcost)
	e1:SetTarget(c45591967.dmtg)
	e1:SetOperation(c45591967.dmop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，从自己的额外卡组把1只怪兽除外，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡破坏，给与对方300伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45591967,1))  --"卡片破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c45591967.descost)
	e2:SetTarget(c45591967.destg)
	e2:SetOperation(c45591967.desop)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于记录玩家在本回合中进行的特殊召唤次数，以限制灵摆效果的使用次数
	Duel.AddCustomActivityCounter(45591967,ACTIVITY_SPSUMMON,c45591967.counterfilter)
end
-- 计数器的过滤函数，排除灵摆召唤的怪兽，确保只有非灵摆召唤的特殊召唤计入计数器
function c45591967.counterfilter(c)
	return not c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 检查当前玩家是否已经进行过特殊召唤，若未进行则允许发动灵摆效果
function c45591967.dmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 创建一个场地方效果，禁止玩家在本回合进行灵摆召唤
	if chk==0 then return Duel.GetCustomActivityCount(45591967,tp,ACTIVITY_SPSUMMON)==0 end
	-- 将该效果注册到玩家的场上
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c45591967.splimit)
	-- 设置该效果的限制条件，仅对灵摆召唤进行限制
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数，判断召唤类型是否为灵摆召唤
function c45591967.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤函数，判断卡片是否为表侧表示的灵摆怪兽
function c45591967.dmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 设置灵摆效果的目标和操作信息，计算伤害值并设定目标玩家
function c45591967.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家额外卡组是否存在表侧表示的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c45591967.dmfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 获取玩家额外卡组中表侧表示的灵摆怪兽数量并乘以300作为伤害值
	local dam=Duel.GetMatchingGroupCount(c45591967.dmfilter,tp,LOCATION_EXTRA,0,nil)*300
	-- 设定连锁操作的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设定连锁操作的目标参数为计算出的伤害值
	Duel.SetTargetParam(dam)
	-- 设置连锁操作信息，指定伤害效果的目标玩家和伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行灵摆效果的伤害处理，对目标玩家造成相应伤害
function c45591967.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 再次获取玩家额外卡组中表侧表示的灵摆怪兽数量并乘以300作为伤害值
	local d=Duel.GetMatchingGroupCount(c45591967.dmfilter,tp,LOCATION_EXTRA,0,nil)*300
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 设置怪兽效果的费用，从额外卡组除外1只怪兽作为费用
function c45591967.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家额外卡组是否存在可以除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择玩家额外卡组中1只可以除外的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的怪兽除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置怪兽效果的目标和操作信息，选择灵摆区域的1张卡进行破坏并造成伤害
function c45591967.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) end
	-- 检查是否存在可以作为目标的灵摆区域的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择玩家或对方灵摆区域的1张卡作为目标
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,nil)
	-- 设置连锁操作信息，指定破坏效果的目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁操作信息，指定伤害效果的目标玩家和伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 执行怪兽效果的破坏和伤害处理，对目标卡进行破坏并造成伤害
function c45591967.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然有效并进行破坏操作
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 对目标玩家造成300点伤害
		Duel.Damage(1-tp,300,REASON_EFFECT)
	end
end
