--マジック・ハンド
-- 效果：
-- ①：只在这张卡在场上表侧表示存在才有1次，对方用抽卡以外的方法从卡组把卡加入手卡时才能发动。那卡送去墓地，给与对方800伤害。
function c22530212.initial_effect(c)
	-- 效果原文内容：①：只在这张卡在场上表侧表示存在才有1次，对方用抽卡以外的方法从卡组把卡加入手卡时才能发动。那卡送去墓地，给与对方800伤害。
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
-- 检索满足条件的卡片组：检查目标卡片是否为对方控制、来自卡组、且不是通过抽卡方式加入手牌
function c22530212.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
end
-- 判断连锁是否满足发动条件：确认是否有对方通过非抽卡方式从卡组加入手牌的卡片
function c22530212.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22530212.cfilter,1,nil,1-tp)
end
-- 设置效果处理的目标和操作信息：设定要送去墓地的卡片组和给对方造成800伤害
function c22530212.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c22530212.cfilter,nil,1-tp)
	-- 将目标卡片设置为当前连锁处理对象
	Duel.SetTargetCard(g)
	-- 设置操作信息：将目标卡片送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 设置操作信息：给与对方800伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果发动时的处理函数：获取目标卡片并执行送去墓地和造成伤害的操作
function c22530212.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被指定的目标卡片，并筛选出与当前效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=0 then
		-- 将目标卡片以效果原因送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
			-- 给与对方800伤害
			Duel.Damage(1-tp,800,REASON_EFFECT)
		end
	end
end
