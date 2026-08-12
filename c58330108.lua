--破壊竜ガンドラ－ギガ・レイズ
-- 效果：
-- 这张卡不能通常召唤。把这张卡以外的自己的手卡·场上2只怪兽送去墓地的场合可以特殊召唤。
-- ①：这张卡的攻击力上升除外中的卡数量×300。
-- ②：1回合1次，把基本分支付一半才能发动。自己墓地的「甘多拉」怪兽种类对应的以下适用。
-- ●1种类：这张卡以外的场上的卡全部破坏。
-- ●2种类：这张卡以外的场上的卡全部除外。
-- ●3种类以上：这张卡以外的双方的场上·墓地的卡全部除外。
function c58330108.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把这张卡以外的自己的手卡·场上2只怪兽送去墓地的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c58330108.spcon)
	e1:SetTarget(c58330108.sptg)
	e1:SetOperation(c58330108.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升除外中的卡数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c58330108.value)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把基本分支付一半才能发动。自己墓地的「甘多拉」怪兽种类对应的以下适用。●1种类：这张卡以外的场上的卡全部破坏。●2种类：这张卡以外的场上的卡全部除外。●3种类以上：这张卡以外的双方的场上·墓地的卡全部除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58330108,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c58330108.cost)
	e3:SetTarget(c58330108.target)
	e3:SetOperation(c58330108.operation)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡·场上的怪兽，且能送去墓地
function c58330108.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤规则的条件：检查手卡·场上是否存在满足送墓条件且能保证怪兽区域空位的2只怪兽
function c58330108.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取手卡·场上除这张卡以外的所有满足送墓条件的怪兽
	local g=Duel.GetMatchingGroup(c58330108.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,c)
	-- 检查是否能选出2只怪兽，在送去墓地后能让这张卡成功特殊召唤到怪兽区域
	return g:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 特殊召唤规则的准备：选择要送去墓地的2只怪兽并保存
function c58330108.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡·场上除这张卡以外的所有满足送墓条件的怪兽
	local g=Duel.GetMatchingGroup(c58330108.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,c)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择2只送去墓地后能保证特殊召唤位置的怪兽
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行：将选中的怪兽送去墓地
function c58330108.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽作为特殊召唤的消耗送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 计算攻击力上升数值的辅助函数
function c58330108.value(e,c)
	-- 返回双方除外区卡片总数乘以300的数值
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED)*300
end
-- 效果发动代价：支付一半基本分
function c58330108.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 扣除发动玩家当前基本分的一半（向下取整）
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤条件：墓地的「甘多拉」怪兽
function c58330108.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf5)
end
-- 效果发动时的目标确认与操作信息设置：根据墓地「甘多拉」怪兽的种类数，判断是否满足发动条件并设置对应的效果分类（破坏或除外）
function c58330108.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 计算自己墓地中「甘多拉」怪兽的不同卡名（种类）数量
	local gc=Duel.GetMatchingGroup(c58330108.filter,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)
	if chk==0 then
		-- 检查场上是否存在除这张卡以外的卡（用于1种类时的破坏效果检测）
		local b1=Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		-- 检查场上是否存在除这张卡以外可以被除外的卡（用于2种类时的除外效果检测）
		local b2=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		-- 检查双方场上·墓地是否存在除张卡以外可以被除外的卡（用于3种类以上时的除外效果检测）
		local b3=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,c)
		return (gc==1 and b1) or (gc==2 and b2) or (gc>2 and b3)
	end
	if gc==1 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 获取场上除这张卡以外的所有卡
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		-- 设置连锁中的操作信息：破坏场上除这张卡以外的所有卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	else
		e:SetCategory(CATEGORY_REMOVE)
		local loc=LOCATION_ONFIELD
		if gc>2 then loc=LOCATION_ONFIELD+LOCATION_GRAVE end
		-- 根据种类数获取对应区域（场上或双方场上·墓地）中除这张卡以外可以被除外的卡
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,loc,loc,c)
		-- 设置连锁中的操作信息：除外符合条件的卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	end
end
-- 效果处理的执行：根据墓地「甘多拉」怪兽的种类数，执行对应的破坏或除外处理
function c58330108.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新计算自己墓地中「甘多拉」怪兽的种类数
	local gc=Duel.GetMatchingGroup(c58330108.filter,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)
	if gc==1 then
		-- 获取场上除这张卡以外的所有卡（若这张卡已离场则获取全部场上的卡）
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		-- 因效果破坏获取到的卡片组
		Duel.Destroy(g,REASON_EFFECT)
	elseif gc>=2 then
		local loc=LOCATION_ONFIELD
		if gc>2 then loc=LOCATION_ONFIELD+LOCATION_GRAVE end
		-- 获取对应区域中除这张卡以外可以被除外的卡
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,loc,loc,aux.ExceptThisCard(e))
		-- 因效果将获取到的卡片组表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
