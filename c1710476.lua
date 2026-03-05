--Sin サイバー・エンド・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。从额外卡组把1只「电子终结龙」除外的场合才能特殊召唤。
-- ①：「罪」怪兽在场上只能有1只表侧表示存在。
-- ②：只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击宣言。
-- ③：没有场地魔法卡表侧表示存在的场合这张卡破坏。
function c1710476.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,c1710476.uqfilter,LOCATION_MZONE)
	-- 从额外卡组把1只「电子终结龙」除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1710476.spcon)
	e1:SetTarget(c1710476.sptg)
	e1:SetOperation(c1710476.spop)
	c:RegisterEffect(e1)
	-- 没有场地魔法卡表侧表示存在的场合这张卡破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SELF_DESTROY)
	e7:SetCondition(c1710476.descon)
	c:RegisterEffect(e7)
	-- 只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击宣言。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetTarget(c1710476.antarget)
	c:RegisterEffect(e8)
	-- 这张卡不能通常召唤。
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e9:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该特殊召唤条件为始终不满足（即不能通常召唤）。
	e9:SetValue(aux.FALSE)
	c:RegisterEffect(e9)
end
-- 用于判断是否为「罪」系列怪兽的过滤函数。
function c1710476.uqfilter(c)
	-- 若玩家受到效果75223115影响，则只判断是否为罪电子终结龙。
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),75223115) then
		return c:IsCode(1710476)
	else
		return c:IsSetCard(0x23)
	end
end
-- 用于筛选额外卡组中可除外的「电子终结龙」。
function c1710476.spfilter(c)
	return c:IsCode(1546123) and c:IsAbleToRemoveAsCost()
end
-- 用于筛选场上或墓地中的可除外的「罪」怪兽。
function c1710476.spfilter2(c,tp)
	-- 筛选具有效果48829461且能除外的怪兽，并确保场上还有怪兽区。
	return c:IsHasEffect(48829461,tp) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 判断是否满足特殊召唤条件：有怪兽区且有可除外的「电子终结龙」或「罪」怪兽。
function c1710476.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断自己场上是否有怪兽区可用。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断额外卡组中是否存在可除外的「电子终结龙」。
		and Duel.IsExistingMatchingCard(c1710476.spfilter,tp,LOCATION_EXTRA,0,1,nil)
	-- 判断场上或墓地中是否存在可除外的「罪」怪兽。
	local b2=Duel.IsExistingMatchingCard(c1710476.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
	return b1 or b2
end
-- 设置特殊召唤的目标选择逻辑，包括从额外卡组和场上/墓地选择除外对象。
function c1710476.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Group.CreateGroup()
	-- 判断自己场上是否有怪兽区可用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取额外卡组中所有可除外的「电子终结龙」。
		local g1=Duel.GetMatchingGroup(c1710476.spfilter,tp,LOCATION_EXTRA,0,nil)
		g:Merge(g1)
	end
	-- 获取场上或墓地中所有可除外的「罪」怪兽。
	local g2=Duel.GetMatchingGroup(c1710476.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	g:Merge(g2)
	-- 提示玩家选择要除外的卡。
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
-- 设置特殊召唤的操作逻辑，将选中的卡除外。
function c1710476.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 将选中的卡以特殊召唤理由除外。
	Duel.Remove(tc,POS_FACEUP,REASON_SPSUMMON)
end
-- 判断场地魔法区是否没有表侧表示的场地魔法卡。
function c1710476.descon(e)
	-- 若场上没有表侧表示的场地魔法卡，则满足破坏条件。
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 设置攻击宣言禁止效果的目标过滤函数，排除自身。
function c1710476.antarget(e,c)
	return c~=e:GetHandler()
end
