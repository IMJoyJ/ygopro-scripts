--デーモンの顕現
-- 效果：
-- 「恶魔召唤」＋暗属性怪兽
-- ①：这张卡只要在怪兽区域存在，卡名当作「恶魔召唤」使用。
-- ②：只要这张卡在怪兽区域存在，自己场上的「恶魔召唤」的攻击力上升500。
-- ③：融合召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「恶魔召唤」特殊召唤。
function c32775808.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为70781052的怪兽和1个暗属性怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,70781052,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),1,true,true)
	-- 使该卡在场上时卡号视为「恶魔召唤」
	aux.EnableChangeCode(c,70781052)
	-- 只要这张卡在怪兽区域存在，自己场上的「恶魔召唤」的攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为卡号为70781052的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,70781052))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 融合召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「恶魔召唤」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32775808,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c32775808.spcon)
	e3:SetTarget(c32775808.sptg)
	e3:SetOperation(c32775808.spop)
	c:RegisterEffect(e3)
end
-- 判断效果发动条件：该卡从前场被送去墓地且为融合召唤，且为对方控制
function c32775808.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
		and rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤满足条件的「恶魔召唤」怪兽，用于特殊召唤
function c32775808.spfilter(c,e,tp)
	return c:IsCode(70781052) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的检查条件：确认场上存在可特殊召唤的「恶魔召唤」怪兽
function c32775808.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌·卡组·墓地中是否存在满足条件的「恶魔召唤」怪兽
		and Duel.IsExistingMatchingCard(c32775808.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只「恶魔召唤」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行特殊召唤操作，从手牌·卡组·墓地选择1只「恶魔召唤」怪兽特殊召唤
function c32775808.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「恶魔召唤」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32775808.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
