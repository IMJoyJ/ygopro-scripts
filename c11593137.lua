--混沌の落とし穴
-- 效果：
-- 支付2000基本分发动。光属性以及暗属性怪兽的召唤·反转召唤·特殊召唤无效并从游戏中除外。
function c11593137.initial_effect(c)
	-- 支付2000基本分发动。光属性以及暗属性怪兽的召唤·反转召唤·特殊召唤无效并从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(c11593137.condition)
	e1:SetCost(c11593137.cost)
	e1:SetTarget(c11593137.target)
	e1:SetOperation(c11593137.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
end
-- 筛选属性为光或暗的怪兽
function c11593137.filter(c)
	return c:IsAttribute(0x30) and c:IsAbleToRemove()
end
-- 效果发动条件判断
function c11593137.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 满足无效召唤条件且存在光或暗属性怪兽
	return aux.NegateSummonCondition() and eg:IsExists(c11593137.filter,1,nil)
end
-- 支付2000基本分
function c11593137.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 支付2000基本分
	Duel.PayLPCost(tp,2000)
end
-- 效果发动时的处理目标设定
function c11593137.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能除外卡片
	if chk==0 then return Duel.IsPlayerCanRemove(tp) end
	local g=eg:Filter(c11593137.filter,nil)
	-- 设置无效召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	-- 设置除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果发动时的处理流程
function c11593137.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c11593137.filter,nil)
	-- 使目标怪兽的召唤无效
	Duel.NegateSummon(g)
	-- 将目标怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
