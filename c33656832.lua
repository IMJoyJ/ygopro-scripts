--曲芸の魔術師
-- 效果：
-- ←2 【灵摆】 2→
-- 「曲芸之魔术师」的灵摆效果1回合只能使用1次。
-- ①：自己场上的怪兽被效果破坏时才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- ①：魔法·陷阱卡的发动无效的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被战斗破坏时才能发动。这张卡在自己的灵摆区域放置。
function c33656832.initial_effect(c)
	-- 为这张卡注册灵摆怪兽的基本属性（可进行灵摆召唤、可在灵摆区域发动等）。
	aux.EnablePendulumAttribute(c)
	-- 「曲芸之魔术师」的灵摆效果1回合只能使用1次。①：自己场上的怪兽被效果破坏时才能发动。灵摆区域的这张卡特殊召唤。
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
-- 筛选条件：判断被破坏的怪兽之前位于主要怪兽区、控制者为tp，且是因效果而被破坏。
function c33656832.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
end
-- 发动条件：被破坏的怪兽中存在至少1只满足“自己场上被效果破坏”条件的怪兽。
function c33656832.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33656832.cfilter,1,nil,tp)
end
-- 效果发动目标判定：需要自己主要怪兽区有空位，且这张卡处于灵摆区域时可以特殊召唤。
function c33656832.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查：自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：宣告本次效果将把这张卡特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与发动时的效果保持关联，则将其特殊召唤。
function c33656832.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到持有者（tp）的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 发动条件：被无效的连锁是魔法·陷阱卡的发动（即对应『魔法·陷阱卡的发动无效的场合』）。
function c33656832.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果发动目标判定：自己的灵摆区域左右两侧中至少有一个空格可用。
function c33656832.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查：自己的灵摆区域（左侧或右侧）有空格。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 效果处理：若这张卡仍与发动时的效果保持关联，则将其移动到自己的灵摆区域。
function c33656832.penop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到己方灵摆区域。
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
