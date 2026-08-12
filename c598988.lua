--Sin レインボー・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。从手卡·卡组把1只「究极宝玉神 虹龙」除外的场合才能特殊召唤。
-- ①：「罪」怪兽在场上只能有1只表侧表示存在。
-- ②：只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击宣言。
-- ③：没有场地魔法卡表侧表示存在的场合这张卡破坏。
function c598988.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,c598988.uqfilter,LOCATION_MZONE)
	-- 从手卡·卡组把1只「究极宝玉神 虹龙」除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c598988.spcon)
	e1:SetTarget(c598988.sptg)
	e1:SetOperation(c598988.spop)
	c:RegisterEffect(e1)
	-- ③：没有场地魔法卡表侧表示存在的场合这张卡破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SELF_DESTROY)
	e7:SetCondition(c598988.descon)
	c:RegisterEffect(e7)
	-- ②：只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击宣言。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetTarget(c598988.antarget)
	c:RegisterEffect(e8)
	-- 这张卡不能通常召唤。
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e9:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为不能通过上述特殊召唤规则以外的方法特殊召唤
	e9:SetValue(aux.FALSE)
	c:RegisterEffect(e9)
end
-- 场上只能表侧表示存在1张的卡片的过滤函数（处理「罪」怪兽的唯一性，若受「罪 领域」影响则仅限同名卡，否则为「罪」字段怪兽）
function c598988.uqfilter(c)
	-- 检查玩家是否受到「罪 领域」的效果影响
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),75223115) then
		return c:IsCode(598988)
	else
		return c:IsSetCard(0x23)
	end
end
-- 过滤手卡或卡组中可以作为特殊召唤Cost除外的「究极宝玉神 虹龙」
function c598988.spfilter(c)
	return c:IsCode(79856792) and c:IsAbleToRemoveAsCost()
end
-- 过滤场上或墓地中可以通过其他卡的效果代替除外作为特殊召唤Cost的卡
function c598988.spfilter2(c,tp)
	-- 检查卡片是否具有代替除外的效果、是否可以作为Cost除外，且该卡离开场上后是否有可用的怪兽区域
	return c:IsHasEffect(48829461,tp) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件检查函数
function c598988.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有空余的怪兽区域
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡或卡组中存在可以作为Cost除外的「究极宝玉神 虹龙」
		and Duel.IsExistingMatchingCard(c598988.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
	-- 检查场上或墓地是否存在可以代替除外Cost的卡
	local b2=Duel.IsExistingMatchingCard(c598988.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
	return b1 or b2
end
-- 特殊召唤规则的目标选择函数（选择要除外的卡）
function c598988.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Group.CreateGroup()
	-- 如果自己场上有空余的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取手卡或卡组中可以作为Cost除外的「究极宝玉神 虹龙」卡片组
		local g1=Duel.GetMatchingGroup(c598988.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		g:Merge(g1)
	end
	-- 获取场上或墓地中可以代替除外Cost的卡片组
	local g2=Duel.GetMatchingGroup(c598988.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
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
-- 特殊召唤规则的执行操作函数（将选中的卡除外）
function c598988.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 将选中的卡片以特殊召唤的理由表侧表示除外
	Duel.Remove(tc,POS_FACEUP,REASON_SPSUMMON)
end
-- 自身不入连锁破坏效果的条件检查函数
function c598988.descon(e)
	-- 检查场上（双方场地区域）是否存在表侧表示的场地魔法卡，若不存在则返回true
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 限制攻击宣言效果的影响对象过滤函数（过滤自身以外的自己怪兽）
function c598988.antarget(e,c)
	return c~=e:GetHandler()
end
