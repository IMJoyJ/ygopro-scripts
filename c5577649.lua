--スクラップ・クラッシュ
-- 效果：
-- 自己场上存在的名字带有「废铁」的怪兽被破坏送去墓地时才能发动。场上表侧表示存在的魔法·陷阱卡全部破坏。
function c5577649.initial_effect(c)
	-- 自己场上存在的名字带有「废铁」的怪兽被破坏送去墓地时才能发动。场上表侧表示存在的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c5577649.condition)
	e1:SetTarget(c5577649.target)
	e1:SetOperation(c5577649.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查卡片是否为自己场上表侧表示存在的「废铁」怪兽且因破坏送去墓地
function c5577649.cfilter(c,tp)
	return c:IsSetCard(0x24) and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 发动条件：检查送去墓地的卡中是否存在满足条件的「废铁」怪兽
function c5577649.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5577649.cfilter,1,nil,tp)
end
-- 过滤条件：场上表侧表示存在的魔法·陷阱卡
function c5577649.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动：进行发动可行性检查，并设置破坏场上所有表侧表示魔陷的操作信息
function c5577649.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查场上是否存在至少1张除本卡以外的表侧表示魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c5577649.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上除本卡以外的所有表侧表示魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c5577649.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置操作信息：表示此效果的处理为破坏场上所有符合条件的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：将场上表侧表示存在的魔法·陷阱卡全部破坏
function c5577649.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上除本卡以外的所有表侧表示魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c5577649.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将符合条件的卡全部因效果破坏
	Duel.Destroy(g,REASON_EFFECT)
end
