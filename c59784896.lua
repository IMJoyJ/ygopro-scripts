--ダークゼブラ
-- 效果：
-- 自己的准备阶段时，自己控制的怪兽只有这张卡的场合，这张卡变成守备表示。那个回合表示形式不能变更。
function c59784896.initial_effect(c)
	-- 自己的准备阶段时，自己控制的怪兽只有这张卡的场合，这张卡变成守备表示。那个回合表示形式不能变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59784896,0))  --"变成守备表示"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c59784896.condition)
	e1:SetTarget(c59784896.target)
	e1:SetOperation(c59784896.operation)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件函数，用于判断是否满足在自己的准备阶段且自己场上只有1只怪兽
function c59784896.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否为当前回合玩家的回合，且自己怪兽区域的卡数量等于1
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 定义效果的发动目标函数，由于是必发效果，直接返回true并设置改变表示形式的操作信息
function c59784896.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：将自身改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 定义效果的处理函数，将自身变为表侧守备表示并施加本回合不能变更表示形式的效果
function c59784896.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍受效果影响且处于表侧攻击表示，则将其变为表侧守备表示
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)~=0 then
		-- 那个回合表示形式不能变更。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
