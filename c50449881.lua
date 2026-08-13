--シャーク・フォートレス
-- 效果：
-- 5星怪兽×2
-- ①：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
function c50449881.initial_effect(c)
	-- 为卡片添加超量召唤手续：用2只等级5的怪兽作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50449881,0))  --"多次攻击"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c50449881.condition)
	e1:SetCost(c50449881.cost)
	e1:SetTarget(c50449881.target)
	e1:SetOperation(c50449881.operation)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c50449881.atlimit)
	c:RegisterEffect(e2)
end
-- 定义②效果的发动条件：当前回合能够进入战斗阶段时才能发动。
function c50449881.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家能否进入战斗阶段，若能则发动条件成立。
	return Duel.IsAbleToEnterBP()
end
-- 定义②效果的发动代价：从这张卡上取除1个超量素材作为发动代价。
function c50449881.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义选择对象的过滤条件：自己场上的表侧表示怪兽，且没有已适用的“增加攻击次数”效果。
function c50449881.filter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 定义②效果的发动目标处理：选择自己场上1只表侧表示怪兽作为效果对象。
function c50449881.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50449881.filter(chkc) end
	-- 发动时确认自己场上是否存在1只满足条件的表侧表示怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c50449881.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送选择表侧表示怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只表侧表示怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c50449881.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义②效果处理时的操作：给对象怪兽附加本回合可以进行2次攻击的效果。
function c50449881.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 定义①效果的攻击对象限制：对方不能选择除这张卡以外的怪兽作为攻击对象。
function c50449881.atlimit(e,c)
	return c~=e:GetHandler()
end
