--セフィラの聖選士
-- 效果：
-- ①：得到自己的额外卡组的表侧表示的「神数」怪兽种类的以下效果。
-- ●3种类以上：自己场上的怪兽的攻击力上升双方的额外卡组的表侧表示的卡数量×100。
-- ●5种类以上：自己场上的怪兽不会被对方的效果破坏。
-- ●8种类以上：自己场上的怪兽不会成为对方的效果的对象。
-- ●10种类：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。对方的手卡·场上·墓地的卡全部回到持有者卡组。
function c98076754.initial_effect(c)
	-- ①：得到自己的额外卡组的表侧表示的「神数」怪兽种类的以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动的条件为不在伤害计算后（配合伤害步骤发动限制）
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ●3种类以上：自己场上的怪兽的攻击力上升双方的额外卡组的表侧表示的卡数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c98076754.effcon)
	e2:SetValue(c98076754.atkval)
	e2:SetLabel(3)
	c:RegisterEffect(e2)
	-- ●5种类以上：自己场上的怪兽不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c98076754.effcon)
	-- 设置不会被对方的效果破坏
	e3:SetValue(aux.indoval)
	e3:SetLabel(5)
	c:RegisterEffect(e3)
	-- ●8种类以上：自己场上的怪兽不会成为对方的效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(c98076754.effcon)
	-- 设置不会成为对方的效果的对象
	e4:SetValue(aux.tgoval)
	e4:SetLabel(8)
	c:RegisterEffect(e4)
	-- ●10种类：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。对方的手卡·场上·墓地的卡全部回到持有者卡组。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c98076754.tdcon)
	e5:SetCost(c98076754.tdcost)
	e5:SetTarget(c98076754.tdtg)
	e5:SetOperation(c98076754.tdop)
	c:RegisterEffect(e5)
end
-- 过滤自身额外卡组表侧表示的「神数」怪兽
function c98076754.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc4)
end
-- 判定自己额外卡组表侧表示的「神数」怪兽种类是否达到指定数量以上
function c98076754.effcon(e)
	-- 获取自己额外卡组表侧表示的「神数」怪兽的卡名种类数量，并判断是否大于等于设定的数值
	return Duel.GetMatchingGroup(c98076754.cfilter,e:GetHandlerPlayer(),LOCATION_EXTRA,0,nil):GetClassCount(Card.GetCode)>=e:GetLabel()
end
-- 计算攻击力上升数值的函数
function c98076754.atkval(e,c)
	-- 返回双方额外卡组表侧表示的卡片数量乘以100的数值
	return Duel.GetMatchingGroupCount(Card.IsFaceup,0,LOCATION_EXTRA,LOCATION_EXTRA,nil)*100
end
-- 判定自己额外卡组表侧表示的「神数」怪兽种类是否刚好为10种类
function c98076754.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己额外卡组表侧表示的「神数」怪兽卡名种类数量是否等于10
	return Duel.GetMatchingGroup(c98076754.cfilter,tp,LOCATION_EXTRA,0,nil):GetClassCount(Card.GetCode)==10
end
-- 10种类效果的发动代价处理函数
function c98076754.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将魔法与陷阱区域表侧表示的这张卡送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 10种类效果的发动准备与合法性检测函数
function c98076754.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方的手卡、场上、墓地是否存在至少1张可以回到卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 获取对方手卡、场上、墓地所有可以回到卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 设置连锁处理的操作信息，声明将对方手卡、场上、墓地的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 10种类效果的效果处理函数
function c98076754.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对方手卡、场上、墓地所有可以回到卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 检查涉及墓地的操作是否会被「王家之谷」的效果无效，若被无效则终止处理
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将目标卡片全部送回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
