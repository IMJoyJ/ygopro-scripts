--拒神ドゥータン
-- 效果：
-- 光属性怪兽＋场上·墓地以外的怪兽×2
-- ①：融合召唤的这张卡不会被战斗破坏。
-- ②：原本卡名和对方的场上·墓地的怪兽相同的怪兽在自己的场上·墓地其中每种之内都不存在的场合，自己场上的怪兽不会被效果破坏。
-- ③：把原本卡名和对方的场上·墓地的怪兽相同的1只怪兽从手卡·卡组·额外卡组送去墓地，以对方的场上·墓地1只怪兽为对象才能发动。那只怪兽除外。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	-- 设置融合召唤条件：以光属性怪兽为融合素材，另外需要2只不在场上或墓地的怪兽作为融合素材
	aux.AddFusionProcFunFun(c,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_LIGHT),aux.FilterBoolFunction(aux.NOT(Card.IsLocation),LOCATION_ONFIELD+LOCATION_GRAVE),2,true)
	c:EnableReviveLimit()
	-- ①：融合召唤的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：原本卡名和对方的场上·墓地的怪兽相同的怪兽在自己的场上·墓地其中每种之内都不存在的场合，自己场上的怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(s.indcon2)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：把原本卡名和对方的场上·墓地的怪兽相同的1只怪兽从手卡·卡组·额外卡组送去墓地，以对方的场上·墓地1只怪兽为对象才能发动。那只怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.rmcost)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 判断是否为融合召唤
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 筛选场上或墓地存在与对方怪兽同名的己方怪兽
function s.cfilter(c,tp)
	-- 检查是否存在与指定卡名相同的对方场上或墓地的怪兽
	return c:IsFaceupEx() and Duel.IsExistingMatchingCard(s.codefilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,c:GetOriginalCode())
end
-- 检查指定卡名的怪兽是否存在于对方场上或墓地
function s.codefilter(c,code)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:GetOriginalCode()==code
end
-- 判断是否满足效果②的发动条件
function s.indcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方场上或墓地不存在与对方怪兽同名的怪兽，则效果②发动
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
end
-- 筛选可作为cost送入墓地的怪兽
function s.cfilter1(c,tp)
	-- 检查是否存在与指定卡名相同的对方场上或墓地的怪兽
	return c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.codefilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,c:GetOriginalCode())
		and c:IsAbleToGraveAsCost()
end
-- 设置效果③的发动cost
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动cost条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,tp) end
	-- 提示玩家选择要送入墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的卡送入墓地
	local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tp)
	-- 将选中的卡送入墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 筛选可除外的怪兽
function s.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 设置效果③的发动target
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 判断是否满足发动target条件
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 从对方场上或墓地选择目标怪兽
	local g=aux.SelectTargetFromFieldFirst(tp,s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息，记录将要除外的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行效果③的除外操作
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
