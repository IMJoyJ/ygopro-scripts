--サイバー・エタニティ・ドラゴン
-- 效果：
-- 「电子龙」怪兽＋机械族怪兽×2
-- ①：只要自己墓地有机械族融合怪兽存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ②：融合召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地把1只「电子龙」特殊召唤。
-- ③：把墓地的这张卡除外才能发动。这个回合中，自己场上的融合怪兽不会被对方的效果破坏，对方不能把那些作为效果的对象。
function c82315403.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤素材为1只「电子龙」怪兽和2只机械族怪兽
	aux.AddFusionProcFunFun(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1093),aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),2,true)
	-- ①：只要自己墓地有机械族融合怪兽存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c82315403.indcon)
	-- 设定为不能成为对方卡的效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设定为不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：融合召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地把1只「电子龙」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82315403,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c82315403.spcon)
	e3:SetTarget(c82315403.sptg)
	e3:SetOperation(c82315403.spop)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外才能发动。这个回合中，自己场上的融合怪兽不会被对方的效果破坏，对方不能把那些作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(82315403,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	-- 发动代价：把墓地的这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetOperation(c82315403.operation)
	c:RegisterEffect(e4)
end
c82315403.material_setcode=0x1093
-- 过滤条件：机械族融合怪兽
function c82315403.cfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE)
end
-- 效果①的生效条件：自己墓地存在机械族融合怪兽
function c82315403.indcon(e)
	-- 检查自己墓地是否存在至少1只满足过滤条件的卡（机械族融合怪兽）
	return Duel.IsExistingMatchingCard(c82315403.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
-- 效果②的发动条件：融合召唤的这张卡因对方被送去墓地
function c82315403.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 过滤条件：卡名为「电子龙」且可以特殊召唤的怪兽
function c82315403.spfilter(c,e,tp)
	return c:IsCode(70095154) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（检查怪兽区域是否有空位，以及手卡、卡组、墓地是否存在可以特殊召唤的「电子龙」）
function c82315403.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡、卡组、墓地是否存在至少1只满足过滤条件的「电子龙」
		and Duel.IsExistingMatchingCard(c82315403.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 声明效果处理为从手卡、卡组、墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的效果处理：从手卡、卡组、墓地选择1只「电子龙」特殊召唤
function c82315403.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可以特殊召唤怪兽的空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地选择1只不受「王家长眠之谷」影响的「电子龙」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c82315403.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的效果处理：本回合中，自己场上的融合怪兽获得抗性
function c82315403.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，自己场上的融合怪兽不会被对方的效果破坏，对方不能把那些作为效果的对象。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c82315403.efftg)
	-- 设定为不能成为对方卡的效果的对象
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该不能成为效果对象的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设定为不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	-- 注册该不会被效果破坏的效果
	Duel.RegisterEffect(e2,tp)
end
-- 过滤条件：自己场上的融合怪兽
function c82315403.efftg(e,c)
	return c:IsType(TYPE_FUSION)
end
