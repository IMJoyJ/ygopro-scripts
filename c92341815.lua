--星空蝶
-- 效果：
-- 自己场上的怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：「星空蝶」在自己场上只能有1张表侧表示存在。
-- ②：对方场上的怪兽的攻击力下降自己场上的有「勇者衍生物」的衍生物名记述的怪兽种类×500。
-- ③：这张卡被送去墓地的场合，以自己场上1只「勇者衍生物」为对象才能发动。那只自己怪兽把这张卡装备。
function c92341815.initial_effect(c)
	-- 在卡片关联卡片列表中添加「勇者衍生物」的卡片密码
	aux.AddCodeList(c,3285552)
	c:SetUniqueOnField(1,0,92341815)
	-- 自己场上的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c92341815.target)
	e1:SetOperation(c92341815.activate)
	c:RegisterEffect(e1)
	-- 自己场上的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c92341815.eqlimit)
	c:RegisterEffect(e2)
	-- ②：对方场上的怪兽的攻击力下降自己场上的有「勇者衍生物」的衍生物名记述的怪兽种类×500。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c92341815.atkval)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合，以自己场上1只「勇者衍生物」为对象才能发动。那只自己怪兽把这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,92341815)
	e4:SetTarget(c92341815.eqtg)
	e4:SetOperation(c92341815.eqop)
	c:RegisterEffect(e4)
end
-- 装备魔法卡发动时的对象选择与操作信息设置
function c92341815.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 选择自己场上1只表侧表示怪兽作为装备对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备效果的操作信息，将所选怪兽作为装备目标
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- 装备魔法卡发动时的效果处理
function c92341815.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 限制装备卡只能装备在自己场上的怪兽上
function c92341815.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer())
end
-- 过滤自己场上表侧表示且记述有「勇者衍生物」卡名的怪兽
function c92341815.atkfilter(c)
	-- 检查怪兽是否表侧表示且其效果文本中记述有「勇者衍生物」的卡名
	return c:IsFaceup() and aux.IsCodeListed(c,3285552)
end
-- 计算对方场上怪兽攻击力下降的数值
function c92341815.atkval(e)
	-- 获取自己场上所有满足条件的记述有「勇者衍生物」的怪兽
	local g=Duel.GetMatchingGroup(c92341815.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)*-500
end
-- 过滤自己场上表侧表示的「勇者衍生物」
function c92341815.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 墓地效果发动时的对象选择与操作信息设置
function c92341815.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c92341815.cfilter(chkc) and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	local c=e:GetHandler()
	-- 检查自己场上是否存在可以作为对象的「勇者衍生物」
	if chk==0 then return Duel.IsExistingTarget(c92341815.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查魔法与陷阱区域是否有空位，且该卡在场上是否满足唯一存在限制
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「勇者衍生物」作为装备对象
	local g=Duel.SelectTarget(tp,c92341815.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备效果的操作信息，将这张卡作为要装备的卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	-- 设置离开墓地效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 墓地效果的处理，将自身从墓地装备给目标「勇者衍生物」
function c92341815.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法与陷阱区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取发动时选择的「勇者衍生物」对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) and c:CheckUniqueOnField(tp) then
		-- 将这张卡作为装备卡装备给目标「勇者衍生物」
		Duel.Equip(tp,c,tc)
	end
end
