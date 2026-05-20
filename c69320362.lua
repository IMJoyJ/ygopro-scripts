--伝説のゼンマイ
-- 效果：
-- 自己场上表侧表示存在的名字带有「发条」的怪兽全部变成里侧守备表示。
function c69320362.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「发条」的怪兽全部变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c69320362.target)
	e1:SetOperation(c69320362.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示、名字带有「发条」且可以转成里侧表示的怪兽
function c69320362.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsCanTurnSet()
end
-- 效果发动的目标选择与检测：检查是否存在符合条件的怪兽，并设置改变表示形式的操作信息
function c69320362.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否存在至少1只符合过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69320362.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有符合过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c69320362.filter,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息：改变表示形式，涉及卡片为获取到的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：获取符合条件的怪兽，并将其全部改变为里侧守备表示
function c69320362.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，获取当前自己场上所有符合过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c69320362.filter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 将获取到的怪兽全部改变为里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
