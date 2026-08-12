--光の聖剣ダンネル
-- 效果：
-- 自己场上的怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：「光之圣剑 丹内尔」在自己场上只能有1张表侧表示存在。
-- ②：装备怪兽的攻击力上升自己场上的有「勇者衍生物」的衍生物名记述的怪兽种类×500。
-- ③：这张卡被送去墓地的场合，以自己场上1只「勇者衍生物」为对象才能发动。那只自己怪兽把这张卡装备。
function c65952776.initial_effect(c)
	-- 注册卡片效果中记述了「勇者衍生物」的卡片密码
	aux.AddCodeList(c,3285552)
	c:SetUniqueOnField(1,0,65952776)
	-- 自己场上的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c65952776.target)
	e1:SetOperation(c65952776.activate)
	c:RegisterEffect(e1)
	-- 自己场上的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c65952776.eqlimit)
	c:RegisterEffect(e2)
	-- ②：装备怪兽的攻击力上升自己场上的有「勇者衍生物」的衍生物名记述的怪兽种类×500。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c65952776.atkval)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合，以自己场上1只「勇者衍生物」为对象才能发动。那只自己怪兽把这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,65952776)
	e4:SetTarget(c65952776.eqtg)
	e4:SetOperation(c65952776.eqop)
	c:RegisterEffect(e4)
end
-- 装备魔法卡发动时的目标选择与检测函数
function c65952776.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 选择自己场上1只表侧表示怪兽作为装备对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁处理中的操作信息为装备该怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- 装备魔法卡发动时的效果处理函数
function c65952776.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备限制函数，限制只能装备在自己场上的怪兽上
function c65952776.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer())
end
-- 过滤自己场上表侧表示且效果文本记述了「勇者衍生物」的怪兽
function c65952776.atkfilter(c)
	-- 检查怪兽是否表侧表示且效果文本记述了「勇者衍生物」
	return c:IsFaceup() and aux.IsCodeListed(c,3285552)
end
-- 计算攻击力上升值的函数
function c65952776.atkval(e)
	-- 获取自己场上所有满足条件的记述了「勇者衍生物」的怪兽
	local g=Duel.GetMatchingGroup(c65952776.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)*500
end
-- 过滤自己场上表侧表示的「勇者衍生物」
function c65952776.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 墓地效果发动时的目标选择与检测函数
function c65952776.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c65952776.cfilter(chkc) and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	local c=e:GetHandler()
	-- 检查自己场上是否存在可以作为对象的「勇者衍生物」
	if chk==0 then return Duel.IsExistingTarget(c65952776.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查魔陷区是否有空位，且这张卡在场上是否满足唯一存在限制
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「勇者衍生物」作为装备对象
	local g=Duel.SelectTarget(tp,c65952776.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁处理中的操作信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	-- 设置连锁处理中的操作信息为这张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 墓地效果发动时的效果处理函数
function c65952776.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔陷区是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取作为装备目标的「勇者衍生物」
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) and c:CheckUniqueOnField(tp) then
		-- 将墓地的这张卡装备给目标「勇者衍生物」
		Duel.Equip(tp,c,tc)
	end
end
