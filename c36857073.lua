--琰魔竜 レッド・デーモン・ベリアル
-- 效果：
-- 调整＋调整以外的龙族·暗属性同调怪兽1只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只怪兽解放，以自己墓地1只「红莲魔」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡给与对方战斗伤害时才能发动。从自己的卡组以及墓地各把1只等级相同的调整守备表示特殊召唤。
function c36857073.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽（任意）＋1只调整以外的龙族·暗属性·同调怪兽作为素材，合计2只素材。
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
-- 素材过滤函数：判断怪兽是否同时满足龙族、暗属性、同调怪兽三个条件，用于筛选同调素材中的非调整怪兽。
function c36857073.sfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
end
-- 解放怪兽的过滤条件：若特殊召唤前已有空格（ft>0），则任意可解放怪兽均可；若没有空格，则必须选择己方主要怪兽区的怪兽，以便解放后空出格子用于特殊召唤。
function c36857073.cfilter(c,ft,tp)
	return ft>0 or (c:IsControler(tp) and c:GetSequence()<5)
end
-- ①效果的发动代价：解放自己场上1只怪兽。先检查能否满足解放条件，再选择1只怪兽解放作为COST。
function c36857073.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方主要怪兽区域当前的空格数量，用于判断解放后是否有足够格子特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查发动条件：己方主要怪兽区空格数不为负数（解放后至少能有1个空位），且场上存在满足条件的可解放怪兽。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c36857073.cfilter,1,nil,ft,tp) end
	-- 从己方场上选择1只满足条件的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c36857073.cfilter,1,1,nil,ft,tp)
	-- 将选择的怪兽解放（REASON_COST），作为效果的发动代价。
	Duel.Release(g,REASON_COST)
end
-- 墓地对象过滤函数：选择属于「红莲魔」系列（0x1045）且可以被特殊召唤的怪兽。
function c36857073.spfilter1(c,e,tp)
	return c:IsSetCard(0x1045) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动时选择对象：从自己墓地选择1只「红莲魔」怪兽作为特殊召唤对象，并设置特殊召唤操作信息。
function c36857073.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c36857073.spfilter1(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只符合条件的「红莲魔」怪兽，存在才能发动。
	if chk==0 then return Duel.IsExistingTarget(c36857073.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡（①效果的对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「红莲魔」怪兽，并设定为效果对象。
	local g=Duel.SelectTarget(tp,c36857073.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息：包含特殊召唤分类，目标为选中的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将对象怪兽从墓地特殊召唤到自己场上。
function c36857073.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时第一个被选择的对象（墓地「红莲魔」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡给与对方战斗伤害时（伤害承受方不是自己，即对方受到战斗伤害）。
function c36857073.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 卡组侧素材过滤：选择1只可以表侧守备特殊召唤的调整，且墓地存在1只与该调整等级相同的可特殊召唤的调整。
function c36857073.spfilter2(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 同时检查墓地是否存在与卡组所选调整等级相同的另一只调整，确保能凑成一对同等级调整。
		and Duel.IsExistingMatchingCard(c36857073.spfilter3,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel())
end
-- 墓地侧素材过滤：选择1只可以表侧守备特殊召唤的调整，且等级与卡组选择的调整相同。
function c36857073.spfilter3(c,e,tp,lv)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and c:IsLevel(lv)
end
-- ②效果的发动时检查：我方不受【青眼精灵龙】效果影响（不能同时特殊召唤2只以上），且我方主要怪兽区有至少2个空格，并且卡组存在符合条件的调整，才能发动。
function c36857073.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认我方主要怪兽区至少有2个空格，以容纳要特殊召唤的2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认卡组中存在1只能与墓地调整组成同等级配对的调整怪兽，满足才能发动。
		and Duel.IsExistingMatchingCard(c36857073.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组和墓地合计特殊召唤2只怪兽，为效果处理做准备。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理：从卡组和墓地各选1只等级相同的调整，均以表侧守备表示特殊召唤；处理前再次检查是否受【青眼精灵龙】影响及格子是否足够。
function c36857073.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 处理时再次确认我方主要怪兽区至少有2个空格，若不足则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡（卡组中的调整怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的调整怪兽作为特殊召唤对象之一。
	local g1=Duel.SelectMatchingCard(tp,c36857073.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g1:GetCount()==0 then return end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡（墓地中的调整怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1只与卡组所选调整等级相同的调整怪兽，并用 NecroValleyFilter 规避王家长眠之谷对墓地特殊召唤的限制。
	local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c36857073.spfilter3),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,g1:GetFirst():GetLevel())
	g1:Merge(g2)
	-- 将卡组和墓地选出的2只调整怪兽合并后，全部以表侧守备表示特殊召唤到自己场上。
	Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
