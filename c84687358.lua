--ミラーフォース・ドラゴン
-- 效果：
-- 这张卡在用「克里底亚之牙」的效果把自己的手卡·场上的「神圣防护罩 -反射镜力-」送去墓地的场合才能特殊召唤。
-- ①：自己场上的怪兽被选择作为攻击对象时或者成为对方的效果的对象时才能发动。对方场上的卡全部破坏。
function c84687358.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡在用「克里底亚之牙」的效果把自己的手卡·场上的「神圣防护罩 -反射镜力-」送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ①：自己场上的怪兽被选择作为攻击对象时才能发动。对方场上的卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c84687358.descon1)
	e2:SetTarget(c84687358.destg)
	e2:SetOperation(c84687358.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BECOME_TARGET)
	e3:SetCondition(c84687358.descon2)
	c:RegisterEffect(e3)
end
c84687358.material_trap=44095762
-- 过滤函数：检查卡片是否是自己场上的怪兽
function c84687358.tgfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 发动条件1：自己场上的怪兽被选择作为攻击对象时
function c84687358.descon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c84687358.tgfilter,1,nil,tp)
end
-- 发动条件2：自己场上的怪兽成为对方的效果的对象时
function c84687358.descon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c84687358.tgfilter,1,nil,tp)
end
-- 效果发动靶向：检查对方场上是否存在可破坏的卡，且此卡自身不在连锁中（防止同一连锁内重复发动）
function c84687358.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：破坏对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：获取并破坏对方场上的所有卡
function c84687358.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果破坏上述卡片
	Duel.Destroy(g,REASON_EFFECT)
end
