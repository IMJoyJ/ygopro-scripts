--黄華の機界騎士
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：相同纵列有卡2张以上存在的场合，这张卡可以在那个纵列的自己场上特殊召唤。
-- ②：从自己墓地把1只「机界骑士」怪兽除外，以和这张卡相同纵列1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c29415459.initial_effect(c)
	-- ①：相同纵列有卡2张以上存在的场合，这张卡可以在那个纵列的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,29415459+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c29415459.hspcon)
	e1:SetValue(c29415459.hspval)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把1只「机界骑士」怪兽除外，以和这张卡相同纵列1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29415459,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c29415459.cost)
	e3:SetTarget(c29415459.target)
	e3:SetOperation(c29415459.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断一张卡是否在同一纵列有其他卡存在
function c29415459.cfilter(c)
	return c:GetColumnGroupCount()>0
end
-- 判断特殊召唤条件是否满足，即是否有符合条件的纵列区域可用
function c29415459.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=0
	-- 获取场上所有在同一纵列有卡的卡组
	local lg=Duel.GetMatchingGroup(c29415459.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历符合条件的卡组，计算可用的召唤区域
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	-- 检查在计算出的区域中是否有足够的召唤空间
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 返回特殊召唤时可用的召唤区域
function c29415459.hspval(e,c)
	local tp=c:GetControler()
	local zone=0
	-- 获取场上所有在同一纵列有卡的卡组
	local lg=Duel.GetMatchingGroup(c29415459.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历符合条件的卡组，计算可用的召唤区域
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	return 0,zone
end
-- 过滤函数，用于判断一张卡是否为「机界骑士」怪兽且可作为除外的代价
function c29415459.costfilter(c)
	return c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的费用处理，从墓地选择并除外一张「机界骑士」怪兽
function c29415459.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足费用条件，即墓地是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c29415459.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择要除外的卡
	local g=Duel.SelectMatchingCard(tp,c29415459.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于判断一张卡是否为魔法或陷阱卡且在同一纵列
function c29415459.filter(c,g)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and g:IsContains(c)
end
-- 设置效果的目标，选择一张同纵列的魔法或陷阱卡
function c29415459.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cg=e:GetHandler():GetColumnGroup()
	if chkc then return c29415459.filter(chkc,cg) and chkc:IsOnField() end
	-- 检查是否满足效果发动条件，即场上是否存在符合条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c29415459.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,cg) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的卡
	local g=Duel.SelectTarget(tp,c29415459.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,cg)
	-- 设置效果操作信息，确定破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果的处理函数，对选中的卡进行破坏
function c29415459.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
