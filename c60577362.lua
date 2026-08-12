--威圧する魔眼
-- 效果：
-- ①：以自己场上1只攻击力2000以下的不死族怪兽为对象才能发动。这个回合，那只怪兽可以直接攻击。
function c60577362.initial_effect(c)
	-- ①：以自己场上1只攻击力2000以下的不死族怪兽为对象才能发动。这个回合，那只怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c60577362.condition)
	e1:SetTarget(c60577362.target)
	e1:SetOperation(c60577362.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件：当前回合玩家能否进入战斗阶段
function c60577362.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否可以进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤条件：自己场上表侧表示、攻击力2000以下的不死族怪兽
function c60577362.filter(c)
	return c:IsFaceup() and c:IsAttackBelow(2000) and c:IsRace(RACE_ZOMBIE)
end
-- 效果发动时的对象选择与合法性检查
function c60577362.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c60577362.filter(chkc) end
	-- 在发动阶段，检查自己场上是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c60577362.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 在客户端显示提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c60577362.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使作为对象的怪兽在当前回合可以直接攻击
function c60577362.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽可以直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
