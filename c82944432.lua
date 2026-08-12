--機甲忍者ブレード・ハート
-- 效果：
-- 战士族4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只「忍者」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
function c82944432.initial_effect(c)
	-- 设置XYZ召唤手续：战士族4星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只「忍者」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82944432,0))  --"2次攻击"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c82944432.condition)
	e1:SetCost(c82944432.cost)
	e1:SetTarget(c82944432.target)
	e1:SetOperation(c82944432.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：当前回合玩家能够进入战斗阶段
function c82944432.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 效果发动代价：取除这张卡的1个超量素材
function c82944432.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：自己场上表侧表示、属于「忍者」系列且未拥有追加攻击效果的怪兽
function c82944432.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2b) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 效果发动目标：选择自己场上1只表侧表示的「忍者」怪兽作为对象
function c82944432.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c82944432.filter(chkc) end
	-- 检查自己场上是否存在符合条件的「忍者」怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c82944432.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只符合条件的「忍者」怪兽并将其设为效果对象
	Duel.SelectTarget(tp,c82944432.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使作为对象的怪兽在这个回合的战斗阶段中可以作2次攻击
function c82944432.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的目标对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
