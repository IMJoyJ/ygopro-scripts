--キリビ・レディ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有战士族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把场上的这张卡送去墓地才能发动。从手卡把1只4星以下的战士族怪兽特殊召唤。这个回合，对方不能把这个效果特殊召唤的怪兽作为效果的对象。
function c42052439.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上有战士族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42052439,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,42052439)
	e1:SetCondition(c42052439.spcon1)
	e1:SetTarget(c42052439.sptg1)
	e1:SetOperation(c42052439.spop1)
	c:RegisterEffect(e1)
	-- ②：把场上的这张卡送去墓地才能发动。从手卡把1只4星以下的战士族怪兽特殊召唤。这个回合，对方不能把这个效果特殊召唤的怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42052439,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,42052440)
	e2:SetCost(c42052439.spcost2)
	e2:SetTarget(c42052439.sptg2)
	e2:SetOperation(c42052439.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示且种族为战士族，用于①效果的发动条件检测。
function c42052439.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- ①效果的发动条件判定：检查自己场上是否存在至少1张表侧表示的战士族怪兽。
function c42052439.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（我方主要怪兽区）是否存在至少1张满足cfilter条件的表侧表示战士族怪兽。
	return Duel.IsExistingMatchingCard(c42052439.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果发动时合法性检查：自己场上怪兽区存在空格，且这张卡自身可被特殊召唤。
function c42052439.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己场上主要怪兽区是否有可用空格用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：预声明本效果将特殊召唤这张卡，供后续连锁判定（如星尘龙等）使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联（未被无效/离场），将其表侧表示特殊召唤到自己场上。
function c42052439.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到自己场上（正常检查召唤条件和苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动代价：将场上的这张卡送去墓地，作为发动COST。
function c42052439.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 以COST形式将这张卡送去墓地（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数：选择手卡中等级4以下、种族为战士族且能够被特殊召唤的怪兽。
function c42052439.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时合法性检查：考虑将这张卡作为COST送墓后场上仍有怪兽区空格，且手卡存在满足条件的战士族怪兽。
function c42052439.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查将这张卡送去墓地后自己场上可用的怪兽区空格数是否大于0。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 同时检查手卡中是否存在至少1张满足spfilter条件的4星以下战士族怪兽。
		and Duel.IsExistingMatchingCard(c42052439.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：声明本效果将把手卡中的1只怪兽特殊召唤（目标在处理时选择，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理：若怪兽区仍有空位，从手卡选择1只4星以下的战士族怪兽特殊召唤，并赋予其‘对方不能作为效果对象’的保护效果持续到回合结束。
function c42052439.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上主要怪兽区有空位（防止处理前区域被占满）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向玩家显示选择提示消息‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡中选择1只满足spfilter条件的怪兽（4星以下、战士族、可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c42052439.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选择成功且特殊召唤成功（返回不为0），则继续执行给该怪兽附加保护效果；否则不处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个回合，对方不能把这个效果特殊召唤的怪兽作为效果的对象。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		-- 设置该保护效果的判定函数，使特殊召唤的怪兽不会被对方选择为效果对象（对方效果指定它时被禁止）。
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
