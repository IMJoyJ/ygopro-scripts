--炎舞－「天璇」
-- 效果：
-- 这张卡的发动时，选择自己场上1只兽战士族怪兽。选择的怪兽的攻击力直到结束阶段时上升700。此外，只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升300。
function c44920699.initial_effect(c)
	-- 这张卡的发动时，选择自己场上1只兽战士族怪兽。选择的怪兽的攻击力直到结束阶段时上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件：仅在伤害步骤内且尚未进行伤害计算时才能发动（与EFFECT_FLAG_DAMAGE_STEP配合，允许在伤害步骤发动但限制伤害计算后不可发动）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c44920699.target)
	e1:SetOperation(c44920699.activate)
	c:RegisterEffect(e1)
	-- 此外，只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置持续效果的适用对象：我方场上的兽战士族怪兽（攻击力上升300的对象）。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR))
	e3:SetValue(300)
	c:RegisterEffect(e3)
end
-- 定义筛选条件：卡片须为表侧表示且种族为兽战士族。
function c44920699.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR)
end
-- 发动时的目标选择函数：校验并选取自己场上1只表侧表示兽战士族怪兽作为效果对象。
function c44920699.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c44920699.filter(chkc) end
	-- 效果发动合法性检查：确认自己场上是否存在至少1只满足条件的表侧兽战士族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c44920699.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只表侧兽战士族怪兽，并将其设为当前连锁的效果对象。
	Duel.SelectTarget(tp,c44920699.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽，若其仍与效果相关且为表侧表示，则赋予其攻击力上升700的持续效果直到结束阶段。
function c44920699.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽（第一张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的攻击力直到结束阶段时上升700。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(700)
		tc:RegisterEffect(e1)
	end
end
