--深黒の落とし穴
-- 效果：
-- 5星以上的效果怪兽特殊召唤成功时才能发动。那些5星以上的效果怪兽从游戏中除外。
function c28654932.initial_effect(c)
	-- 卡片效果初始化，设置为发动时的效果，触发条件为特殊召唤成功，目标函数为c28654932.target，发动函数为c28654932.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c28654932.target)
	e1:SetOperation(c28654932.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的怪兽：表侧表示、效果怪兽、等级5以上、可以除外
function c28654932.filter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsLevelAbove(5)
		and (not e or c:IsRelateToEffect(e)) and c:IsAbleToRemove()
end
-- 效果发动时的处理函数，检查是否有满足条件的怪兽，若有则设置除外目标和操作信息
function c28654932.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c28654932.filter,1,nil,nil) end
	local g=eg:Filter(c28654932.filter,nil,nil)
	-- 将连锁处理的目标设置为所有特殊召唤成功的怪兽
	Duel.SetTargetCard(eg)
	-- 设置操作信息，指定本次效果将要除外的怪兽组和数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果发动时的处理函数，筛选满足条件的怪兽并将其除外
function c28654932.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c28654932.filter,nil,e)
	if g:GetCount()>0 then
		-- 将符合条件的怪兽以效果原因除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
