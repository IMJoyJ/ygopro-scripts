--Sin トゥルース・ドラゴン
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
-- ①：「罪 真实龙」以外的自己场上的表侧表示的「罪」怪兽被战斗·效果破坏的场合，把基本分支付一半才能发动。这张卡从手卡·墓地特殊召唤。
-- ②：「罪」怪兽在场上只能有1只表侧表示存在。
-- ③：没有场地魔法卡表侧表示存在的场合这张卡破坏。
-- ④：这张卡战斗破坏对方怪兽的场合发动。对方场上的表侧表示怪兽全部破坏。
function c37115575.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,c37115575.uqfilter,LOCATION_MZONE)
	-- ①：「罪 真实龙」以外的自己场上的表侧表示的「罪」怪兽被战斗·效果破坏的场合，把基本分支付一半才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37115575,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c37115575.spcon)
	e1:SetCost(c37115575.spcost)
	e1:SetTarget(c37115575.sptg)
	e1:SetOperation(c37115575.spop)
	c:RegisterEffect(e1)
	-- ③：没有场地魔法卡表侧表示存在的场合这张卡破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SELF_DESTROY)
	e7:SetCondition(c37115575.descon)
	c:RegisterEffect(e7)
	-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e8:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为无法特殊召唤，即只能通过效果特殊召唤。
	e8:SetValue(aux.FALSE)
	c:RegisterEffect(e8)
	-- ④：这张卡战斗破坏对方怪兽的场合发动。对方场上的表侧表示怪兽全部破坏。
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(37115575,1))  --"对方表侧表示的怪兽全部破坏"
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e9:SetCategory(CATEGORY_DESTROY)
	e9:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置该效果为仅在与对方怪兽战斗破坏对方怪兽时才能发动。
	e9:SetCondition(aux.bdocon)
	e9:SetTarget(c37115575.detg)
	e9:SetOperation(c37115575.deop)
	c:RegisterEffect(e9)
end
-- 用于判断是否为「罪」系列怪兽，若受75223115效果影响则视为真实龙。
function c37115575.uqfilter(c)
	-- 判断是否受75223115效果影响，若受则视为真实龙。
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),75223115) then
		return c:IsCode(37115575)
	else
		return c:IsSetCard(0x23)
	end
end
-- 用于筛选被破坏的「罪」怪兽，确保其为己方怪兽且非真实龙。
function c37115575.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousSetCard(0x23) and c:GetPreviousCodeOnField()~=37115575 and not c:IsReason(REASON_RULE)
end
-- 判断是否有满足条件的「罪」怪兽被破坏。
function c37115575.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37115575.cfilter,1,nil,tp)
end
-- 支付一半基本分作为发动cost。
function c37115575.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前基本分的一半。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 判断是否满足特殊召唤条件。
function c37115575.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位可特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 设置操作信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作。
function c37115575.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤并完成程序。
	if Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 判断是否没有场地魔法卡在场。
function c37115575.descon(e)
	-- 若无场地魔法卡在场则触发破坏效果。
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 设置破坏效果的目标为对方场上所有表侧表示怪兽。
function c37115575.detg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息为破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作。
function c37115575.deop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因破坏目标怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
