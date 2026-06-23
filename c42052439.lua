--キリビ・レディ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有战士族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把场上的这张卡送去墓地才能发动。从手卡把1只4星以下的战士族怪兽特殊召唤。这个回合，对方不能把这个效果特殊召唤的怪兽作为效果的对象。
function c42052439.initial_effect(c)
	-- ①：自己场上有战士族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
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
-- 过滤函数，用于判断场上是否存在正面表示的战士族怪兽
function c42052439.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 效果①的发动条件，判断自己场上是否存在至少1只正面表示的战士族怪兽
function c42052439.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在至少1只正面表示的战士族怪兽
	return Duel.IsExistingMatchingCard(c42052439.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动时的处理条件，判断是否满足特殊召唤的条件
function c42052439.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果①的发动信息，表示将要特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理，将此卡从手卡特殊召唤
function c42052439.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡从手卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动代价，将此卡送去墓地作为代价
function c42052439.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于判断手卡中是否存在满足条件的战士族4星以下怪兽
function c42052439.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时的处理条件，判断是否满足特殊召唤的条件
function c42052439.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 判断手卡中是否存在满足条件的战士族4星以下怪兽
		and Duel.IsExistingMatchingCard(c42052439.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果②的发动信息，表示将要从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的发动处理，将手卡中符合条件的战士族4星以下怪兽特殊召唤，并赋予其不能成为对方效果对象的效果
function c42052439.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手卡中满足条件的战士族4星以下怪兽
	local g=Duel.SelectMatchingCard(tp,c42052439.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽特殊召唤到场上
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 为特殊召唤的怪兽添加效果，使其在本回合不能成为对方效果的对象
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		-- 设置效果不能成为对方效果对象的过滤函数
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
