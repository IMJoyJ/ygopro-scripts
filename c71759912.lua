--ラッコアラ
-- 效果：
-- 这张卡以外的兽族怪兽在自己场上表侧表示存在的场合，可以把自己场上表侧表示存在的1只怪兽的攻击力直到结束阶段时上升1000。这个效果1回合只能使用1次。
function c71759912.initial_effect(c)
	-- 这张卡以外的兽族怪兽在自己场上表侧表示存在的场合，可以把自己场上表侧表示存在的1只怪兽的攻击力直到结束阶段时上升1000。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71759912,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c71759912.condition)
	e1:SetTarget(c71759912.target)
	e1:SetOperation(c71759912.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的兽族怪兽
function c71759912.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- 效果发动条件：自己场上存在自身以外的表侧表示兽族怪兽
function c71759912.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只自身以外的表侧表示兽族怪兽
	return Duel.IsExistingMatchingCard(c71759912.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果发动目标：选择自己场上1只表侧表示的怪兽为对象
function c71759912.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查自己场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使选择的怪兽攻击力直到结束阶段时上升1000
function c71759912.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍存在自身以外的表侧表示兽族怪兽，若不存在则不处理效果
	if not Duel.IsExistingMatchingCard(c71759912.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then return end
	-- 获取已选择的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 攻击力直到结束阶段时上升1000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
