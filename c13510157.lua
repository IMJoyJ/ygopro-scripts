--ティスティナの猟犬
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有光属性「提斯蒂娜」怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：只要对方场上有里侧守备表示怪兽存在，自己的「提斯蒂娜」怪兽可以直接攻击。
local s,id,o=GetID()
-- 注册两个效果：①特殊召唤效果和②直接攻击效果
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上有光属性「提斯蒂娜」怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要对方场上有里侧守备表示怪兽存在，自己的「提斯蒂娜」怪兽可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.dacon)
	-- 设置效果2的目标为「提斯蒂娜」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1a4))
	c:RegisterEffect(e2)
end
-- 检查场上是否存在表侧表示的光属性「提斯蒂娜」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsSetCard(0x1a4)
end
-- 判断是否满足效果①的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在表侧表示的光属性「提斯蒂娜」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果①的发动时点和目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行效果①的处理程序
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡是否还在场上，是则特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 判断对方场上有无里侧守备表示怪兽
function s.dacon(e)
	-- 检查对方场上是否存在里侧守备表示的怪兽
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil,POS_FACEDOWN_DEFENSE)
end
