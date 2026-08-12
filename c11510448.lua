--十二獣タイグリス
-- 效果：
-- 4星怪兽×3
-- 「十二兽 虎炮」1回合1次也能在同名卡以外的自己场上的「十二兽」怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只超量怪兽和自己墓地1只「十二兽」怪兽为对象才能发动。那只「十二兽」怪兽在那只超量怪兽下面重叠作为超量素材。
function c11510448.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,3,c11510448.ovfilter,aux.Stringid(11510448,0),3,c11510448.xyzop)  --"是否在「十二兽」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c11510448.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c11510448.defval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只超量怪兽和自己墓地1只「十二兽」怪兽为对象才能发动。那只「十二兽」怪兽在那只超量怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11510448,1))  --"补充超量素材"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c11510448.cost)
	e3:SetTarget(c11510448.target)
	e3:SetOperation(c11510448.operation)
	c:RegisterEffect(e3)
end
-- 判断怪兽是否为「十二兽」卡组且不是此卡的函数
function c11510448.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf1) and not c:IsCode(11510448)
end
-- 超量召唤时的处理函数
function c11510448.xyzop(e,tp,chk)
	-- 检查是否已使用过此卡效果
	if chk==0 then return Duel.GetFlagEffect(tp,11510448)==0 end
	-- 注册此卡效果已使用的标识
	Duel.RegisterFlagEffect(tp,11510448,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 判断怪兽是否为「十二兽」卡组且攻击力非负的函数
function c11510448.atkfilter(c)
	return c:IsSetCard(0xf1) and c:GetAttack()>=0
end
-- 计算此卡攻击力的函数
function c11510448.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c11510448.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end
-- 判断怪兽是否为「十二兽」卡组且守备力非负的函数
function c11510448.deffilter(c)
	return c:IsSetCard(0xf1) and c:GetDefense()>=0
end
-- 计算此卡守备力的函数
function c11510448.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c11510448.deffilter,nil)
	return g:GetSum(Card.GetDefense)
end
-- 支付效果代价的函数
function c11510448.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 判断是否为超量怪兽的函数
function c11510448.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 判断是否为可叠放的「十二兽」怪兽的函数
function c11510448.filter2(c)
	return c:IsSetCard(0xf1) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 设置效果目标的函数
function c11510448.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断场上是否存在超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c11510448.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 判断墓地是否存在「十二兽」怪兽
		and Duel.IsExistingTarget(c11510448.filter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示对方此卡效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示选择超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(11510448,2))  --"请选择1只超量怪兽"
	-- 选择场上一只超量怪兽作为目标
	Duel.SelectTarget(tp,c11510448.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示选择作为超量素材的墓地怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	-- 选择墓地一只「十二兽」怪兽作为目标
	local g=Duel.SelectTarget(tp,c11510448.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，表示将有怪兽从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 判断怪兽是否可叠放的函数
function c11510448.opfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsCanOverlay()
end
-- 执行效果操作的函数
function c11510448.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc1=g:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
	local g2=g:Filter(c11510448.opfilter,nil)
	if tc1 and tc1:IsFaceup() and not tc1:IsImmuneToEffect(e) and g2:GetCount()>0 then
		-- 将目标怪兽叠放至目标超量怪兽上
		Duel.Overlay(tc1,g2)
	end
end
