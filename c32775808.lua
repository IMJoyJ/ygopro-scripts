--デーモンの顕現
-- 效果：
-- 「恶魔召唤」＋暗属性怪兽
-- ①：这张卡只要在怪兽区域存在，卡名当作「恶魔召唤」使用。
-- ②：只要这张卡在怪兽区域存在，自己场上的「恶魔召唤」的攻击力上升500。
-- ③：融合召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「恶魔召唤」特殊召唤。
function c32775808.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡登记融合召唤手续：融合素材为「恶魔召唤」（70781052）＋1只暗属性怪兽。
	aux.AddFusionProcCodeFun(c,70781052,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),1,true,true)
	-- 注册卡名变更效果：这张卡在怪兽区域存在时，卡名当作「恶魔召唤」（70781052）使用。
	aux.EnableChangeCode(c,70781052)
	-- ②：只要这张卡在怪兽区域存在，自己场上的「恶魔召唤」的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 指定攻击力上升效果的对象：己方怪兽区域中所有卡号为70781052（即卡名视为「恶魔召唤」）的怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,70781052))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「恶魔召唤」特殊召唤。
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
-- 效果③的发动条件：这张卡以融合召唤方式在怪兽区域存在时，被对方（rp为对方）从自己场上送入墓地。
function c32775808.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
		and rp==1-tp and c:IsPreviousControler(tp)
end
-- 特殊召唤对象的过滤条件：卡名为「恶魔召唤」（70781052），且可以被当前玩家效果特殊召唤（满足召唤条件与苏生限制）。
function c32775808.spfilter(c,e,tp)
	return c:IsCode(70781052) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③发动时点的目标检查：确认自己场上存在可用的怪兽区域，且手卡·卡组·墓地中存在至少1只符合条件的「恶魔召唤」可供特殊召唤。
function c32775808.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上是否有空闲怪兽区域可作为特殊召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时检查自己的手卡·卡组·墓地中是否存在至少1只满足spfilter条件的「恶魔召唤」（70781052）。
		and Duel.IsExistingMatchingCard(c32775808.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果处理将进行特殊召唤，预计从自己的手卡·卡组·墓地中选择1只「恶魔召唤」特殊召唤（供连锁时点检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果③的实际处理：从自己的手卡·卡组·墓地中选出符合条件的「恶魔召唤」特殊召唤；若墓地中的候选受「王家长眠之谷」影响则不能选择，选到的怪兽表侧表示特殊召唤到自己场上。
function c32775808.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认自己场上仍有可用的怪兽区域；若没有则效果处理不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向当前玩家显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让当前玩家从自己的手卡·卡组·墓地中选择1张满足 spfilter 且不受王家长眠之谷影响的「恶魔召唤」（70781052）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32775808.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「恶魔召唤」以表侧表示特殊召唤到自己的怪兽区域（无额外召唤方式，使用规则上通常的特殊召唤流程）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
