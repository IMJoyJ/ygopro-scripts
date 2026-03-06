--ダイガスタ・フェニクス
-- 效果：
-- 2星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择自己场上表侧表示存在的1只风属性怪兽才能发动。这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。
function c2766877.initial_effect(c)
	-- 为卡片添加等级为2、需要2只怪兽进行叠放的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，选择自己场上表侧表示存在的1只风属性怪兽才能发动。这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2766877,0))  --"两次攻击"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c2766877.condition)
	e1:SetCost(c2766877.cost)
	e1:SetTarget(c2766877.target)
	e1:SetOperation(c2766877.operation)
	c:RegisterEffect(e1)
end
-- 检查回合玩家能否进入战斗阶段
function c2766877.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 支付效果的代价，移除1个超量素材
function c2766877.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选满足条件的风属性怪兽（表侧表示且未拥有额外攻击效果）
function c2766877.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 选择目标怪兽，要求为表侧表示的风属性怪兽
function c2766877.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2766877.filter(chkc) end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c2766877.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c2766877.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将额外攻击效果应用到目标怪兽上，使其在本回合可进行2次攻击
function c2766877.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
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
