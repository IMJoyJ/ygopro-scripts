--CNo.65 裁断魔王ジャッジ・デビル
-- 效果：
-- 暗属性3星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力下降1000。
-- ②：这张卡有「No.65 裁断魔人」在作为超量素材的场合，得到以下效果。
-- ●只要这张卡在怪兽区域存在，对方场上的怪兽不能把效果发动。
function c49195710.initial_effect(c)
	-- 为这张卡设置XYZ召唤手续：需要3只暗属性3星怪兽作为超量素材。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),3,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49195710,0))  --"攻守下降"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c49195710.cost)
	e1:SetTarget(c49195710.target)
	e1:SetOperation(c49195710.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡有「No.65 裁断魔人」在作为超量素材的场合，得到以下效果。●只要这张卡在怪兽区域存在，对方场上的怪兽不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c49195710.accon)
	c:RegisterEffect(e2)
end
-- 将该卡登记为No.65，用于No.卡相关规则判定（如No.卡互相战斗/效果的特殊限制）。
aux.xyz_number[49195710]=65
-- 效果发动代价的处理：检查这张卡有1个超量素材可移除；实际发动时移除这张卡的1个超量素材。
function c49195710.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 对象筛选函数：判断卡片是否为表侧表示。
function c49195710.filter(c)
	return c:IsFaceup()
end
-- 效果发动时的取对象处理：验证指定对象是对方场上表侧表示怪兽；无指定对象时检查是否存在合法对象；然后提示玩家选择对方场上1只表侧表示怪兽，并将其设为效果对象。
function c49195710.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c49195710.filter(chkc) end
	-- 发动合法性检查：确认对方场上至少存在1只表侧表示怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c49195710.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给操作玩家显示“请选择表侧表示的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方怪兽区域选择1只表侧表示怪兽作为效果对象，并将该对象登记到当前连锁。
	Duel.SelectTarget(tp,c49195710.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时：取得对象怪兽，若它仍表侧表示且与效果关联，则给它附加攻击力、守备力下降1000的效果（直到离场等标准重置）。
function c49195710.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中登记的效果对象（即被选中的那只对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力·守备力下降1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- ②效果的适用条件：检查这张卡的超量素材中是否存在「No.65 裁断魔人」（卡号3790062）；满足时对方怪兽不能发动效果。
function c49195710.accon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,3790062)
end
