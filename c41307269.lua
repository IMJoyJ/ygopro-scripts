--超重武者カブ－10
-- 效果：
-- ①：对方对怪兽的特殊召唤成功的场合才能发动。自己场上的攻击表示的「超重武者」怪兽全部变成守备表示，那个守备力直到回合结束时上升500。
function c41307269.initial_effect(c)
	-- 效果原文内容：①：对方对怪兽的特殊召唤成功的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41307269,0))  --"表示形式变化"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c41307269.condition)
	e1:SetTarget(c41307269.target)
	e1:SetOperation(c41307269.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：检查召唤玩家是否为对方
function c41307269.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 效果作用：判断是否有对方怪兽特殊召唤成功
function c41307269.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c41307269.cfilter,1,nil,tp)
end
-- 效果作用：筛选自己场上攻击表示的「超重武者」怪兽
function c41307269.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSetCard(0x9a) and c:IsCanChangePosition()
end
-- 效果作用：设置效果处理时的目标怪兽组并设置效果分类为表示形式变化
function c41307269.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(c41307269.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 效果作用：获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c41307269.filter,tp,LOCATION_MZONE,0,nil)
	-- 效果作用：设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果原文内容：自己场上的攻击表示的「超重武者」怪兽全部变成守备表示，那个守备力直到回合结束时上升500。
function c41307269.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c41307269.filter,tp,LOCATION_MZONE,0,nil)
	-- 效果作用：将怪兽全部变为守备表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)
	-- 效果作用：获取实际操作的怪兽组
	local og=Duel.GetOperatedGroup()
	local tc=og:GetFirst()
	while tc do
		-- 效果作用：为怪兽增加500守备力直至回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=og:GetNext()
	end
end
