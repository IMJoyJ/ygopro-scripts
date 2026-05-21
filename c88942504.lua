--管魔人メロメロメロディ
-- 效果：
-- 3星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择自己场上1只名字带有「魔人」的超量怪兽才能发动。这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。
function c88942504.initial_effect(c)
	-- 设置超量召唤手续：3星怪兽×2
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，选择自己场上1只名字带有「魔人」的超量怪兽才能发动。这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88942504,0))  --"多次攻击"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c88942504.condition)
	e1:SetCost(c88942504.cost)
	e1:SetTarget(c88942504.target)
	e1:SetOperation(c88942504.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：必须能够进入战斗阶段
function c88942504.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否能够进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 定义效果发动代价：把这张卡1个超量素材取除
function c88942504.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义过滤条件：自己场上表侧表示、名字带有「魔人」的超量怪兽，且当前未拥有追加攻击效果
function c88942504.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x6d) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 定义效果发动目标：选择自己场上1只名字带有「魔人」的超量怪兽
function c88942504.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c88942504.filter(chkc) end
	-- 在发动阶段，检查自己场上是否存在符合条件的「魔人」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c88942504.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择并锁定自己场上1只符合条件的「魔人」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c88942504.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果处理：使选择的怪兽在同1次的战斗阶段中可以作2次攻击
function c88942504.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
