--インフェルニティ・クイーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在墓地存在，自己手卡是0张的场合，从自己墓地把1只暗属性怪兽除外，以自己场上1只暗属性怪兽为对象才能发动。这个回合，那只怪兽可以直接攻击。
local s,id,o=GetID()
-- 初始化效果：创建并注册"永火王后"的起动效果，设置其描述、类型为起动效果、取对象标志、发动区域为墓地、1回合1次限制，并绑定条件、代价、目标与处理函数后注册到这张卡上。
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在墓地存在，自己手卡是0张的场合，从自己墓地把1只暗属性怪兽除外，以自己场上1只暗属性怪兽为对象才能发动。这个回合，那只怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"直接攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件判断：自己手卡为0张，且当前回合玩家可以进入战斗阶段，满足这些条件时效果才允许发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回条件是否成立：自己的手卡数量为0，且当前允许进入战斗阶段。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 and Duel.IsAbleToEnterBP()
end
-- 代价筛选函数：用于选择除外代价的卡，要求是暗属性怪兽，且能作为代价从墓地除外。
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：确认阶段检查墓地是否存在足够代价；实际发动时提示玩家选择1只暗属性怪兽，并表侧除外作为发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价确认：检查自己墓地是否存在至少1只满足条件的暗属性怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发出选择提示消息，提示内容为"请选择要除外的卡"。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的暗属性怪兽，用于除外的代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽以表侧表示除外，作为发动效果所需支付的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 目标筛选函数：选择自己场上1只表侧表示、暗属性且尚未拥有直接攻击效果的怪兽作为效果对象。
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:GetEffectCount(EFFECT_DIRECT_ATTACK)==0
end
-- 目标处理：作为取对象效果，发动时选择自己场上1只表侧表示暗属性怪兽为对象；连锁处理时也会验证对象是否仍合法。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 目标确认：检查自己场上是否存在至少1只满足条件的表侧表示暗属性怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发出选择提示消息，提示内容为"请选择表侧表示的卡"。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只表侧表示的暗属性怪兽，并将其登记为本次连锁的效果对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取出对象怪兽，若它仍然表侧表示且与效果有关联，则给它赋予"这个回合可以直接攻击"的效果。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁中登记的效果对象怪兽（作为直接攻击效果的适用目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽可以直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
