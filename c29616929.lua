--蟲惑の落とし穴
-- 效果：
-- ①：这个回合特殊召唤的对方场上的怪兽把效果发动时才能发动。那个效果无效并破坏。
function c29616929.initial_effect(c)
	-- 效果原文内容：①：这个回合特殊召唤的对方场上的怪兽把效果发动时才能发动。那个效果无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c29616929.condition)
	e1:SetTarget(c29616929.target)
	e1:SetOperation(c29616929.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断连锁是否满足发动条件，即对方在主要怪兽区特殊召唤的怪兽发动效果
function c29616929.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的发动玩家和发动位置
	local tgp,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	local tc=re:GetHandler()
	-- 效果作用：判断连锁发动玩家为对方、发动位置在主要怪兽区、发动怪兽为本回合特殊召唤且该连锁可被无效
	return tgp==1-tp and loc==LOCATION_MZONE and tc:IsStatus(STATUS_SPSUMMON_TURN) and Duel.IsChainDisablable(ev)
end
-- 效果作用：设置连锁处理时的操作信息，包括使效果无效和破坏目标怪兽
function c29616929.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置使连锁效果无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：设置破坏连锁目标怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果作用：执行连锁效果无效并破坏目标怪兽的操作
function c29616929.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断连锁效果是否成功无效且目标怪兽仍存在于场上
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 效果作用：将目标怪兽以效果原因破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
