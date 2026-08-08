--特異点の悪魔
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：对方把怪兽特殊召唤时，从手卡把这张卡和1张魔法卡丢弃才能发动。那些怪兽破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册对方特殊召唤怪兽时手卡舍弃自身与1张魔法卡破坏那些怪兽的效果
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：对方把怪兽特殊召唤时，从手卡把这张卡和1张魔法卡丢弃才能发动。那些怪兽破坏。
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
-- 特殊召唤玩家过滤：确认怪兽是否由对方特殊召唤
function s.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 发动条件：对方有怪兽特殊召唤成功
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- Cost过滤条件：手卡可以丢弃的魔法卡
function s.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- Cost检查：自身可以丢弃且手卡存在至少1张可丢弃的魔法卡
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and
		-- 检查手卡是否存在除自身以外可丢弃的魔法卡
		Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选择1张魔法卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 作为代价将自身与选中的魔法卡一并从手卡丢弃
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 破坏目标过滤：对方特殊召唤成功且存在于怪兽区的怪兽
function s.desfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and (not e or c:IsRelateToEffect(e))
		and c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_MZONE)
end
-- 发动准备：选择对方特殊召唤的怪兽并设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.desfilter,1,nil,nil,tp) end
	local g=eg:Filter(s.desfilter,nil,nil,tp)
	-- 设置特殊召唤的怪兽为效果的影响对象
	Duel.SetTargetCard(eg)
	-- 设置连锁操作信息：破坏那些特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：将对方特殊召唤的怪兽破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.desfilter,nil,e,tp):Filter(Card.IsRelateToChain,nil)
	-- 破坏选中的对方特殊召唤的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
