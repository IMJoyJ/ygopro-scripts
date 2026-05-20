--守護神官マハード
-- 效果：
-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡和暗属性怪兽进行战斗的伤害步骤内，这张卡的攻击力变成2倍。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地把1只「黑魔术师」特殊召唤。
function c71703785.initial_effect(c)
	-- 在卡片中注册记载了「黑魔术师」（卡号46986414）的卡片密码。
	aux.AddCodeList(c,46986414)
	-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71703785,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DRAW)
	e1:SetCost(c71703785.spcost)
	e1:SetTarget(c71703785.sptg1)
	e1:SetOperation(c71703785.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡和暗属性怪兽进行战斗的伤害步骤内，这张卡的攻击力变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetCondition(c71703785.atkcon)
	e2:SetValue(c71703785.atkval)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地把1只「黑魔术师」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71703785,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c71703785.spcon2)
	e3:SetTarget(c71703785.sptg2)
	e3:SetOperation(c71703785.spop2)
	c:RegisterEffect(e3)
end
-- 效果①的Cost函数：确认这张卡在手卡且未给对方观看（未公开状态）。
function c71703785.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 效果①的Target函数：检查自身是否能特殊召唤并设置特殊召唤的操作信息。
function c71703785.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的Operation函数：将自身特殊召唤。
function c71703785.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到自己的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的Condition函数：判断是否在伤害步骤（或伤害计算时）且与暗属性怪兽进行战斗。
function c71703785.atkcon(e)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	local bc=e:GetHandler():GetBattleTarget()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and bc and bc:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果②的Value函数：返回自身攻击力的2倍。
function c71703785.atkval(e,c)
	return e:GetHandler():GetAttack()*2
end
-- 效果③的Condition函数：判断是否被战斗或效果破坏。
function c71703785.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 效果③的过滤函数：筛选可以特殊召唤的「黑魔术师」。
function c71703785.spfilter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的Target函数：检查是否有可用怪兽区域以及手卡·卡组·墓地是否存在「黑魔术师」，并设置操作信息。
function c71703785.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡、卡组、墓地是否存在至少1只满足特殊召唤条件的「黑魔术师」。
		and Duel.IsExistingMatchingCard(c71703785.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置从手卡、卡组、墓地特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果③的Operation函数：从手卡·卡组·墓地选择1只「黑魔术师」特殊召唤。
function c71703785.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有可用的怪兽区域空格，若无则返回。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地中选择1只满足条件且不受「王家之谷」影响的「黑魔术师」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c71703785.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
