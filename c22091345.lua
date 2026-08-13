--EMスパイク・イーグル
-- 效果：
-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c22091345.initial_effect(c)
	-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22091345,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(c22091345.condition)
	e1:SetTarget(c22091345.target)
	e1:SetOperation(c22091345.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：该效果必须在当前回合玩家可以进入战斗阶段时才能发动，即满足进入战斗阶段的条件下才允许发动此效果。
function c22091345.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段，若不能则效果无法发动。
	return Duel.IsAbleToEnterBP()
end
-- 对象筛选：选择自己场上表侧表示且未具备贯穿效果（EFFECT_PIERCE）的怪兽，确保对象合法且不重复赋予贯穿。
function c22091345.filter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_PIERCE)
end
-- 发动前的目标选择处理：确认存在可选择的怪兽后，提示玩家选择自己场上1只表侧表示的怪兽作为对象。
function c22091345.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 『chk==0』时检查场上是否存在至少1只满足条件的表侧表示怪兽，作为发动效果的合法性条件。
	if chk==0 then return Duel.IsExistingTarget(c22091345.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示信息，让玩家从表侧表示怪兽中选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 执行选择操作，让玩家选择自己场上1只满足条件（表侧且无贯穿）的怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c22091345.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽，若其仍与效果关联，则赋予它贯穿战斗伤害的效果，在本回合内生效。
function c22091345.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时记录的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
