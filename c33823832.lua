--EMファイア・マフライオ
-- 效果：
-- ←5 【灵摆】 5→
-- ①：自己场上的灵摆怪兽被战斗破坏时才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- ①：1回合1次，自己的灵摆怪兽战斗破坏对方怪兽的伤害计算后才能发动。那只自己怪兽直到战斗阶段结束时攻击力上升200，只再1次可以继续攻击。
function c33823832.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的灵摆怪兽被战斗破坏时才能发动。灵摆区域的这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33823832,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c33823832.spcon)
	e2:SetTarget(c33823832.sptg)
	e2:SetOperation(c33823832.spop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，自己的灵摆怪兽战斗破坏对方怪兽的伤害计算后才能发动。那只自己怪兽直到战斗阶段结束时攻击力上升200，只再1次可以继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33823832,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c33823832.cacon)
	e3:SetOperation(c33823832.caop)
	c:RegisterEffect(e3)
end
-- 过滤器函数，用于判断被破坏的怪兽是否为灵摆怪兽且来自己方场上
function c33823832.cfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 条件函数，判断是否有己方灵摆怪兽在战斗中被破坏
function c33823832.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33823832.cfilter,1,nil,tp)
end
-- 设置特殊召唤的条件，检查是否有足够的场上空位和该卡是否可以被特殊召唤
function c33823832.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有足够的空位用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将该卡从灵摆区域特殊召唤到己方场上
function c33823832.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡以正面表示的形式特殊召唤到己方场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 条件函数，判断是否满足灵摆怪兽战斗破坏对方怪兽的条件
function c33823832.cacon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取当前攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if a:IsStatus(STATUS_OPPO_BATTLE) and d:IsControler(tp) then a,d=d,a end
	if a:IsType(TYPE_PENDULUM)
		and not a:IsStatus(STATUS_BATTLE_DESTROYED) and d:IsStatus(STATUS_BATTLE_DESTROYED) then
		e:SetLabelObject(a)
		return true
	else return false end
end
-- 执行灵摆怪兽战斗破坏对方怪兽后的效果，使该怪兽攻击力上升200并可再攻击一次
function c33823832.caop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToBattle() then
		-- 创建攻击力增加200的效果，并在战斗阶段结束时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		if tc:IsChainAttackable() then
			-- 使攻击怪兽可以再进行一次攻击
			Duel.ChainAttack()
		end
	end
end
