--蟲惑の落とし穴
-- 效果：
-- ①：这个回合特殊召唤的对方场上的怪兽把效果发动时才能发动。那个效果无效并破坏。
function c29616929.initial_effect(c)
	-- ①：这个回合特殊召唤的对方场上的怪兽把效果发动时才能发动。那个效果无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c29616929.condition)
	e1:SetTarget(c29616929.target)
	e1:SetOperation(c29616929.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：当前连锁的效果由对方玩家在怪兽区发动，且发动效果的那只怪兽在本回合被特殊召唤过，并且该效果可以被无效。
function c29616929.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果控制者及其发动位置（怪兽区）。
	local tgp,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	local tc=re:GetHandler()
	-- 判断是否满足发动条件：效果控制者为对方、发动位置为怪兽区、发动效果的怪兽持有本回合特殊召唤状态，且该连锁效果可被无效。
	return tgp==1-tp and loc==LOCATION_MZONE and tc:IsStatus(STATUS_SPSUMMON_TURN) and Duel.IsChainDisablable(ev)
end
-- 效果发动时：确认发动合法后，设定无效该连锁效果的操作信息；若发动效果的怪兽可被破坏且仍与效果关联，则同时设定破坏该怪兽的操作信息。
function c29616929.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁处理包含‘使效果无效’这一分类，对象为当前发动的效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若该效果怪兽可被破坏且与连锁效果相关，则追加‘破坏’分类，对象为发动效果的怪兽。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先无效该连锁的效果，若成功且效果怪兽仍与效果相关，则将其破坏。
function c29616929.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若该连锁效果已被成功无效，且发动效果的怪兽仍与那个效果保持关联（未离场或重置），则继续处理破坏。
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏发动效果的那组怪兽（即诱发这次连锁的怪兽）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
