--精霊神后 ドリアード
-- 效果：
-- 这张卡不能通常召唤。自己·对方的墓地的怪兽属性是6种类以上的场合才能特殊召唤。
-- ①：这张卡的攻击力·守备力上升自己·对方的墓地的怪兽的属性种类×500。
-- ②：对方把怪兽特殊召唤之际，把自己墓地3只怪兽除外才能发动。那次特殊召唤无效，那些怪兽破坏。
function c32965616.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己·对方的墓地的怪兽属性是6种类以上的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c32965616.spcon)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力·守备力上升自己·对方的墓地的怪兽的属性种类×500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c32965616.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 对方把怪兽特殊召唤之际，把自己墓地3只怪兽除外才能发动。那次特殊召唤无效，那些怪兽破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(32965616,0))
	e5:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_SPSUMMON)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c32965616.discon)
	e5:SetCost(c32965616.discost)
	e5:SetTarget(c32965616.distg)
	e5:SetOperation(c32965616.disop)
	c:RegisterEffect(e5)
end
-- 检查场上是否有足够的位置以及墓地是否有6种以上属性的怪兽。
function c32965616.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否有足够的位置。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 获取墓地中所有怪兽的属性种类数。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_MONSTER)
	return g:GetClassCount(Card.GetAttribute)>=6
end
-- 获取墓地中所有怪兽的属性种类数并乘以500作为攻击力加成。
function c32965616.atkval(e,c)
	-- 获取墓地中所有怪兽的属性种类数。
	local g=Duel.GetMatchingGroup(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_MONSTER)
	return g:GetClassCount(Card.GetAttribute)*500
end
-- 判断是否为对方特殊召唤且当前无连锁处理。
function c32965616.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方特殊召唤且当前无连锁处理。
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 定义除外卡的过滤条件：必须是怪兽且能作为费用除外。
function c32965616.discfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 检查是否满足除外3张怪兽的费用条件，并选择并除外这些卡。
function c32965616.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外3张怪兽的费用条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c32965616.discfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择3张满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,c32965616.discfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 将选中的卡除外作为费用。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果处理时的操作信息，包括无效召唤和破坏。
function c32965616.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置破坏的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 执行效果操作：使召唤无效并破坏相关怪兽。
function c32965616.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使召唤无效。
	Duel.NegateSummon(eg)
	-- 破坏相关怪兽。
	Duel.Destroy(eg,REASON_EFFECT)
end
