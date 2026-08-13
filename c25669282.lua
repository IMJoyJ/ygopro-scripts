--完全燃焼
-- 效果：
-- 「完全燃烧」在1回合只能发动1张。
-- ①：把自己场上1只表侧表示的「化合兽」怪兽除外才能发动。从卡组把2只「化合兽」怪兽特殊召唤（同名卡最多1张）。
-- ②：对方怪兽的直接攻击宣言时，把墓地的这张卡除外，以除外的1只自己的二重怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽当作再1次召唤的状态使用。这个效果在这张卡送去墓地的回合不能发动。
function c25669282.initial_effect(c)
	-- 「完全燃烧」在1回合只能发动1张。①：把自己场上1只表侧表示的「化合兽」怪兽除外才能发动。从卡组把2只「化合兽」怪兽特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,25669282+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c25669282.cost)
	e1:SetTarget(c25669282.target)
	e1:SetOperation(c25669282.activate)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的直接攻击宣言时，把墓地的这张卡除外，以除外的1只自己的二重怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽当作再1次召唤的状态使用。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25669282,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c25669282.spcon)
	-- 为②效果设置发动代价：把墓地的这张卡除外（aux.bfgcost是除外自身的cost函数）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c25669282.sptg)
	e2:SetOperation(c25669282.spop)
	c:RegisterEffect(e2)
end
c25669282.has_text_type=TYPE_DUAL
-- 定义c25669282.cfilter，过滤自己场上表侧表示且拥有「化合兽」字段、并且可以作为代价除外的怪兽。
function c25669282.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xeb) and c:IsAbleToRemoveAsCost()
end
-- 代价函数：发动①效果时，从自己场上选择1只符合条件的表侧表示「化合兽」怪兽，将其表侧表示除外作为代价。
function c25669282.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在至少1只符合条件的「化合兽」怪兽可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c25669282.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，让玩家选择要除外的卡（HINTMSG_REMOVE提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己场上选择1张符合条件的「化合兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c25669282.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- spfilter1：从卡组寻找可以特殊召唤的「化合兽」怪兽，并且确保卡组中还存在另一只不同名的可特殊召唤「化合兽」（同名卡最多1张的限制）。
function c25669282.spfilter1(c,e,tp)
	return c:IsSetCard(0xeb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认卡组中存在另一张符合条件的「化合兽」怪兽（用于满足特殊召唤2只）。
		and Duel.IsExistingMatchingCard(c25669282.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- spfilter2：作为第二只候选，需满足「化合兽」字段、与第一张卡名不同、且可以特殊召唤。
function c25669282.spfilter2(c,e,tp,code)
	return c:IsSetCard(0xeb) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- target：发动前检查：我方不受青眼精灵龙“不能同时特殊召唤2只以上”效果影响，且主要怪兽区有空位，且卡组有可特召的「化合兽」。
function c25669282.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 我方主要怪兽区至少要有1个可用空格，用于特殊召唤怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 卡组中存在至少1张满足spfilter1的「化合兽」怪兽（即可选择第一只，并且隐含第二只存在）。
		and Duel.IsExistingMatchingCard(c25669282.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表明本次效果将要从卡组特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理时，再次确认不受青眼精灵龙限制且主要怪兽区有2个空格；然后选第一只、第二只不同名的「化合兽」，一并特殊召唤。
function c25669282.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 我方主要怪兽区至少要有2个可用空格，才能同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		-- 提示玩家选择要特殊召唤的卡（第一只）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择第一只「化合兽」怪兽（由spfilter1过滤）。
		local g1=Duel.SelectMatchingCard(tp,c25669282.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g1:GetCount()<=0 then return end
		-- 提示玩家选择要特殊召唤的卡（第二只）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择第二只「化合兽」怪兽，通过传入第一只的卡号保证同名卡最多1张。
		local g2=Duel.SelectMatchingCard(tp,c25669282.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,g1:GetFirst():GetCode())
		g1:Merge(g2)
		-- 将选择的两只「化合兽」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- spcon：②效果的发动条件：对方怪兽直接攻击宣言时（攻击者为对方，攻击目标为空），且这张卡不是送去墓地的回合。
function c25669282.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前战斗情况：攻击者为对方、被直接攻击（无攻击目标），且满足“送去墓地的回合不能发动”的限制。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil and aux.exccon(e)
end
-- spfilter3：筛选除外状态中表侧表示且为二重怪兽、可以特殊召唤的对象。
function c25669282.spfilter3(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- sptg：取对象效果判定：以除外的自己的1只表侧表示二重怪兽为对象；需有怪兽区空格且存在合法对象。
function c25669282.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c25669282.spfilter3(chkc,e,tp) end
	-- 我方主要怪兽区至少要有1个空位，才能特殊召唤对象。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 除外的自己的二重怪兽中存在可以特殊召唤的目标。
		and Duel.IsExistingTarget(c25669282.spfilter3,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外的自己的1只表侧表示二重怪兽为对象（通过SelectTarget设定为效果对象）。
	local g=Duel.SelectTarget(tp,c25669282.spfilter3,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息，表明将把对象怪兽特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- spop：效果处理：取出对象怪兽，若仍与效果关联则尝试分步特殊召唤；成功后将其设为“再1次召唤状态”，最后完成特殊召唤。
function c25669282.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的取对象卡片。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与效果关联，且能够以表侧表示特殊召唤，则执行分步特殊召唤（后续通过EnableDualState将其变为再召唤状态）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:EnableDualState()
	end
	-- 结束分步特殊召唤流程，正式完成特殊召唤。
	Duel.SpecialSummonComplete()
end
