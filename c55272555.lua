--メメント・ホーン・ドラゴン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己墓地有「莫忘」怪兽3种类以上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡被效果破坏的场合，以包含自己场上的「莫忘」卡的场上3张表侧表示卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤规则，②被效果破坏时选择场上3张表侧表示卡破坏的诱发效果。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己墓地有「莫忘」怪兽3种类以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：场上的这张卡被效果破坏的场合，以包含自己场上的「莫忘」卡的场上3张表侧表示卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地的「莫忘」怪兽。
function s.cfilter(c)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER)
end
-- 特殊召唤规则的条件判定：自己场上有怪兽区域空位，且自己墓地存在3种类以上的「莫忘」怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己墓地所有的「莫忘」怪兽。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 判定自己主要怪兽区域有空位，且墓地「莫忘」怪兽的卡名种类在3种以上。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetClassCount(Card.GetCode)>2
end
-- 效果②的发动条件判定：场上的这张卡被效果破坏。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
-- 过滤条件：自己场上表侧表示的「莫忘」卡，且场上还存在另外至少2张可以成为对象的表侧表示卡。
function s.filter(c,tp)
	-- 判定卡片是否为自己场上表侧表示的「莫忘」卡，且场上除其以外还存在至少2张表侧表示的卡。
	return c:IsFaceup() and c:IsSetCard(0x1a1) and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,c)
end
-- 效果②的对象选择与效果处理信息注册。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定是否能选择符合条件的自己场上的「莫忘」卡（作为3张卡中的第1张）。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示的「莫忘」卡作为第1个对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上另外2张表侧表示的卡作为第2、第3个对象。
	local ag=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,g)
	-- 设置效果处理信息：破坏这3张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g+ag,3,0,0)
end
-- 效果②的效果处理：破坏作为对象的卡。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏仍存在于场上的对象卡片。
	Duel.Destroy(Duel.GetTargetsRelateToChain(),REASON_EFFECT)
end
