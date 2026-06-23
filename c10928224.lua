--アマゾネスペット仔虎
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「亚马逊宠物虎」使用。
-- ②：这张卡在手卡·墓地存在，自己场上有「亚马逊」怪兽召唤·特殊召唤的场合才能发动。这张卡特殊召唤。
-- ③：这张卡的攻击力上升自己墓地的「亚马逊」卡数量×100。
function c10928224.initial_effect(c)
	-- 为卡片注册一个监听送入墓地事件的单次持续效果，用于记录卡片是否已送入墓地的状态。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ②：这张卡在手卡·墓地存在，自己场上有「亚马逊」怪兽召唤·特殊召唤的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10928224,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,10928224)
	e1:SetLabelObject(e0)
	e1:SetCondition(c10928224.spcon)
	e1:SetTarget(c10928224.sptg)
	e1:SetOperation(c10928224.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 使卡片在场上或墓地时视为「亚马逊宠物虎」卡名，用于满足效果条件。
	aux.EnableChangeCode(c,10979723,LOCATION_MZONE+LOCATION_GRAVE)
	-- ①：这张卡的卡名只要在场上·墓地存在当作「亚马逊宠物虎」使用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c10928224.val)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否存在己方的「亚马逊」怪兽且满足召唤或特殊召唤条件。
function c10928224.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x4)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果条件函数，判断是否有己方的「亚马逊」怪兽被召唤或特殊召唤成功。
function c10928224.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c10928224.cfilter,1,nil,tp,se)
end
-- 效果目标函数，判断是否可以将此卡特殊召唤。
function c10928224.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件，包括场上是否有空位和此卡是否能被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前处理的连锁的操作信息，指定将要特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行将此卡特殊召唤到场上的操作。
function c10928224.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作，将此卡以正面表示形式特殊召唤到场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 攻击力计算函数，根据墓地中的「亚马逊」卡数量计算攻击力提升值。
function c10928224.val(e,c)
	-- 统计己方墓地中「亚马逊」卡的数量，并乘以100作为攻击力提升值。
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x4)*100
end
