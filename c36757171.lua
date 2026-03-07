--ヴェルズ・バハムート
-- 效果：
-- 名字带有「入魔」的4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择对方场上表侧表示存在的1只怪兽才能发动。从手卡丢弃1只名字带有「入魔」的怪兽，得到选择的对方怪兽的控制权。
function c36757171.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足名字带有「入魔」条件的4星怪兽作为素材进行召唤，需要2个素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xa),4,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，选择对方场上表侧表示存在的1只怪兽才能发动。从手卡丢弃1只名字带有「入魔」的怪兽，得到选择的对方怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_HANDES)
	e1:SetDescription(aux.Stringid(36757171,0))  --"获取控制权"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c36757171.cost)
	e1:SetTarget(c36757171.target)
	e1:SetOperation(c36757171.operation)
	c:RegisterEffect(e1)
end
-- 支付效果代价，从自己场上移除1个超量素材
function c36757171.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示且可以改变控制权
function c36757171.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 设置效果目标，检查对方场上是否存在满足条件的怪兽以及自己手牌是否存在满足条件的怪兽
function c36757171.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c36757171.filter(chkc) end
	-- 检查对方场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c36757171.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己手牌是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c36757171.dfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上满足条件的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c36757171.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将改变目标怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置效果处理信息，表示将丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 过滤函数，用于判断手牌是否为名字带有「入魔」的怪兽且可以丢弃
function c36757171.dfilter(c)
	return c:IsSetCard(0xa) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果处理函数，选择并丢弃1张名字带有「入魔」的手牌，然后获得目标怪兽的控制权
function c36757171.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择1张名字带有「入魔」的手牌丢弃
	local g=Duel.SelectMatchingCard(tp,c36757171.dfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 将选择的1张手牌送入墓地
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获得目标怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end
