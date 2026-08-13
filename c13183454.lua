--零鳥姫リオート・ハルピュイア
-- 效果：
-- 鸟兽族5星怪兽×2
-- 把这张卡1个超量素材取除，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力变成0。
function c13183454.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用鸟兽族等级5的怪兽2只作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WINDBEAST),5,2)
	c:EnableReviveLimit()
	-- 把这张卡1个超量素材取除，选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13183454,0))  --"攻击变成0"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c13183454.cost)
	e1:SetTarget(c13183454.target)
	e1:SetOperation(c13183454.operation)
	c:RegisterEffect(e1)
end
-- 发动代价判定与支付：检查这张卡是否至少有1个超量素材可移除，若可以则移除1个超量素材作为发动代价。
function c13183454.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选择对象的过滤条件：必须是表侧表示且当前攻击力大于0的怪兽。
function c13183454.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 效果发动的目标选择处理：从对方场上选择1只表侧表示且攻击力大于0的怪兽作为对象，并登记为效果对象。
function c13183454.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c13183454.filter(chkc) end
	-- 发动条件检查：对方场上是否存在至少1只满足过滤条件（表侧表示且攻击力大于0）的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c13183454.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家显示选择提示信息，提示内容为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示且攻击力大于0的怪兽，并将其设置为当前连锁的效果对象。
	Duel.SelectTarget(tp,c13183454.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：将作为对象的对方怪兽的攻击力变成0，通过赋予其攻击力最终值设定为0的效果来实现，并在该怪兽离开场上等标准状态变化时重置。
function c13183454.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时锁定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()>0 then
		-- 选择的怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
