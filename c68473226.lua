--ハードアームドラゴン
-- 效果：
-- ①：这张卡可以把手卡1只8星以上的怪兽送去墓地，从手卡特殊召唤。
-- ②：把这张卡解放作召唤的7星以上的怪兽不会被效果破坏。
function c68473226.initial_effect(c)
	-- ①：这张卡可以把手卡1只8星以上的怪兽送去墓地，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c68473226.spcon)
	e1:SetTarget(c68473226.sptg)
	e1:SetOperation(c68473226.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放作召唤的7星以上的怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_PRE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c68473226.regcon)
	e2:SetOperation(c68473226.regop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中等级8以上且能送去墓地的怪兽
function c68473226.spfilter(c)
	return c:IsLevelAbove(8) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤规则的条件判定函数，检查怪兽区域是否有空位以及手卡中是否存在可作为Cost送去墓地的8星以上怪兽
function c68473226.spcon(e,c)
	if c==nil then return true end
	-- 检查自身怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只除自身以外、等级8以上且能送去墓地的怪兽
		and Duel.IsExistingMatchingCard(c68473226.spfilter,c:GetControler(),LOCATION_HAND,0,1,c)
end
-- 特殊召唤规则的Target函数，用于让玩家选择手卡中1只作为Cost送去墓地的8星以上怪兽
function c68473226.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中除自身以外、满足条件的8星以上怪兽组
	local g=Duel.GetMatchingGroup(c68473226.spfilter,tp,LOCATION_HAND,0,c)
	-- 向玩家发送“请选择要送去墓地的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的Operation函数，执行将选中的怪兽送去墓地的操作
function c68473226.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的手卡怪兽作为特殊召唤的Cost送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
-- 抗性赋予效果的注册条件判定，检查是否是因为通常召唤而被解放，且召唤出的怪兽在场上表侧表示、等级在7星以上
function c68473226.regcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return r==REASON_SUMMON and rc:IsFaceup() and rc:IsLevelAbove(7)
end
-- 抗性赋予效果的注册操作，为被召唤的7星以上怪兽注册“不会被效果破坏”的永续效果
function c68473226.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68473226,0))  --"「硬甲龙」效果适用中"
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	e1:SetCondition(c68473226.indcon)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1)
end
-- 抗性效果的适用条件，仅在怪兽存在于怪兽区域时适用
function c68473226.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
