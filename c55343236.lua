--Sin 真紅眼の黒竜
-- 效果：
-- 这张卡不能通常召唤。从卡组把1只「真红眼黑龙」除外的场合可以特殊召唤。
-- ①：「罪」怪兽在场上只能有1只表侧表示存在。
-- ②：只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击宣言。
-- ③：没有场地魔法卡表侧表示存在的场合这张卡破坏。
function c55343236.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,c55343236.uqfilter,LOCATION_MZONE)
	-- 这张卡不能通常召唤。从卡组把1只「真红眼黑龙」除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c55343236.spcon)
	e1:SetTarget(c55343236.sptg)
	e1:SetOperation(c55343236.spop)
	c:RegisterEffect(e1)
	-- ③：没有场地魔法卡表侧表示存在的场合这张卡破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SELF_DESTROY)
	e7:SetCondition(c55343236.descon)
	c:RegisterEffect(e7)
	-- ②：只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击宣言。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetTarget(c55343236.antarget)
	c:RegisterEffect(e8)
end
-- 过滤场上「罪」怪兽的条件（若受「罪 领域」影响则仅过滤同名卡，否则过滤所有「罪」系列怪兽）
function c55343236.uqfilter(c)
	-- 检查玩家是否受到「罪 领域」的效果影响
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),75223115) then
		return c:IsCode(55343236)
	else
		return c:IsSetCard(0x23)
	end
end
-- 过滤卡组中可以作为特殊召唤Cost除外的「真红眼黑龙」
function c55343236.spfilter(c)
	return c:IsCode(74677422) and c:IsAbleToRemoveAsCost()
end
-- 过滤因其他卡的效果（如「罪 选择」）可以从怪兽区域或墓地除外代替的卡
function c55343236.spfilter2(c,tp)
	-- 检查卡片是否具有代替除外效果、能否作为Cost除外，且其离开后能留出可用的怪兽区域空格
	return c:IsHasEffect(48829461,tp) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件判定函数
function c55343236.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且卡组中存在可以作为Cost除外的「真红眼黑龙」
		and Duel.IsExistingMatchingCard(c55343236.spfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查怪兽区域或墓地是否存在可以代替除外的卡
	local b2=Duel.IsExistingMatchingCard(c55343236.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
	return b1 or b2
end
-- 特殊召唤规则的目标选择（Cost选择）函数
function c55343236.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Group.CreateGroup()
	-- 如果自己场上有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取卡组中所有可以作为Cost除外的「真红眼黑龙」
		local g1=Duel.GetMatchingGroup(c55343236.spfilter,tp,LOCATION_DECK,0,nil)
		g:Merge(g1)
	end
	-- 获取怪兽区域或墓地中所有可以代替除外的卡
	local g2=Duel.GetMatchingGroup(c55343236.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	g:Merge(g2)
	-- 提示玩家选择要除外的卡片
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
-- 特殊召唤规则的具体执行操作函数
function c55343236.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 将选择的卡片表侧表示除外作为特殊召唤的Cost
	Duel.Remove(tc,POS_FACEUP,REASON_SPSUMMON)
end
-- 自身破坏效果的条件判定函数
function c55343236.descon(e)
	-- 检查双方场地区域是否存在表侧表示的场地魔法卡，若不存在则返回true
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 过滤不能进行攻击宣言的怪兽（自身以外的自己怪兽）
function c55343236.antarget(e,c)
	return c~=e:GetHandler()
end
