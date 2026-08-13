--幻獣機ハリアード
-- 效果：
-- 1回合1次，为让这张卡以外的卡的效果发动而让自己场上的怪兽被解放时，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，1回合1次，把1只衍生物解放才能发动。从手卡把1只名字带有「幻兽机」的怪兽特殊召唤。
function c20368763.initial_effect(c)
	-- 这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c20368763.lvval)
	c:RegisterEffect(e1)
	-- 只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置战斗破坏免疫效果仅在自场上有衍生物存在时适用。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 1回合1次，为让这张卡以外的卡的效果发动而让自己场上的怪兽被解放时，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20368763,0))  --"特殊召唤Token"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_RELEASE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c20368763.spcon)
	e4:SetTarget(c20368763.sptg)
	e4:SetOperation(c20368763.spop)
	c:RegisterEffect(e4)
	-- 此外，1回合1次，把1只衍生物解放才能发动。从手卡把1只名字带有「幻兽机」的怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(20368763,1))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c20368763.spcost2)
	e5:SetTarget(c20368763.sptg2)
	e5:SetOperation(c20368763.spop2)
	c:RegisterEffect(e5)
end
-- 计算这张卡的等级上升值：自己场上所有「幻兽机衍生物」的等级合计数值。
function c20368763.lvval(e,c)
	local tp=c:GetControler()
	-- 获取自己场上所有卡号为31533705的衍生物，并求和其等级。
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 筛选条件：被解放的怪兽原控制者为tp、原位置为怪兽区，且解放原因为COST。
function c20368763.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsReason(REASON_COST)
end
-- 效果发动条件：其他卡的效果为发动而解放了自己场上的怪兽（不包含本卡自身的效果发动）。
function c20368763.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler()~=e:GetHandler() and re:IsHasType(0x7f0) and eg:IsExists(c20368763.cfilter,1,nil,tp)
end
-- 效果发动时的目标处理：无需选择对象，直接设置操作信息为特殊召唤衍生物。
function c20368763.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次处理包含衍生物生成，预计生成1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次处理包含特殊召唤，预计特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：若自己怪兽区有空位且可特招该衍生物，则生成1只「幻兽机衍生物」并特殊召唤到场上。
function c20368763.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否有空位，若无则无法特殊召唤衍生物，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查自己是否允许特殊召唤指定参数的「幻兽机衍生物」（卡号31533705，机械族/风/3星/攻守0）。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 生成1只「幻兽机衍生物」（卡号20368764），归tp控制。
		local token=Duel.CreateToken(tp,20368764)
		-- 将生成的衍生物以表侧攻击表示特殊召唤到tp的场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选可解放的衍生物：必须是衍生物；若自己怪兽区无空位，则只能选择自己主要怪兽区的衍生物，以便解放后腾出特召位置。
function c20368763.spcfilter(c,ft,tp)
	return c:IsType(TYPE_TOKEN)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
end
-- 发动代价：从自己场上选择1只衍生物解放。检查可解放对象且保证解放后仍有空位用于特殊召唤。
function c20368763.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己主要怪兽区当前可用的空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 代价检查：要求当前空格数大于-1（保证解放衍生物后能腾出至少1个怪兽区），且存在可解放的衍生物。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c20368763.spcfilter,1,nil,ft,tp) end
	-- 玩家选择1只满足条件的衍生物作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c20368763.spcfilter,1,1,nil,ft,tp)
	-- 将选择的衍生物以COST理由解放，完成代价支付。
	Duel.Release(g,REASON_COST)
end
-- 筛选手卡中可作为特殊召唤对象的「幻兽机」怪兽：属于0x101b系列，且可以被当前效果特殊召唤。
function c20368763.spfilter(c,e,tp)
	return c:IsSetCard(0x101b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标处理：检查手卡是否有符合条件的「幻兽机」怪兽，并设置操作信息为特殊召唤。
function c20368763.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：确认手卡中是否存在至少1只符合条件的「幻兽机」怪兽，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c20368763.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果含特殊召唤，预计从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若自己怪兽区有空位，则玩家选择手卡中的1只「幻兽机」怪兽特殊召唤到场上。
function c20368763.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否有空位，若无则无法特殊召唤，终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡中选择1只符合条件的「幻兽机」怪兽。
	local g=Duel.SelectMatchingCard(tp,c20368763.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
