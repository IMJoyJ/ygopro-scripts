--トラップ・イーター
-- 效果：
-- 这张卡不能通常召唤。把对方场上表侧表示存在的1张陷阱卡送去墓地的场合才能特殊召唤。
function c13821299.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把对方场上表侧表示存在的1张陷阱卡送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c13821299.spcon)
	e2:SetTarget(c13821299.sptg)
	e2:SetOperation(c13821299.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查以玩家来看的对方场上是否存在满足条件的陷阱卡
function c13821299.spfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤条件函数，判断是否满足特殊召唤的条件
function c13821299.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家的怪兽区域是否有可用空间
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查玩家的对方场上是否存在至少1张满足条件的陷阱卡
		and Duel.IsExistingMatchingCard(c13821299.spfilter,c:GetControler(),0,LOCATION_ONFIELD,1,nil)
end
-- 特殊召唤目标选择函数，用于选择要送去墓地的陷阱卡
function c13821299.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家对方场上的所有满足条件的陷阱卡
	local g=Duel.GetMatchingGroup(c13821299.spfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 向玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤处理函数，执行将陷阱卡送去墓地的操作
function c13821299.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标陷阱卡以特殊召唤为理由送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
