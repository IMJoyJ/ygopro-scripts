--フォース・リゾネーター
-- 效果：
-- 把自己场上表侧表示存在的这张卡送去墓地，选择自己场上表侧表示存在的1只怪兽发动。这个回合，选择的怪兽攻击的场合，对方直到伤害步骤结束时不能把以怪兽为对象的魔法·陷阱·效果怪兽的效果发动。
function c40583194.initial_effect(c)
	-- 创建一个起动效果，效果描述为“效果抑制”，该效果为取对象效果，类型为起动效果，发动位置在主要怪兽区，需要支付将自身送去墓地的代价，选择自己场上表侧表示存在的1只怪兽作为对象，发动时使该怪兽攻击时对方不能发动以怪兽为对象的魔法·陷阱·效果怪兽的效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40583194,0))  --"效果抑制"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c40583194.cost)
	e1:SetTarget(c40583194.target)
	e1:SetOperation(c40583194.operation)
	c:RegisterEffect(e1)
end
-- 支付效果的代价，检查自身是否能作为送去墓地的代价
function c40583194.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为支付代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 选择自己场上表侧表示存在的1只怪兽作为效果对象
function c40583194.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查自己场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动，为选择的怪兽注册一个永续效果，使其在该怪兽攻击时，对方不能发动以怪兽为对象的魔法·陷阱·效果怪兽的效果
function c40583194.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个永续效果，使对方不能选择以怪兽为对象的魔法·陷阱·效果怪兽的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SELECT_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,0xff)
		e1:SetValue(c40583194.etarget)
		e1:SetCondition(c40583194.limcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断效果对象是否为怪兽卡，且处于表侧表示或在主要怪兽区
function c40583194.etarget(e,re,c)
	return c:IsType(TYPE_MONSTER) and (c:IsFaceup() or c:IsLocation(LOCATION_MZONE))
end
-- 判断当前攻击的怪兽是否为该效果的持有者
function c40583194.limcon(e)
	-- 判断当前攻击的怪兽是否为该效果的持有者
	return Duel.GetAttacker()==e:GetHandler()
end
