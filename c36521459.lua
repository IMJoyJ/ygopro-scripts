--Sin スターダスト・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。从额外卡组把1只「星尘龙」除外的场合才能特殊召唤。
-- ①：「罪」怪兽在场上只能有1只表侧表示存在。
-- ②：只要这张卡在怪兽区域存在，场地区域的表侧表示的卡不会被效果破坏。
-- ③：只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击宣言。
-- ④：没有场地魔法卡表侧表示存在的场合这张卡破坏。
function c36521459.initial_effect(c)
	-- 记录该卡具有「星尘龙」的卡片密码，用于后续效果判定
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
	-- 没有场地魔法卡表侧表示存在的场合这张卡破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SELF_DESTROY)
	e7:SetCondition(c36521459.descon)
	c:RegisterEffect(e7)
	-- 只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击宣言。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetTarget(c36521459.antarget)
	c:RegisterEffect(e8)
	-- 只要这张卡在怪兽区域存在，场地区域的表侧表示的卡不会被效果破坏。
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
	-- 设置该特殊召唤条件为始终返回假值，即不能通常召唤
	ea:SetValue(aux.FALSE)
	c:RegisterEffect(ea)
end
-- 用于判断是否为「罪」怪兽的过滤函数，若玩家受75223115效果影响则判断为36521459，否则判断为0x23属性
function c36521459.uqfilter(c)
	-- 判断该玩家是否受到75223115效果影响
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),75223115) then
		return c:IsCode(36521459)
	else
		return c:IsSetCard(0x23)
	end
end
-- 用于筛选额外卡组中可除外的「星尘龙」卡片
function c36521459.spfilter(c)
	return c:IsCode(44508094) and c:IsAbleToRemoveAsCost()
end
-- 用于筛选场上或墓地中的可除外的「罪」怪兽
function c36521459.spfilter2(c,tp)
	-- 判断该怪兽是否具有48829461效果且可除外且有怪兽区
	return c:IsHasEffect(48829461,tp) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 判断是否满足特殊召唤条件：有怪兽区且额外卡组有星尘龙，或场上/墓地有罪怪兽
function c36521459.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断玩家是否有可用怪兽区
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断额外卡组是否存在星尘龙
		and Duel.IsExistingMatchingCard(c36521459.spfilter,tp,LOCATION_EXTRA,0,1,nil)
	-- 判断场上或墓地是否存在罪怪兽
	local b2=Duel.IsExistingMatchingCard(c36521459.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
	return b1 or b2
end
-- 构建可除外的怪兽组，包含额外卡组的星尘龙和场上/墓地的罪怪兽
function c36521459.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Group.CreateGroup()
	-- 判断玩家是否有可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取额外卡组中所有星尘龙
		local g1=Duel.GetMatchingGroup(c36521459.spfilter,tp,LOCATION_EXTRA,0,nil)
		g:Merge(g1)
	end
	-- 获取场上或墓地中所有罪怪兽
	local g2=Duel.GetMatchingGroup(c36521459.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	g:Merge(g2)
	-- 提示玩家选择要除外的卡
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
-- 执行特殊召唤的除外操作
function c36521459.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 将目标卡以特殊召唤理由除外
	Duel.Remove(tc,POS_FACEUP,REASON_SPSUMMON)
end
-- 判断场地魔法区是否有表侧表示的卡
function c36521459.descon(e)
	-- 判断场地魔法区是否没有表侧表示的卡
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 设置攻击宣言禁止效果的目标为除自身外的所有怪兽
function c36521459.antarget(e,c)
	return c~=e:GetHandler()
end
