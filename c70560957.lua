--トゥーン・ロールバック
-- 效果：
-- ①：以自己场上1只卡通怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
function c70560957.initial_effect(c)
	-- ①：以自己场上1只卡通怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c70560957.condition)
	e1:SetTarget(c70560957.target)
	e1:SetOperation(c70560957.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查当前回合玩家是否能够进入战斗阶段
function c70560957.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否可以进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤条件：自己场上表侧表示、属于卡通类型且未拥有追加攻击效果的怪兽
function c70560957.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 效果发动时的目标选择与合法性检查
function c70560957.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c70560957.filter(chkc) end
	-- 在发动阶段（chk==0）检查自己场上是否存在至少1只符合条件的卡通怪兽
	if chk==0 then return Duel.IsExistingTarget(c70560957.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的卡通怪兽作为效果的对象
	Duel.SelectTarget(tp,c70560957.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使作为对象的怪兽在这个回合可以作2次攻击
function c70560957.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
