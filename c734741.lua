--彼岸の悪鬼 ラビキャント
-- 效果：
-- 「彼岸的恶鬼 鲁比坎泰」的①的效果1回合只能使用1次。把这张卡作为同调素材的场合，不是「彼岸」怪兽的同调召唤不能使用。
-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
function c734741.initial_effect(c)
	-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c734741.sdcon)
	c:RegisterEffect(e1)
	-- 「彼岸的恶鬼 鲁比坎泰」的①的效果1回合只能使用1次。①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(734741,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,734741)
	e2:SetCondition(c734741.sscon)
	e2:SetTarget(c734741.sstg)
	e2:SetOperation(c734741.ssop)
	c:RegisterEffect(e2)
	-- 把这张卡作为同调素材的场合，不是「彼岸」怪兽的同调召唤不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(c734741.synlimit)
	c:RegisterEffect(e3)
end
-- 限制同调素材只能用于「彼岸」怪兽的同调召唤
function c734741.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0xb1)
end
-- 过滤里侧表示怪兽以及非「彼岸」怪兽
function c734741.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xb1)
end
-- 自我破坏效果的发动条件：检查自己场上是否存在「彼岸」怪兽以外的怪兽
function c734741.sdcon(e)
	-- 检查自己场上是否存在至少1只里侧表示或非「彼岸」的怪兽
	return Duel.IsExistingMatchingCard(c734741.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤魔法·陷阱卡
function c734741.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 特殊召唤效果的发动条件：检查自己场上是否存在魔法·陷阱卡
function c734741.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己场上不存在任何魔法·陷阱卡
	return not Duel.IsExistingMatchingCard(c734741.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤效果的靶向处理，检查自身是否能特殊召唤并设置操作信息
function c734741.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示准备特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行，将自身特殊召唤到场上
function c734741.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
