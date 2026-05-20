--黄昏の交衣
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。选自己墓地的「光道」怪兽任意数量除外，作为对象的怪兽的攻击力·守备力直到回合结束时上升这个效果除外的怪兽数量×200。
-- ②：这张卡被「光道」怪兽的效果从卡组送去墓地的场合才能发动。这个回合，自己场上的「光道」怪兽不会被战斗·效果破坏。
function c83747250.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。选自己墓地的「光道」怪兽任意数量除外，作为对象的怪兽的攻击力·守备力直到回合结束时上升这个效果除外的怪兽数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制该效果在伤害步骤中只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c83747250.target)
	e1:SetOperation(c83747250.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被「光道」怪兽的效果从卡组送去墓地的场合才能发动。这个回合，自己场上的「光道」怪兽不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c83747250.indcon)
	e2:SetOperation(c83747250.indop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地可以除外的「光道」怪兽
function c83747250.filter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果①的发动准备与合法性检测（选择自己场上1只表侧表示怪兽为对象，并确认墓地有可除外的「光道」怪兽）
function c83747250.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在至少1只表侧表示的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查自己墓地是否存在至少1只可以除外的「光道」怪兽
		and Duel.IsExistingMatchingCard(c83747250.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的实际处理逻辑（除外墓地的「光道」怪兽，并提升对象怪兽的攻击力·守备力）
function c83747250.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取自己墓地所有满足条件的「光道」怪兽
	local g=Duel.GetMatchingGroup(c83747250.filter,tp,LOCATION_GRAVE,0,nil)
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and g:GetCount()>0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,1,g:GetCount(),nil)
		-- 将选中的「光道」怪兽表侧表示除外，并获取实际除外的数量
		local rc=Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		-- 作为对象的怪兽的攻击力……直到回合结束时上升这个效果除外的怪兽数量×200
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(200*rc)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 检查这张卡是否是被「光道」怪兽的效果从卡组送去墓地
function c83747250.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK) and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x38)
		and bit.band(r,REASON_EFFECT)~=0
end
-- 效果②的实际处理逻辑（赋予自己场上的「光道」怪兽本回合不会被战斗·效果破坏的抗性）
function c83747250.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己场上的「光道」怪兽不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置抗性效果的影响对象为「光道」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x38))
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册战斗破坏抗性的全局效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 注册效果破坏抗性的全局效果
	Duel.RegisterEffect(e2,tp)
end
