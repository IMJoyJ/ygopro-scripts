--幻獣機ハムストラット
-- 效果：
-- 这张卡反转时，把2只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，把1只衍生物解放才能发动。选择自己墓地1只名字带有「幻兽机」的怪兽特殊召唤。「幻兽机 同温层仓鼠」的这个效果1回合只能使用1次。
function c66200210.initial_effect(c)
	-- 这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c66200210.lvval)
	c:RegisterEffect(e1)
	-- 只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置效果适用的条件为自己场上存在衍生物
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 这张卡反转时，把2只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(66200210,0))  --"特殊召唤Token"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_FLIP)
	e4:SetTarget(c66200210.sptg)
	e4:SetOperation(c66200210.spop)
	c:RegisterEffect(e4)
	-- 此外，把1只衍生物解放才能发动。选择自己墓地1只名字带有「幻兽机」的怪兽特殊召唤。「幻兽机 同温层仓鼠」的这个效果1回合只能使用1次。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(66200210,1))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,66200210)
	e5:SetCost(c66200210.spcost2)
	e5:SetTarget(c66200210.sptg2)
	e5:SetOperation(c66200210.spop2)
	c:RegisterEffect(e5)
end
-- 计算等级上升数值的辅助函数
function c66200210.lvval(e,c)
	local tp=c:GetControler()
	-- 获取自己场上所有「幻兽机衍生物」的等级合计值
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 反转效果（特殊召唤衍生物）的发动准备与检测函数
function c66200210.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理中的操作信息：产生2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置连锁处理中的操作信息：特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 反转效果（特殊召唤衍生物）的实际处理函数
function c66200210.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若自己场上的怪兽区域空位数小于等于1，则不处理效果（无法特殊召唤2只怪兽）
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	-- 检查玩家是否可以特殊召唤符合「幻兽机衍生物」参数的怪兽
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建第一只「幻兽机衍生物」的卡片数据
		local token1=Duel.CreateToken(tp,66200211)
		-- 逐步特殊召唤第一只衍生物（表侧表示）
		Duel.SpecialSummonStep(token1,0,tp,tp,false,false,POS_FACEUP)
		-- 创建第二只「幻兽机衍生物」的卡片数据
		local token2=Duel.CreateToken(tp,66200211)
		-- 逐步特殊召唤第二只衍生物（表侧表示）
		Duel.SpecialSummonStep(token2,0,tp,tp,false,false,POS_FACEUP)
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
end
-- 过滤可解放的衍生物的条件函数（需考虑解放后是否能腾出怪兽区域空位）
function c66200210.cfilter(c,ft,tp)
	return c:IsType(TYPE_TOKEN)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
end
-- 特殊召唤墓地怪兽效果的发动代价（Cost）处理函数
function c66200210.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上怪兽区域的空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 步骤检测：检查场上是否存在至少1只可解放的衍生物，且解放后有足够的怪兽区域空位
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c66200210.cfilter,1,nil,ft,tp) end
	-- 过滤并选择1只自己场上要解放的衍生物
	local g=Duel.SelectReleaseGroup(tp,c66200210.cfilter,1,1,nil,ft,tp)
	-- 将选择的衍生物解放作为发动的代价
	Duel.Release(g,REASON_COST)
end
-- 过滤自己墓地中可以特殊召唤的「幻兽机」怪兽的条件函数
function c66200210.filter(c,e,tp)
	return c:IsSetCard(0x101b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤墓地怪兽效果的发动准备与目标选择函数
function c66200210.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c66200210.filter(chkc,e,tp) end
	-- 步骤检测：检查自己墓地是否存在至少1只可以特殊召唤的「幻兽机」怪兽
	if chk==0 then return Duel.IsExistingTarget(c66200210.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送选择特殊召唤目标的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「幻兽机」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c66200210.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理中的操作信息：特殊召唤选中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤墓地怪兽效果的实际处理函数
function c66200210.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
