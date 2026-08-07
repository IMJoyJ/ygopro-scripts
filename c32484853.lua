--特異点の悪魔
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：对方把怪兽特殊召唤时，从手卡把这张卡和1张魔法卡丢弃才能发动。那些怪兽破坏。
local s,id,o=GetID()
-- 注册卡片初始化效果：对方把怪兽特殊召唤时，从手牌丢弃自身和1张魔法卡发动，将那些特殊召唤的怪兽破坏。
function s.initial_effect(c)
	-- ①：对方把怪兽特殊召唤时，从手卡把这张卡和1张魔法卡丢弃才能发动。那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏特殊召唤的怪兽"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
-- 特殊召唤玩家过滤函数：检查怪兽是否由对方玩家特殊召唤。
function s.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 效果发动条件检查函数：检查当前特殊召唤的怪兽中是否存在由对方特殊召唤的怪兽。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 手牌Cost魔法卡过滤函数：检查卡片是否为魔法卡且能从手牌丢弃。
function s.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 效果发动Cost检查函数：检查自身可丢弃且手牌中存在除自身外可丢弃的魔法卡。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and
		-- 检查自己手牌中是否存在至少1张除自身以外的可以丢弃的魔法卡。
		Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 弹出提示要求玩家选择要送去墓地的魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌选择1张除自身以外的魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将自身及选中的魔法卡作为cost从手牌丢弃送去墓地。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 破坏目标怪兽过滤函数：检查怪兽是否由对方特殊召唤且位于怪兽区域（与效果有联系）。
function s.desfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and (not e or c:IsRelateToEffect(e))
		and c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_MZONE)
end
-- 效果目标选择函数：检查是否存在对方特殊召唤的怪兽，将那些怪兽设为连锁对象并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.desfilter,1,nil,nil,tp) end
	local g=eg:Filter(s.desfilter,nil,nil,tp)
	-- 将当前特殊召唤的怪兽设为连锁的对象。
	Duel.SetTargetCard(eg)
	-- 设置当前连锁的操作信息为破坏那些特殊召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理函数：将与连锁有联系的对方特殊召唤的怪兽全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.desfilter,nil,e,tp):Filter(Card.IsRelateToChain,nil)
	-- 将符合条件的对方特殊召唤的怪兽破坏送去墓地。
	Duel.Destroy(g,REASON_EFFECT)
end
