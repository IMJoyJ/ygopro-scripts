--砂塵のバリア －ダスト・フォース－
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。对方场上的攻击表示怪兽全部变成里侧守备表示。这个效果变成里侧守备表示的怪兽不能把表示形式变更。
function c40838625.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。对方场上的攻击表示怪兽全部变成里侧守备表示。这个效果变成里侧守备表示的怪兽不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c40838625.condition)
	e1:SetTarget(c40838625.target)
	e1:SetOperation(c40838625.activate)
	c:RegisterEffect(e1)
end
-- 规则层面：该函数为效果的发动条件判断，用于确认本效果是否在对方怪兽进行攻击宣言的时点满足发动条件。
function c40838625.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是本卡的控制者（tp），即必须是在对方回合——也就是对方怪兽攻击宣言时，才能满足发动条件。
	return tp~=Duel.GetTurnPlayer()
end
-- 筛选出对方场上攻击表示且当前可以被变为里侧守备表示的怪兽，这些怪兽是本效果可能影响的对象。
function c40838625.filter(c)
	return c:IsAttackPos() and c:IsCanTurnSet()
end
-- 规则层面：发动时的合法性与操作信息登记。先检查是否存在至少1只符合条件的怪兽；若存在，则获取全部符合条件的怪兽并设置操作信息，声明将把这些怪兽变为里侧守备表示。
function c40838625.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）需要确认对方场上存在至少1只攻击表示且可转为里侧守备表示的怪兽，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c40838625.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足过滤条件（攻击表示且可里侧守备）的怪兽组，用于设置操作信息。
	local g=Duel.GetMatchingGroup(c40838625.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，声明本效果将改变怪兽表示形式（CATEGORY_POSITION），对象为g中的所有卡，数量为g:GetCount()。此信息用于连锁处理和效果发动的检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 规则层面：效果处理阶段。重新获取当前符合条件的对方怪兽，将其全部变为里侧守备表示，并对实际被变更的怪兽附加“不能改变表示形式”的持续效果，直到满足标准重置条件。
function c40838625.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上当前满足条件（攻击表示且可里侧守备）的怪兽组，以应对发动后场上状态可能发生的变化。
	local g=Duel.GetMatchingGroup(c40838625.filter,tp,0,LOCATION_MZONE,nil)
	-- 将获取到的所有符合条件的怪兽变为里侧守备表示；若实际变更的数量不为0，则进入后续的附加限制效果处理。这是“对方场上的攻击表示怪兽全部变成里侧守备表示”的规则执行。
	if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
		-- 获取刚才Duel.ChangePosition实际改变了表示形式的怪兽组，这些怪兽才是“这个效果变成里侧守备表示的怪兽”，后续只对这些怪兽附加不能变更表示形式的效果。
		local og=Duel.GetOperatedGroup()
		local tc=og:GetFirst()
		while tc do
			-- 这个效果变成里侧守备表示的怪兽不能把表示形式变更。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=og:GetNext()
		end
	end
end
