--アマゾネスペット仔虎
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「亚马逊宠物虎」使用。
-- ②：这张卡在手卡·墓地存在，自己场上有「亚马逊」怪兽召唤·特殊召唤的场合才能发动。这张卡特殊召唤。
-- ③：这张卡的攻击力上升自己墓地的「亚马逊」卡数量×100。
function c10928224.initial_effect(c)
	-- 为这张卡注册“已在墓地”的标记检测效果，返回该效果 e0；e0 被作为②效果的标签对象，用于在②效果的发动条件中排除因本效果自身特殊召唤所引发的重复触发。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在手卡·墓地存在，自己场上有「亚马逊」怪兽召唤·特殊召唤的场合才能发动。这张卡特殊召唤。
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
	-- 为这张卡注册①效果：这张卡的卡名只要在场上·墓地存在当作「亚马逊宠物虎」使用。
	aux.EnableChangeCode(c,10979723,LOCATION_MZONE+LOCATION_GRAVE)
	-- ③：这张卡的攻击力上升自己墓地的「亚马逊」卡数量×100。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c10928224.val)
	c:RegisterEffect(e4)
end
-- 判断怪兽是否满足②效果的触发源条件：必须表侧表示、由 tp 控制、属于「亚马逊」字段，且导致其召唤/特殊召唤的效果不是本②效果（se）时才算符合。
function c10928224.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x4)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ②效果的发动条件：从标签对象中取出需要排除的诱发效果 se，检查本次召唤/特殊召唤成功的怪兽组 eg 中是否存在至少 1 只满足 cfilter 条件的「亚马逊」怪兽。
function c10928224.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c10928224.cfilter,1,nil,tp,se)
end
-- 发动合法性判定（chk==0 时）：自己场上必须有可用的主要怪兽区空格，且这张卡能够被特殊召唤，否则不能发动。
function c10928224.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 当 chk==0 时，首先检查自己场上是否存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁的效果处理将特殊召唤这张卡（数量为 1），以便其他效果进行连锁判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与当前效果关联（未被除外等），则将其特殊召唤到场上。
function c10928224.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到 tp 的场上（指定召唤方式为 0，并检查召唤条件与苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果攻击力上升数值的计算函数：统计这张卡控制者墓地中「亚马逊」字段卡的数量，用于计算攻击力上升值。
function c10928224.val(e,c)
	-- 返回这张卡控制者墓地中「亚马逊」卡数量 × 100，作为③效果的攻击力上升数值。
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x4)*100
end
