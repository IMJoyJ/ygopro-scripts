--共闘
-- 效果：
-- 这张卡发动的回合，自己怪兽不能直接攻击。
-- ①：从手卡丢弃1只怪兽，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成和为这张卡发动而丢弃的怪兽的各自数值相同。
function c31472884.initial_effect(c)
	-- 对应效果原文：这张卡发动的回合，自己怪兽不能直接攻击。①：从手卡丢弃1只怪兽，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时变成和为这张卡发动而丢弃的怪兽的各自数值相同。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件为伤害步骤限制：只能在伤害计算前发动，伤害计算时及之后不能发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c31472884.cost)
	e1:SetTarget(c31472884.target)
	e1:SetOperation(c31472884.activate)
	c:RegisterEffect(e1)
	if not c31472884.global_check then
		c31472884.global_check=true
		-- 对应效果原文：这张卡发动的回合，自己怪兽不能直接攻击。①：从手卡丢弃1只怪兽，以场上1只表侧表示怪兽为对象才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c31472884.check)
		-- 将全局监听攻击宣言的辅助效果注册进决斗，用于检测并记录直接攻击，以配合“这张卡发动的回合，自己怪兽不能直接攻击”的限制。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 攻击宣言时进行检测：若攻击目标是空（直接攻击），则为攻击怪兽的控制者注册标记，供后续限制效果使用。
function c31472884.check(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 判断本次攻击是否没有攻击对象，即是否为直接攻击。
	if Duel.GetAttackTarget()==nil then
		-- 为直接攻击怪兽的控制者注册一个“共斗”相关标记，该标记在结束阶段重置，用于记录本回合已进行过直接攻击。
		Duel.RegisterFlagEffect(tc:GetControler(),31472884,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 定义手卡丢弃代价的筛选函数：需要是怪兽、可以被丢弃、攻击力/守备力数值存在，并且场上存在可选择为对象的面朝上怪兽。
function c31472884.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable() and c:GetAttack()>=0 and c:GetDefense()>=0
		-- 额外确认场上存在满足条件的表侧表示怪兽，确保可以正确选择效果对象。
		and Duel.IsExistingTarget(c31472884.tgfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
-- 定义对象怪兽的筛选条件：表侧表示，并且攻击力或守备力至少有一项与待丢弃怪兽的对应数值不同。
function c31472884.tgfilter(c,dc)
	return c:IsFaceup() and (not c:IsAttack(dc:GetAttack()) or not c:IsDefense(dc:GetDefense()))
end
-- 代价函数：先设置标签为1，表示代价处理逻辑延后到target阶段执行，并返回true允许发动。
function c31472884.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 目标处理函数：实际执行丢弃手卡怪兽、选择场上表侧表示怪兽为对象，并给己方怪兽附加本回合不能直接攻击的誓约效果。
function c31472884.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and c31472884.tgfilter(chkc,e:GetLabelObject()) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查自己是否已经拥有31472884标记（本回合发动过共斗或已有直接攻击记录），用于限制不能重复满足发动条件。
		return Duel.GetFlagEffect(tp,31472884)==0
			-- 检查手卡中是否存在1只满足丢弃条件的怪兽，确保能够支付“从手卡丢弃1只怪兽”的代价。
			and Duel.IsExistingMatchingCard(c31472884.cfilter,tp,LOCATION_HAND,0,1,nil)
	end
	-- 向玩家显示“请选择要丢弃的手牌”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手卡中筛选并选择1只符合条件的怪兽，作为此次发动要丢弃的代价。
	local g=Duel.SelectMatchingCard(tp,c31472884.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽卡以“代价+丢弃”的理由送去墓地，完成丢弃代价。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	-- 向玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c31472884.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g:GetFirst())
	e:SetLabelObject(g:GetFirst())
	-- 对应效果原文：这张卡发动的回合，自己怪兽不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能直接攻击”的誓约效果注册给当前玩家，使该玩家本回合自己场上的怪兽不能直接攻击。
	Duel.RegisterEffect(e1,tp)
end
-- 效果处理：取得被丢弃怪兽的攻击力和守备力，给对象怪兽附加使其攻击力·守备力变成对应数值的直到回合结束的效果。
function c31472884.activate(e,tp,eg,ep,ev,re,r,rp)
	local cc=e:GetLabelObject()
	local atk=cc:GetAttack()
	local def=cc:GetDefense()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 对应效果原文中的攻击力部分：那只怪兽的攻击力·守备力直到回合结束时变成和为这张卡发动而丢弃的怪兽的各自数值相同（本行设置攻击力）。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 对应效果原文中的守备力部分：那只怪兽的攻击力·守备力直到回合结束时变成和为这张卡发动而丢弃的怪兽的各自数值相同（本行设置守备力）。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(def)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
