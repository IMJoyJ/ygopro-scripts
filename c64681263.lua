--局地的大ハリケーン
-- 效果：
-- 自己的手卡·墓地存在的卡全部回到持有者卡组洗切。
function c64681263.initial_effect(c)
	-- 自己的手卡·墓地存在的卡全部回到持有者卡组洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c64681263.target)
	e1:SetOperation(c64681263.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标过滤与检测
function c64681263.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己的手卡和墓地中是否存在至少1张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND+LOCATION_GRAVE,0)>0 end
	-- 获取自己手卡和墓地的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND+LOCATION_GRAVE,0)
	-- 设置操作信息，表示将自己手卡和墓地的所有卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理的执行
function c64681263.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时自己手卡和墓地的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND+LOCATION_GRAVE,0)
	-- 进行「王家长眠之谷」的适用检测，若受其影响则使效果无效
	if aux.NecroValleyNegateCheck(g) then return end
	-- 将获取到的卡片全部送回持有者的卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
