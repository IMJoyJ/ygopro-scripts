--セキュリティ・ブロック
-- 效果：
-- ①：以场上1只电子界族怪兽为对象才能发动。这个回合，那只怪兽不会被战斗破坏，双方受到的全部战斗伤害变成0。
function c91665064.initial_effect(c)
	-- ①：以场上1只电子界族怪兽为对象才能发动。这个回合，那只怪兽不会被战斗破坏，双方受到的全部战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c91665064.target)
	e1:SetOperation(c91665064.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示的电子界族怪兽
function c91665064.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- 效果发动的对象选择与合法性检测
function c91665064.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c91665064.filter(chkc) end
	-- 检查场上是否存在可以作为效果对象的表侧表示电子界族怪兽
	if chk==0 then return Duel.IsExistingTarget(c91665064.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的电子界族怪兽作为效果对象
	Duel.SelectTarget(tp,c91665064.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理，使双方受到的全部战斗伤害变成0，并使作为对象的怪兽在这个回合不会被战斗破坏
function c91665064.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，那只怪兽不会被战斗破坏，双方受到的全部战斗伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，使双方玩家受到的全部战斗伤害变成0
	Duel.RegisterEffect(e1,tp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 这个回合，那只怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	tc:RegisterEffect(e2)
end
