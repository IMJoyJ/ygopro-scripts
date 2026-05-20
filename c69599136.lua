--底なし落とし穴
-- 效果：
-- ①：对方对怪兽的召唤·反转召唤·特殊召唤成功时才能发动。那些怪兽变成里侧守备表示。这个效果变成里侧守备表示的怪兽不能把表示形式变更。
function c69599136.initial_effect(c)
	-- ①：对方对怪兽的召唤·反转召唤·特殊召唤成功时才能发动。那些怪兽变成里侧守备表示。这个效果变成里侧守备表示的怪兽不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c69599136.target)
	e1:SetOperation(c69599136.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e3:SetTarget(c69599136.target2)
	c:RegisterEffect(e3)
end
-- 过滤出对方召唤·反转召唤·特殊召唤成功的表侧表示且可以转为里侧表示的怪兽
function c69599136.filter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(1-tp) and c:IsCanTurnSet()
end
-- 召唤·特殊召唤成功时的效果发动目标确认与设置，检查并筛选出对方召唤·特殊召唤成功的怪兽作为效果处理对象
function c69599136.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c69599136.filter,1,nil,tp) end
	local g=eg:Filter(c69599136.filter,nil,tp)
	-- 将符合条件的怪兽群设置为当前连锁的效果处理对象
	Duel.SetTargetCard(g)
end
-- 反转召唤成功时的效果发动目标确认与设置，检查并筛选出对方反转召唤成功的怪兽作为效果处理对象
function c69599136.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return rp==1-tp and tc:IsFaceup() and tc:IsCanTurnSet() end
	-- 将反转召唤成功的怪兽设置为当前连锁的效果处理对象
	Duel.SetTargetCard(tc)
end
-- 效果处理的核心逻辑，将作为对象的怪兽变成里侧守备表示，并使这些怪兽不能变更表示形式
function c69599136.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象怪兽变成里侧守备表示，并判断是否有怪兽成功改变了表示形式
	if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
		-- 获取本次操作中实际改变了表示形式的怪兽卡片组
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
