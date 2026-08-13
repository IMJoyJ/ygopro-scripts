--バトルマニア
-- 效果：
-- 对方回合的准备阶段时才能发动。对方场上表侧表示存在的怪兽全部变成攻击表示，这个回合表示形式不能改变。此外，这个回合可以攻击的对方怪兽必须作出攻击。
function c31245780.initial_effect(c)
	-- 对方回合的准备阶段时才能发动。对方场上表侧表示存在的怪兽全部变成攻击表示，这个回合表示形式不能改变。此外，这个回合可以攻击的对方怪兽必须作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	e1:SetCondition(c31245780.condition)
	e1:SetTarget(c31245780.target)
	e1:SetOperation(c31245780.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件的判定函数：检查当前是否为对方回合的准备阶段（非自己的回合且处于准备阶段），满足才可发动。
function c31245780.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 条件表达式：当前回合玩家不是本卡发动者（即对方回合）且当前阶段为准备阶段时返回真。
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()==PHASE_STANDBY
end
-- 目标选择/操作信息设定函数：效果发动时确认对方场上有表侧表示怪兽存在，并收集这些怪兽作为后续改变表示形式的对象。
function c31245780.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：若对方场上不存在表侧表示怪兽，则效果不能发动（返回false）；否则可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上全部表侧表示怪兽集合，准备作为效果处理对象。
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 向系统登记本次效果将改变表示形式（CATEGORY_POSITION），对象为已选择的对方表侧怪兽，数量为怪兽总数。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- 效果处理函数：将对方场上表侧表示怪兽全部变为攻击表示；给每只怪兽附加“必须攻击”和“不能改变表示形式”效果，并打上标记；所有这些效果持续到回合结束。
function c31245780.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时重新获取对方场上当前存在的表侧表示怪兽（以实际处理时的场上情况为准）。
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		-- 将对象怪兽全部改为表侧攻击表示（保持表侧，若已是表侧攻击则不变）。
		Duel.ChangePosition(sg,POS_FACEUP_ATTACK,0,POS_FACEUP_ATTACK,0)
		local tc=sg:GetFirst()
		while tc do
			-- 这个回合可以攻击的对方怪兽必须作出攻击。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_MUST_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 这个回合表示形式不能改变。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			tc:RegisterFlagEffect(31245780,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			tc=sg:GetNext()
		end
	end
end
-- 过滤函数：判断某怪兽是否带有本回合战斗狂的标记且处于可攻击状态，用于强制攻击效果的后续判定。
function c31245780.befilter(c)
	return c:GetFlagEffect(31245780)~=0 and c:IsAttackable()
end
