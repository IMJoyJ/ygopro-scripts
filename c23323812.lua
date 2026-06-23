--念導力
-- 效果：
-- 自己场上表侧表示存在的念动力族怪兽被对方怪兽的攻击破坏的场合才能发动。那个时候进行攻击的1只对方怪兽破坏，自己基本分回复那个攻击力的数值。
function c23323812.initial_effect(c)
	-- 创建效果，设置效果类别为破坏和回复，类型为发动，取对象，触发事件为战斗破坏，条件、目标和发动函数分别为condition、target和activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c23323812.condition)
	e1:SetTarget(c23323812.target)
	e1:SetOperation(c23323812.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查卡是否为己方控制者、正面表示、为攻击目标且为念动力族
function c23323812.filter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
		-- 检查卡是否为攻击目标且为念动力族
		and c==Duel.GetAttackTarget() and c:IsRace(RACE_PSYCHO)
end
-- 条件函数，检查是否有满足filter条件的卡被破坏
function c23323812.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23323812.filter,1,nil,tp)
end
-- 目标函数，设置攻击怪兽为对象，设置破坏和回复的操作信息
function c23323812.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取此次战斗的攻击怪兽
	local at=Duel.GetAttacker()
	if chkc then return chkc==at end
	if chk==0 then return at:IsControler(1-tp) and at:IsRelateToBattle() and at:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为效果对象
	Duel.SetTargetCard(at)
	local atk=at:GetAttack()
	-- 设置操作信息，将攻击怪兽破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,at,1,0,0)
	-- 设置操作信息，使自己回复攻击怪兽攻击力的数值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
end
-- 发动函数，获取效果对象，若对象有效则破坏对象并回复LP
function c23323812.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果对象
	local a=Duel.GetFirstTarget()
	if a:IsRelateToEffect(e) then
		local atk=a:GetAttack()
		-- 破坏对象，若成功则继续执行回复LP
		if Duel.Destroy(a,REASON_EFFECT)~=0 then
			-- 使自己回复对象攻击力的数值
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end
