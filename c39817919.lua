--霊魂鳥－忍鴉
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：1回合1次，这张卡和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，从手卡丢弃1只灵魂怪兽才能发动。这张卡的攻击力·守备力直到战斗阶段结束时上升丢弃的怪兽的攻击力·守备力的各自数值。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c39817919.initial_effect(c)
	-- 为该卡添加在召唤或反转时回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：1回合1次，这张卡和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，从手卡丢弃1只灵魂怪兽才能发动。这张卡的攻击力·守备力直到战斗阶段结束时上升丢弃的怪兽的攻击力·守备力的各自数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39817919,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c39817919.atkcon)
	e2:SetTarget(c39817919.atkcost)
	e2:SetOperation(c39817919.atkop)
	c:RegisterEffect(e2)
end
-- 判断是否满足效果发动条件：当前阶段为伤害步骤且未计算战斗伤害，且该卡参与了战斗
function c39817919.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local phase=Duel.GetCurrentPhase()
	-- 若当前阶段不是伤害步骤或战斗伤害已计算，则效果不满足发动条件
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取本次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽不是自己控制，则获取防守怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	-- 返回是否为该卡参与战斗且战斗目标存在
	return tc==e:GetHandler() and tc:IsRelateToBattle() and Duel.GetAttackTarget()~=nil
end
-- 定义筛选手牌中可丢弃的灵魂怪兽的过滤函数
function c39817919.cfilter(c)
	return c:IsType(TYPE_SPIRIT) and (c:GetAttack()>0 or c:GetDefense()>0) and c:IsDiscardable()
end
-- 处理效果发动的费用：选择并丢弃一只满足条件的灵魂怪兽
function c39817919.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的灵魂怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c39817919.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家发送提示信息，提示选择丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的1只灵魂怪兽
	local g=Duel.SelectMatchingCard(tp,c39817919.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 将选中的灵魂怪兽送入墓地作为发动效果的代价
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 执行效果的处理：将丢弃怪兽的攻击力和守备力加到该卡上
function c39817919.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local atk=math.max(tc:GetAttack(),0)
	local def=math.max(tc:GetDefense(),0)
	if c:IsRelateToBattle() and c:IsFaceup() and c:IsControler(tp) then
		-- 将该卡的攻击力提升至丢弃怪兽的攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(def)
		c:RegisterEffect(e2)
	end
end
