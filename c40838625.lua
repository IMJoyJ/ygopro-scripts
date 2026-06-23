--砂塵のバリア －ダスト・フォース－
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。对方场上的攻击表示怪兽全部变成里侧守备表示。这个效果变成里侧守备表示的怪兽不能把表示形式变更。
function c40838625.initial_effect(c)
	-- 创建效果，设置效果分类为改变表示形式和盖放怪兽，效果类型为发动，触发事件为攻击宣言时，条件为对方怪兽攻击宣言时，目标为对方场上的攻击表示怪兽，效果处理为将对方场上的攻击表示怪兽变为里侧守备表示并使其不能改变表示形式
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c40838625.condition)
	e1:SetTarget(c40838625.target)
	e1:SetOperation(c40838625.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：当前回合玩家不是效果发动者
function c40838625.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽的攻击宣言时才能发动
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤函数：检查是否为攻击表示且可以变为里侧表示的怪兽
function c40838625.filter(c)
	return c:IsAttackPos() and c:IsCanTurnSet()
end
-- 设置效果目标：检查对方场上是否存在至少1只攻击表示的怪兽，若存在则将这些怪兽设为效果处理对象
function c40838625.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只攻击表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c40838625.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有攻击表示且可以变为里侧表示的怪兽组
	local g=Duel.GetMatchingGroup(c40838625.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，将要处理的怪兽设为对方场上的攻击表示怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理函数：将对方场上的攻击表示怪兽变为里侧守备表示，并为这些怪兽附加不能改变表示形式的效果
function c40838625.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有攻击表示且可以变为里侧表示的怪兽组
	local g=Duel.GetMatchingGroup(c40838625.filter,tp,0,LOCATION_MZONE,nil)
	-- 将怪兽变为里侧守备表示，若成功则继续处理
	if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
		-- 获取实际被改变表示形式的怪兽组
		local og=Duel.GetOperatedGroup()
		local tc=og:GetFirst()
		while tc do
			-- 不能把表示形式变更
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=og:GetNext()
		end
	end
end
