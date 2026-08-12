--琰魔竜 レッド・デーモン・ベリアル
-- 效果：
-- 调整＋调整以外的龙族·暗属性同调怪兽1只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只怪兽解放，以自己墓地1只「红莲魔」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡给与对方战斗伤害时才能发动。从自己的卡组以及墓地各把1只等级相同的调整守备表示特殊召唤。
function c36857073.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的龙族·暗属性同调怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(c36857073.sfilter),1,1)
	c:EnableReviveLimit()
	-- ①：把自己场上1只怪兽解放，以自己墓地1只「红莲魔」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36857073,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,36857073)
	e1:SetCost(c36857073.spcost)
	e1:SetTarget(c36857073.sptg1)
	e1:SetOperation(c36857073.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡给与对方战斗伤害时才能发动。从自己的卡组以及墓地各把1只等级相同的调整守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36857073,1))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1,36857074)
	e2:SetCondition(c36857073.spcon2)
	e2:SetTarget(c36857073.sptg2)
	e2:SetOperation(c36857073.spop2)
	c:RegisterEffect(e2)
end
c36857073.material_type=TYPE_SYNCHRO
-- 过滤满足龙族、暗属性、同调类型的怪兽
function c36857073.sfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
end
-- 过滤满足解放条件的怪兽（场上的怪兽或可以解放的怪兽）
function c36857073.cfilter(c,ft,tp)
	return ft>0 or (c:IsControler(tp) and c:GetSequence()<5)
end
-- 检查是否满足解放条件并选择1只满足条件的怪兽进行解放
function c36857073.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否满足解放条件
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c36857073.cfilter,1,nil,ft,tp) end
	-- 选择满足条件的1只怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c36857073.cfilter,1,1,nil,ft,tp)
	-- 以支付代价的方式解放选择的怪兽
	Duel.Release(g,REASON_COST)
end
-- 过滤满足「红莲魔」卡组且可特殊召唤的怪兽
function c36857073.spfilter1(c,e,tp)
	return c:IsSetCard(0x1045) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标为玩家墓地满足条件的怪兽
function c36857073.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c36857073.spfilter1(chkc,e,tp) end
	-- 检查玩家墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c36857073.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只墓地怪兽作为效果目标
	local g=Duel.SelectTarget(tp,c36857073.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果操作，将目标怪兽特殊召唤
function c36857073.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为对方造成的战斗伤害
function c36857073.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤满足调整类型、可特殊召唤且墓地存在同等级调整的怪兽
function c36857073.spfilter2(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查墓地是否存在同等级的调整
		and Duel.IsExistingMatchingCard(c36857073.spfilter3,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel())
end
-- 过滤满足调整类型、可特殊召唤且等级相同的怪兽
function c36857073.spfilter3(c,e,tp,lv)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and c:IsLevel(lv)
end
-- 设置效果目标为从卡组和墓地各选择1只等级相同的调整
function c36857073.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有2个以上的可用怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家卡组是否存在满足条件的调整
		and Duel.IsExistingMatchingCard(c36857073.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果操作信息为特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行效果操作，从卡组和墓地各选择1只等级相同的调整并特殊召唤
function c36857073.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查玩家场上是否有2个以上的可用怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的调整
	local g1=Duel.SelectMatchingCard(tp,c36857073.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g1:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1只等级相同的调整
	local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c36857073.spfilter3),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,g1:GetFirst():GetLevel())
	g1:Merge(g2)
	-- 将选择的2只调整特殊召唤到场上
	Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
