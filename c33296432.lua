--教導の天啓アディン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡不会被和从额外卡组特殊召唤的怪兽的战斗破坏。
-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。从卡组把「教导的天启 阿东」以外的1只「教导」怪兽特殊召唤。
function c33296432.initial_effect(c)
	-- ①：从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33296432,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,33296432)
	e1:SetCondition(c33296432.spcon)
	e1:SetTarget(c33296432.sptg)
	e1:SetOperation(c33296432.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被和从额外卡组特殊召唤的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c33296432.indes)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。从卡组把「教导的天启 阿东」以外的1只「教导」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33296432,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,33296433)
	e3:SetCondition(c33296432.spcon2)
	e3:SetTarget(c33296432.sptg2)
	e3:SetOperation(c33296432.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：判断怪兽是否是从额外卡组特殊召唤的，用于筛选场上存在的这类怪兽。
function c33296432.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- ①的发动条件：双方场上存在至少1只从额外卡组特殊召唤的怪兽。
function c33296432.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方主要怪兽区中是否存在至少1只从额外卡组特殊召唤的怪兽。
	return Duel.IsExistingMatchingCard(c33296432.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ①发动时的合法性判定：确认自己主要怪兽区有空位，且这张卡自身可以被特殊召唤；通过后登记操作信息。
function c33296432.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定阶段（chk==0）：自己的主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本连锁的操作信息登记为“特殊召唤这张卡”（数量为1），用于其他卡的对应判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与当前效果有关联，则将其从手卡特殊召唤到自己场上。
function c33296432.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以表侧表示将这张卡特殊召唤到我方主要怪兽区，并按通常特殊召唤手续进行合法性检查。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②的战斗破坏抗性判定：战斗对象怪兽是从额外卡组特殊召唤的场合，这张卡不会被那次战斗破坏。
function c33296432.indes(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- ③的发动条件：这张卡被战斗或效果破坏，且破坏前位于场上。
function c33296432.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ③的检索/特召对象过滤：属于「教导」字段、不是「教导的天启 阿东」自身、且可以被特殊召唤。
function c33296432.spfilter(c,e,tp)
	return c:IsSetCard(0x145) and not c:IsCode(33296432) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③发动时的合法性判定：自己主要怪兽区有空位，且卡组存在符合条件的「教导」怪兽；通过后登记操作信息。
function c33296432.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定阶段（chk==0）：自己的主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中存在至少1只满足spfilter条件的「教导」怪兽，可作为特殊召唤对象。
		and Duel.IsExistingMatchingCard(c33296432.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本连锁的操作信息登记为“从卡组特殊召唤1只怪兽”（对象在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：若仍有怪兽区空位，则提示玩家从卡组选择1只符合条件的「教导」怪兽并特殊召唤。
function c33296432.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时安全判定：若我方主要怪兽区已无空位，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选出1只满足spfilter条件的「教导」怪兽，此选择发生在效果处理时，不取对象。
	local g=Duel.SelectMatchingCard(tp,c33296432.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到我方主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
