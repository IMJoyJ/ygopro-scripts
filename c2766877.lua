--ダイガスタ・フェニクス
-- 效果：
-- 2星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择自己场上表侧表示存在的1只风属性怪兽才能发动。这个回合，选择的怪兽在同1次的战斗阶段中可以作2次攻击。
function c2766877.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以任意2只等级2的怪兽作为超量素材进行XYZ召唤。
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
-- 定义效果发动条件：仅当当前回合玩家能够进入战斗阶段时才能发动该效果。
function c2766877.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家能否进入战斗阶段，作为效果发动的前置判定。
	return Duel.IsAbleToEnterBP()
end
-- 定义代价处理：确认这张卡有1个超量素材可作为代价后，实际取除1个超量素材（作为发动费用）。
function c2766877.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义对象过滤器：选择自己场上表侧表示的风属性怪兽，且该怪兽不带有『增加攻击次数』效果，防止重复赋予。
function c2766877.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 定义目标选择流程：校验指定对象是否合法，检查是否存在可选择的怪兽，并提示玩家从自己场上选择1只表侧表示的风属性怪兽作为效果对象。
function c2766877.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2766877.filter(chkc) end
	-- 发动合法性检查：确认自己场上有至少1只满足条件的表侧风属性怪兽可供选择，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c2766877.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示选择提示，提示语为『请选择表侧表示的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作玩家从自己场上选择1只符合条件的表侧风属性怪兽，并将其设为该连锁的效果对象。
	Duel.SelectTarget(tp,c2766877.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得目标怪兽，若其仍与效果关联，则赋予其额外攻击次数+1的效果，使该怪兽本回合战斗阶段可攻击2次。
function c2766877.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时对应的目标怪兽（即被选择的那只风属性怪兽）。
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
