--コアラッコ
-- 效果：
-- 这张卡以外的兽族怪兽在自己场上表侧表示存在的场合，可以把对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时变成0。这个效果1回合只能使用1次。
function c87685879.initial_effect(c)
	-- 这张卡以外的兽族怪兽在自己场上表侧表示存在的场合，可以把对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时变成0。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87685879,0))  --"攻击力变成0"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c87685879.condition)
	e1:SetTarget(c87685879.target)
	e1:SetOperation(c87685879.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且是兽族的怪兽
function c87685879.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- 发动条件：自己场上存在这张卡以外的表侧表示的兽族怪兽
function c87685879.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只这张卡以外的表侧表示的兽族怪兽
	return Duel.IsExistingMatchingCard(c87685879.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果发动时的对象选择与合法性检查
function c87685879.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 在发动效果的准备阶段，检查对方场上是否存在至少1只攻击力不为0的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只攻击力不为0的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：将选择的对方怪兽的攻击力直到结束阶段时变成0
function c87685879.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，再次检查自己场上是否仍存在这张卡以外的表侧表示的兽族怪兽，若不满足则不处理
	if not Duel.IsExistingMatchingCard(c87685879.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then return end
	-- 获取效果发动的目标对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 把对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
	end
end
