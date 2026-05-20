--破壊輪
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方回合，以持有对方基本分数值以下的攻击力的对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽破坏，自己受到那只怪兽的原本攻击力数值的伤害。那之后，给与对方为和自己受到的伤害相同数值的伤害。
function c83555666.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方回合，以持有对方基本分数值以下的攻击力的对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽破坏，自己受到那只怪兽的原本攻击力数值的伤害。那之后，给与对方为和自己受到的伤害相同数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,83555666+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c83555666.condition)
	e1:SetTarget(c83555666.target)
	e1:SetOperation(c83555666.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，限制只能在对方回合发动
function c83555666.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 定义过滤条件：表侧表示且攻击力小于等于指定生命值的怪兽
function c83555666.filter(c,lp)
	return c:IsFaceup() and c:IsAttackBelow(lp)
end
-- 定义效果的目标选择（Target）函数
function c83555666.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取对方玩家的当前生命值
	local lp=Duel.GetLP(1-tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c83555666.filter(chkc,lp) end
	-- 在发动阶段（chk==0）检查场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c83555666.filter,tp,0,LOCATION_MZONE,1,nil,lp) end
	-- 在客户端显示“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1只符合条件的对方怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c83555666.filter,tp,0,LOCATION_MZONE,1,1,nil,lp)
	-- 向系统注册破坏该怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 向系统注册造成伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- 定义效果的处理（Operation）函数
function c83555666.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关且呈表侧表示，并将其破坏
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 对自己造成等同于该怪兽原本攻击力的伤害，并记录实际受到的伤害数值
		local val=Duel.Damage(tp,atk,REASON_EFFECT)
		-- 若自己成功受到伤害且自己的生命值仍大于0，则继续处理后续效果
		if val>0 and Duel.GetLP(tp)>0 then
			-- 中断当前效果处理的时点，使前后的破坏/伤害与后续的伤害不视为同时处理
			Duel.BreakEffect()
			-- 给与对方与自己受到的伤害相同数值的伤害
			Duel.Damage(1-tp,val,REASON_EFFECT)
		end
	end
end
