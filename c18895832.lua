--システム・ダウン
-- 效果：
-- 支付1000基本分。对方场上·墓地的机械族怪兽全部从游戏中除外。
function c18895832.initial_effect(c)
	-- 支付1000基本分。对方场上·墓地的机械族怪兽全部从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c18895832.cost)
	e1:SetTarget(c18895832.target)
	e1:SetOperation(c18895832.activate)
	c:RegisterEffect(e1)
end
-- 定义代价函数：若为合法性检查则仅检查能否支付1000基本分，否则实际支付该LP作为发动代价。
function c18895832.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若处于效果发动合法性检查阶段（chk==0），则仅判定玩家能否支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 若通过检查，实际扣除玩家1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 筛选条件：对方场上表侧表示或墓地中的机械族怪兽，且可被除外。
function c18895832.filter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_MACHINE) and c:IsAbleToRemove()
end
-- 效果发动时确定对象：若对方场上·墓地存在符合条件的机械族怪兽，则获取全部此类怪兽并登记为除外对象（不取对象）。
function c18895832.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认对方场上·墓地至少存在1只符合条件的机械族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c18895832.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 取得对方场上表侧表示及墓地中所有符合条件的机械族怪兽。
	local g=Duel.GetMatchingGroup(c18895832.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
	-- 将取得的怪兽组登记为本次连锁除外效果的操作信息，用于效果处理及时点判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理：取得当前所有符合条件的对方场上·墓地机械族怪兽，并将其全部除外。
function c18895832.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新取得当前所有符合条件的机械族怪兽（不取对象，处理时判定）。
	local g=Duel.GetMatchingGroup(c18895832.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
	-- 将这些怪兽以表侧表示从游戏中除外（除外原因：效果）。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
