--システム・ダウン
-- 效果：
-- 支付1000基本分。对方场上·墓地的机械族怪兽全部从游戏中除外。
function c18895832.initial_effect(c)
	-- 效果原文：支付1000基本分。对方场上·墓地的机械族怪兽全部从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c18895832.cost)
	e1:SetTarget(c18895832.target)
	e1:SetOperation(c18895832.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：支付1000基本分
function c18895832.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 效果作用：支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果作用：定义过滤条件，筛选正面表示的机械族怪兽且可以除外的卡
function c18895832.filter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_MACHINE) and c:IsAbleToRemove()
end
-- 效果作用：设置连锁处理的目标为对方场上和墓地的机械族怪兽
function c18895832.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查对方场上和墓地是否存在满足条件的机械族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c18895832.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 效果作用：获取对方场上和墓地满足条件的机械族怪兽组
	local g=Duel.GetMatchingGroup(c18895832.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
	-- 效果作用：设置操作信息，确定要除外的怪兽数量和类型
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果作用：执行除外操作
function c18895832.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取对方场上和墓地满足条件的机械族怪兽组
	local g=Duel.GetMatchingGroup(c18895832.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
	-- 效果作用：将满足条件的怪兽从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
