--ティスティナの猟犬
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有光属性「提斯蒂娜」怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：只要对方场上有里侧守备表示怪兽存在，自己的「提斯蒂娜」怪兽可以直接攻击。
local s,id,o=GetID()
-- 初始化效果的注册函数：为这张卡创建并注册①的特殊召唤起动效果和②的直击永续效果；①效果作为起动效果在手卡·墓地可发动，②效果为场地永续效果，使我方场上表侧表示的「提斯蒂娜」怪兽获得直接攻击能力。
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
	-- 设置直接攻击效果的适用对象：场上的我方怪兽中卡名属于「提斯蒂娜」系列的怪兽才能受到此效果影响。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1a4))
	c:RegisterEffect(e2)
end
-- 定义筛选函数：用于检查场上是否存在表侧表示、光属性且属于「提斯蒂娜」系列的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsSetCard(0x1a4)
end
-- ①效果的发动条件函数：自己场上的主要怪兽区存在至少1只满足 s.cfilter 的光属性「提斯蒂娜」怪兽时才可发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判定：以自己场上的主要怪兽区为范围，检索是否存在至少1只表侧表示的光属性「提斯蒂娜」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果发动时的目标函数：在发动时检查自己场上是否有空余的主要怪兽区，且这张卡是否能够被特殊召唤；满足条件则设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时（chk==0）检查自己场上是否存在可用的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的处理信息：即将进行特殊召唤，对象为这张卡，数量为1，不指定玩家和位置。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理函数：若这张卡仍与效果关联，则将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理特殊召唤：判定这张卡是否仍与当前效果保持关联（未离场或未被重置），若是则将其以表侧表示特殊召唤到自己场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- ②效果的发动条件函数：对方场上存在至少1只里侧守备表示的怪兽时，直接攻击效果适用。
function s.dacon(e)
	-- 具体判定：以对方场上的主要怪兽区为范围，检查是否存在至少1只处于里侧守备表示位置的怪兽。
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil,POS_FACEDOWN_DEFENSE)
end
