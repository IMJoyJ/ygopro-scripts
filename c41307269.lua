--超重武者カブ－10
-- 效果：
-- ①：对方对怪兽的特殊召唤成功的场合才能发动。自己场上的攻击表示的「超重武者」怪兽全部变成守备表示，那个守备力直到回合结束时上升500。
function c41307269.initial_effect(c)
	-- ①：对方对怪兽的特殊召唤成功的场合才能发动。自己场上的攻击表示的「超重武者」怪兽全部变成守备表示，那个守备力直到回合结束时上升500。
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
-- 判断怪兽是否由对方玩家特殊召唤，用于筛选特殊召唤成功事件中的怪兽。
function c41307269.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 发动条件：对方对怪兽的特殊召唤成功，即特殊召唤的怪兽中存在由对方玩家特殊召唤的怪兽。
function c41307269.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c41307269.cfilter,1,nil,tp)
end
-- 过滤函数：筛选自己场上表侧攻击表示、属于「超重武者」字段且可以改变表示形式的怪兽。
function c41307269.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSetCard(0x9a) and c:IsCanChangePosition()
end
-- 效果发动时的目标处理：确认存在符合条件的怪兽，并取得全部符合条件的怪兽组，登记为改变表示形式的操作信息。
function c41307269.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己场上是否存在至少1只表侧攻击表示且属于「超重武者」字段并能改变表示形式的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c41307269.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有符合条件的「超重武者」怪兽（表侧攻击表示且可改变表示形式）组成怪兽组。
	local g=Duel.GetMatchingGroup(c41307269.filter,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息：本次效果将改变这些怪兽的表示形式，数量为怪兽组内怪兽数，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：将自己场上所有符合条件的攻击表示「超重武者」怪兽变成守备表示，并对实际改变了表示形式的怪兽赋予守备力上升500直到回合结束。
function c41307269.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取符合条件的怪兽组（因为处理时场上情况可能变化）。
	local g=Duel.GetMatchingGroup(c41307269.filter,tp,LOCATION_MZONE,0,nil)
	-- 将攻击表示的怪兽全部变为守备表示（表侧攻击表示变为表侧守备表示，里侧攻击表示变为里侧守备表示）。
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)
	-- 获取刚刚实际被改变表示形式的怪兽组，即成功变成守备表示的怪兽。
	local og=Duel.GetOperatedGroup()
	local tc=og:GetFirst()
	while tc do
		-- 那个守备力直到回合结束时上升500。
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
