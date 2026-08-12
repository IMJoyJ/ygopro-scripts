--霊魂の護送船
-- 效果：
-- 这张卡不能通常召唤。把自己墓地存在的1只光属性怪兽从游戏中除外的场合可以特殊召唤。
function c33347467.initial_effect(c)
	c:EnableReviveLimit()
	-- 创建一个特殊召唤规则效果，用于满足条件时将此卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c33347467.spcon)
	e1:SetTarget(c33347467.sptg)
	e1:SetOperation(c33347467.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查是否为光属性且可以作为除外费用的怪兽
function c33347467.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤条件函数：判断是否满足特殊召唤条件（有空场且墓地有光属性怪兽）
function c33347467.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断当前玩家场上是否有可用怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家墓地是否存在至少1只光属性怪兽
		and Duel.IsExistingMatchingCard(c33347467.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤目标选择函数：从墓地选择1只光属性怪兽除外作为召唤条件
function c33347467.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家墓地所有满足条件的光属性怪兽组
	local g=Duel.GetMatchingGroup(c33347467.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤处理函数：将选中的怪兽从游戏中除外
function c33347467.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标怪兽以正面表示形式除外，作为特殊召唤的代价
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
