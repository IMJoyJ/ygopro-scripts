--No.94 極氷姫クリスタル・ゼロ
-- 效果：
-- 水属性5星怪兽×2
-- ①：把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到自己回合的结束时变成一半。这个效果在对方回合也能发动。
function c62070231.initial_effect(c)
	-- 设置XYZ召唤手续：水属性5星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),5,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到自己回合的结束时变成一半。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62070231,0))  --"攻击变成一半"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件：在伤害步骤中，只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c62070231.cost)
	e1:SetTarget(c62070231.target)
	e1:SetOperation(c62070231.operation)
	c:RegisterEffect(e1)
end
-- 记录该怪兽的“No.”编号为94
aux.xyz_number[62070231]=94
-- 效果发动的代价：检查并取除这张卡的1个超量素材
function c62070231.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时的目标选择：选择场上1只表侧表示的怪兽作为对象
function c62070231.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1只表侧表示怪兽并将其作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使作为对象的怪兽的攻击力直到自己回合的结束时变成一半
function c62070231.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到自己回合的结束时变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		-- 判断当前是否为对方回合，以确定攻击力减半效果的持续回合数（直到自己回合的结束时）
		if Duel.GetTurnPlayer()~=tp then
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		else
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		end
		tc:RegisterEffect(e1)
	end
end
