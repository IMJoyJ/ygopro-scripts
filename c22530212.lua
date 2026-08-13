--マジック・ハンド
-- 效果：
-- ①：只在这张卡在场上表侧表示存在才有1次，对方用抽卡以外的方法从卡组把卡加入手卡时才能发动。那卡送去墓地，给与对方800伤害。
function c22530212.initial_effect(c)
	-- ①：只在这张卡在场上表侧表示存在才有1次，对方用抽卡以外的方法从卡组把卡加入手卡时才能发动。那卡送去墓地，给与对方800伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1)
	e1:SetCondition(c22530212.condition)
	e1:SetTarget(c22530212.target)
	e1:SetOperation(c22530212.activate)
	c:RegisterEffect(e1)
end
-- 筛选出从卡组加入手卡且不是抽卡加入的、由对方控制的卡，用于判定触发条件：卡的控制者是对方、之前位置是卡组、且加入手卡的原因不是抽卡。
function c22530212.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
end
-- 检查本次加入手卡的事件组中是否存在至少一张满足条件的卡（即对方用抽卡以外的方法从卡组加入手卡的卡），存在则效果可以发动。
function c22530212.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22530212.cfilter,1,nil,1-tp)
end
-- 效果发动时点：先通过合法性检查，然后选取事件组中所有符合条件的卡（对方从卡组加入手卡的卡）设为对象，并声明将那些卡送去墓地且给对方造成800伤害。
function c22530212.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c22530212.cfilter,nil,1-tp)
	-- 将选定的符合条件的卡登记为当前连锁的处理对象，供效果处理时使用。
	Duel.SetTargetCard(g)
	-- 设置操作信息：本效果包含将这些对象卡送去墓地，targets为这些卡，数量为其张数。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 设置操作信息：本效果包含给对方造成伤害，对象玩家为对方，伤害数值为800。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果处理时，取出之前登记的对象卡并过滤仍与效果相关的卡；若存在，则将它们送去墓地；若那些卡确实被送去墓地，则给对方造成800点伤害。
function c22530212.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的对象卡，并筛选出仍然与该效果相关的卡（没有被无效或失去关联的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=0 then
		-- 将筛选出的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
			-- 给对方玩家造成800点效果伤害。
			Duel.Damage(1-tp,800,REASON_EFFECT)
		end
	end
end
