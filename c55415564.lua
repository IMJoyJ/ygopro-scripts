--DDイービル
-- 效果：
-- ←8 【灵摆】 8→
-- ①：只在这张卡在灵摆区域存在才有1次，对方对怪兽的灵摆召唤成功时才能发动。这个回合，那些灵摆召唤的怪兽不能攻击，效果无效化。
-- 【怪兽效果】
-- 这个卡名的②的怪兽效果1回合只能使用1次。
-- ①：自己场上没有其他的「DD」怪兽存在的场合，这张卡不能攻击。
-- ②：对方主要阶段，以对方场上1只灵摆召唤的怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
function c55415564.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：只在这张卡在灵摆区域存在才有1次，对方对怪兽的灵摆召唤成功时才能发动。这个回合，那些灵摆召唤的怪兽不能攻击，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetCondition(c55415564.discon1)
	e1:SetTarget(c55415564.distg1)
	e1:SetOperation(c55415564.disop1)
	c:RegisterEffect(e1)
	-- ①：自己场上没有其他的「DD」怪兽存在的场合，这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(c55415564.atcon)
	c:RegisterEffect(e2)
	-- ②：对方主要阶段，以对方场上1只灵摆召唤的怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(55415564,1))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,55415564)
	e4:SetCondition(c55415564.discon2)
	e4:SetTarget(c55415564.distg2)
	e4:SetOperation(c55415564.disop2)
	c:RegisterEffect(e4)
end
-- 过滤对方灵摆召唤成功的怪兽
function c55415564.disfilter1(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM) and (not e or c:IsRelateToEffect(e))
end
-- 检查是否满足灵摆效果①的发动条件：对方对怪兽的灵摆召唤成功
function c55415564.discon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c55415564.disfilter1,1,nil,nil,tp)
end
-- 灵摆效果①的发动准备：设置召唤成功的怪兽为效果处理的对象
function c55415564.distg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前召唤成功的怪兽群设为效果处理的对象
	Duel.SetTargetCard(eg)
end
-- 灵摆效果①的效果处理：使那些灵摆召唤的怪兽在这个回合不能攻击且效果无效化
function c55415564.disop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=eg:Filter(c55415564.disfilter1,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		-- 这个回合，那些灵摆召唤的怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 过滤自己场上表侧表示的「DD」怪兽
function c55415564.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf)
end
-- 检查是否满足怪兽效果①的生效条件：自己场上没有其他的「DD」怪兽存在
function c55415564.atcon(e)
	-- 检查自己场上是否存在除自身以外的表侧表示「DD」怪兽，若不存在则返回true
	return not Duel.IsExistingMatchingCard(c55415564.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 检查是否满足怪兽效果②的发动条件：对方主要阶段
function c55415564.discon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 检查当前是否为对方回合的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤对方场上可以被无效效果的灵摆召唤的怪兽
function c55415564.disfilter2(c)
	-- 检查怪兽是否为未被无效效果的效果怪兽，且是通过灵摆召唤出场的
	return aux.NegateMonsterFilter(c) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 怪兽效果②的发动准备：选择对方场上1只灵摆召唤的怪兽作为对象
function c55415564.distg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c55415564.disfilter2(chkc) end
	-- 检查对方场上是否存在至少1只符合条件的灵摆召唤的怪兽
	if chk==0 then return Duel.IsExistingTarget(c55415564.disfilter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送“选择要无效的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择对方场上1只符合条件的灵摆召唤的怪兽作为对象
	local g=Duel.SelectTarget(tp,c55415564.disfilter2,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表示该效果包含“使效果无效”的操作，对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 怪兽效果②的效果处理：使作为对象的怪兽的效果直到回合结束时无效
function c55415564.disop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与该怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
