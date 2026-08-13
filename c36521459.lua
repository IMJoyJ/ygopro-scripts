--Sin スターダスト・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。从额外卡组把1只「星尘龙」除外的场合才能特殊召唤。
-- ①：「罪」怪兽在场上只能有1只表侧表示存在。
-- ②：只要这张卡在怪兽区域存在，场地区域的表侧表示的卡不会被效果破坏。
-- ③：只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击宣言。
-- ④：没有场地魔法卡表侧表示存在的场合这张卡破坏。
function c36521459.initial_effect(c)
	-- 将本卡效果文本中记载的卡名「星尘龙」（44508094）登记到卡名关联列表，用于后续判断能否从额外卡组除外该卡进行特殊召唤。
	aux.AddCodeList(c,44508094)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,c36521459.uqfilter,LOCATION_MZONE)
	-- 从额外卡组把1只「星尘龙」除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c36521459.spcon)
	e1:SetTarget(c36521459.sptg)
	e1:SetOperation(c36521459.spop)
	c:RegisterEffect(e1)
	-- ④：没有场地魔法卡表侧表示存在的场合这张卡破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SELF_DESTROY)
	e7:SetCondition(c36521459.descon)
	c:RegisterEffect(e7)
	-- ③：只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击宣言。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetTarget(c36521459.antarget)
	c:RegisterEffect(e8)
	-- ②：只要这张卡在怪兽区域存在，场地区域的表侧表示的卡不会被效果破坏。
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e9:SetRange(LOCATION_MZONE)
	e9:SetTargetRange(LOCATION_FZONE,LOCATION_FZONE)
	e9:SetValue(1)
	c:RegisterEffect(e9)
	-- 这张卡不能通常召唤。
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_SINGLE)
	ea:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ea:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定值固定为false，使该卡不能通过其他方式特殊召唤，只能通过自身记载的特殊召唤手续（除外星尘龙）进行特殊召唤。
	ea:SetValue(aux.FALSE)
	c:RegisterEffect(ea)
end
-- 定义①「罪」怪兽在场上只能有1只表侧表示存在的过滤条件：若适用「罪 领域」（75223115），则只限制同名「罪 星尘龙」只能有1只表侧表示；否则限制所有「罪」字段怪兽合计只能有1只表侧表示。
function c36521459.uqfilter(c)
	-- 检查该怪兽的控制者是否受到「罪 领域」（75223115）的效果影响，以决定「罪」唯一性是按每种类各1只还是按同名卡1只适用。
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),75223115) then
		return c:IsCode(36521459)
	else
		return c:IsSetCard(0x23)
	end
end
-- 定义从额外卡组选择除外代价的过滤条件：卡名必须为「星尘龙」（44508094），且可以作为cost除外。
function c36521459.spfilter(c)
	return c:IsCode(44508094) and c:IsAbleToRemoveAsCost()
end
-- 定义从场上·墓地选择除外代价的过滤条件：怪兽持有48829461号效果、可作为cost除外，且将其除外后自己场上仍有可用的怪兽区域。
function c36521459.spfilter2(c,tp)
	-- 判断该候选怪兽是否具有48829461号效果、是否可作为cost除外，以及除外后是否能让出怪兽区域供本卡特殊召唤。
	return c:IsHasEffect(48829461,tp) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤手续的发动条件：若自己场上已有可用怪兽区域且额外卡组存在可除外的「星尘龙」，或场上·墓地存在满足spfilter2的怪兽，则允许发动特殊召唤手续。
function c36521459.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的主要怪兽区域，作为能够特殊召唤的前提。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查额外卡组是否存在至少1张可以作为cost除外的「星尘龙」（44508094）。
		and Duel.IsExistingMatchingCard(c36521459.spfilter,tp,LOCATION_EXTRA,0,1,nil)
	-- 检查自己场上或墓地是否存在至少1张满足spfilter2条件的怪兽（持有48829461效果且可作为cost除外，除外后可腾出怪兽区域）。
	local b2=Duel.IsExistingMatchingCard(c36521459.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
	return b1 or b2
end
-- 特殊召唤手续的选择阶段：汇总额外卡组的「星尘龙」与场上·墓地的特殊代价怪兽，让玩家选择1张要除外的卡；选中后将卡存入效果标签，若选中场上·墓地的卡还需消费其对应效果的次数限制，然后返回成功。
function c36521459.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Group.CreateGroup()
	-- 若当前已有可用怪兽区域，则将额外卡组中的「星尘龙」也加入可选除外代价列表。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取额外卡组中所有卡名为「星尘龙」（44508094）且可作为cost除外的卡。
		local g1=Duel.GetMatchingGroup(c36521459.spfilter,tp,LOCATION_EXTRA,0,nil)
		g:Merge(g1)
	end
	-- 获取场上·墓地中所有满足spfilter2条件（持有48829461效果且可作为cost除外）的怪兽。
	local g2=Duel.GetMatchingGroup(c36521459.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	g:Merge(g2)
	-- 向玩家发出选择提示，提示文本为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		if g2:IsContains(tc) then
			local te=tc:IsHasEffect(48829461,tp)
			te:UseCountLimit(tp)
		end
		return true
	else return false end
end
-- 特殊召唤手续的代价处理：从效果标签中取出玩家选择的卡，并将其除外，完成特殊召唤的前置手续。
function c36521459.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 将选定的卡以表侧表示除外，除外原因标记为特殊召唤（REASON_SPSUMMON）。
	Duel.Remove(tc,POS_FACEUP,REASON_SPSUMMON)
end
-- 定义④自我破坏的触发条件：场上不存在任何表侧表示的场地魔法卡。
function c36521459.descon(e)
	-- 检查双方场上是否存在表侧表示的场地魔法卡；若不存在则返回true，触发这张卡的自我破坏。
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 判定不能攻击宣言的怪兽范围：除本卡（effect handler）以外的己方怪兽，即“其他的自己怪兽”不能攻击宣言。
function c36521459.antarget(e,c)
	return c~=e:GetHandler()
end
