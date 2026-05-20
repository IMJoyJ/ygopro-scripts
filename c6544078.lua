--伊弉凪
-- 效果：
-- 这张卡可以把手卡1只灵魂怪兽从游戏中除外从手卡特殊召唤。只要这张卡在自己场上表侧表示存在，自己场上存在的灵魂怪兽在结束阶段时回到手卡效果可以不发动。
function c6544078.initial_effect(c)
	-- 这张卡可以把手卡1只灵魂怪兽从游戏中除外从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6544078,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c6544078.spcon)
	e1:SetTarget(c6544078.sptg)
	e1:SetOperation(c6544078.spop)
	c:RegisterEffect(e1)
	-- 只要这张卡在自己场上表侧表示存在，自己场上存在的灵魂怪兽在结束阶段时回到手卡效果可以不发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPIRIT_MAYNOT_RETURN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以作为Cost除外的灵魂怪兽
function c6544078.filter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件检查：需要怪兽区域有空位且手卡有可除外的灵魂怪兽
function c6544078.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的主要怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只可以作为Cost除外的灵魂怪兽
		and Duel.IsExistingMatchingCard(c6544078.filter,c:GetControler(),LOCATION_HAND,0,1,nil)
end
-- 特殊召唤规则的Cost选择：从手卡选择1只灵魂怪兽并暂存
function c6544078.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中所有满足条件的灵魂怪兽
	local g=Duel.GetMatchingGroup(c6544078.filter,tp,LOCATION_HAND,0,nil)
	-- 发送系统提示，要求玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的实际操作：将选中的灵魂怪兽除外
function c6544078.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的灵魂怪兽以特殊召唤为原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
