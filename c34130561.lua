--魔道騎士ガイア
-- 效果：
-- 这个卡名在规则上也当作「暗黑骑士 盖亚」卡使用。这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合或者对方场上有攻击力2300以上的怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只龙族·5星怪兽守备表示特殊召唤。
function c34130561.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合或者对方场上有攻击力2300以上的怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34130561,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c34130561.ntcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只龙族·5星怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34130561,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,34130561)
	e2:SetTarget(c34130561.sptg)
	e2:SetOperation(c34130561.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断对方场上是否存在攻击力2300以上的怪兽。
function c34130561.ntfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2300)
end
-- 召唤条件函数，判断是否满足不用解放作召唤的条件。
function c34130561.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 满足等级5以上且场上存在空位的条件。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 满足己方场上没有怪兽或对方场上存在攻击力2300以上的怪兽的条件。
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsExistingMatchingCard(c34130561.ntfilter,tp,0,LOCATION_MZONE,1,nil))
end
-- 过滤函数，用于筛选龙族5星怪兽。
function c34130561.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的发动时点处理函数，用于判断是否可以发动以及设置操作信息。
function c34130561.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上存在空位且手牌或墓地存在符合条件的龙族5星怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c34130561.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只龙族5星怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤效果的处理函数，用于选择并特殊召唤符合条件的怪兽。
function c34130561.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位，如果没有则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地选择一只符合条件的龙族5星怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c34130561.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以守备表示特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
