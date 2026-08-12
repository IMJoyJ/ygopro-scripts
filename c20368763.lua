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
	-- 只要自己场上有衍生物存在，这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 判断场上是否存在衍生物，若存在则此效果生效。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 1回合1次，为让这张卡以外的卡的效果发动而让自己场上的怪兽被解放时，把1只「幻兽机衍生物」特殊召唤。
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
	-- 1回合1次，把1只衍生物解放才能发动。从手卡把1只名字带有「幻兽机」的怪兽特殊召唤。
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
-- 计算场上所有「幻兽机衍生物」的等级总和。
function c20368763.lvval(e,c)
	local tp=c:GetControler()
	-- 获取场上所有「幻兽机衍生物」的等级总和。
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 判断解放的怪兽是否为场上怪兽且因cost被解放。
function c20368763.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsReason(REASON_COST)
end
-- 判断是否为非此卡自身的效果发动导致的解放，并且解放的怪兽满足cfilter条件。
function c20368763.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler()~=e:GetHandler() and re:IsHasType(0x7f0) and eg:IsExists(c20368763.cfilter,1,nil,tp)
end
-- 设置效果处理时将要特殊召唤的衍生物和Token。
function c20368763.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时将要特殊召唤的Token。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果处理时将要特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 若场上存在空位且可以特殊召唤Token，则创建并特殊召唤1只「幻兽机衍生物」。
function c20368763.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有空位则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否可以特殊召唤Token。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建1只「幻兽机衍生物」Token。
		local token=Duel.CreateToken(tp,20368764)
		-- 将创建的Token特殊召唤到场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为衍生物且满足解放条件。
function c20368763.spcfilter(c,ft,tp)
	return c:IsType(TYPE_TOKEN)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
end
-- 设置起动效果的解放费用，需选择1只衍生物进行解放。
function c20368763.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否满足解放费用条件。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c20368763.spcfilter,1,nil,ft,tp) end
	-- 选择1只满足条件的衍生物进行解放。
	local g=Duel.SelectReleaseGroup(tp,c20368763.spcfilter,1,1,nil,ft,tp)
	-- 将选中的衍生物进行解放。
	Duel.Release(g,REASON_COST)
end
-- 判断手卡中是否存在名字带有「幻兽机」的怪兽。
function c20368763.spfilter(c,e,tp)
	return c:IsSetCard(0x101b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时将要特殊召唤的卡。
function c20368763.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c20368763.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 若场上存在空位，则提示选择1只名字带有「幻兽机」的怪兽进行特殊召唤。
function c20368763.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有空位则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只名字带有「幻兽机」的怪兽。
	local g=Duel.SelectMatchingCard(tp,c20368763.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
