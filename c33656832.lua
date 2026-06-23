--曲芸の魔術師
-- 效果：
-- ←2 【灵摆】 2→
-- 「曲芸之魔术师」的灵摆效果1回合只能使用1次。
-- ①：自己场上的怪兽被效果破坏时才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- ①：魔法·陷阱卡的发动无效的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被战斗破坏时才能发动。这张卡在自己的灵摆区域放置。
function c33656832.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以灵摆召唤和作为灵摆卡发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的怪兽被效果破坏时才能发动。灵摆区域的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,33656832)
	e1:SetCondition(c33656832.spcon)
	e1:SetTarget(c33656832.sptg)
	e1:SetOperation(c33656832.spop)
	c:RegisterEffect(e1)
	-- ①：魔法·陷阱卡的发动无效的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c33656832.spcon2)
	e2:SetTarget(c33656832.sptg)
	e2:SetOperation(c33656832.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗破坏时才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetTarget(c33656832.pentg)
	e3:SetOperation(c33656832.penop)
	c:RegisterEffect(e3)
end
-- 用于判断被破坏的怪兽是否在自己场上且是因效果破坏
function c33656832.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
end
-- 判断是否有满足条件的怪兽被破坏（即是否满足灵摆效果发动条件）
function c33656832.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33656832.cfilter,1,nil,tp)
end
-- 设置特殊召唤的条件：场上是否有空位且该卡可以被特殊召唤
function c33656832.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将该卡特殊召唤到场上
function c33656832.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡以正面表示形式特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断是否为魔法或陷阱卡的发动被无效
function c33656832.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断灵摆区域是否有空位可用于放置该卡
function c33656832.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 执行将该卡移动到灵摆区域的操作
function c33656832.penop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将该卡移动到自己的灵摆区域并正面表示
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
