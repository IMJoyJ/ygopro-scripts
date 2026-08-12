--マジック・ストライカー
-- 效果：
-- ①：这张卡可以把自己墓地1张魔法卡除外，从手卡特殊召唤。
-- ②：这张卡可以直接攻击。
-- ③：这张卡的战斗发生的对自己的战斗伤害变成0。
function c93187568.initial_effect(c)
	-- ①：这张卡可以把自己墓地1张魔法卡除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c93187568.spcon)
	e1:SetTarget(c93187568.sptg)
	e1:SetOperation(c93187568.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- ③：这张卡的战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查卡片是否为魔法卡且可以作为cost除外
function c93187568.spfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判定：检查怪兽区域是否有空位，以及墓地是否存在可以除外的魔法卡
function c93187568.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上的主要怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张满足过滤条件的卡（魔法卡且能被除外）
		and Duel.IsExistingMatchingCard(c93187568.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤规则的目标选择：从墓地选择1张要除外的魔法卡，并将其暂存
function c93187568.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足过滤条件的卡片组
	local g=Duel.GetMatchingGroup(c93187568.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的具体执行操作：将选中的卡除外
function c93187568.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因，将选中的卡片表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
