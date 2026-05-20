--おジャマ・デルタハリケーン！！
-- 效果：
-- 当「扰乱·绿」「扰乱·黄」「扰乱·黑」在自己场上以表侧表示存在时这张卡才能发动。破坏对方场上存在的所有卡。
function c8251996.initial_effect(c)
	-- 将「扰乱·绿」「扰乱·黄」「扰乱·黑」的卡片密码注册到本卡的关联卡片列表中，用于相关卡片效果的检索判定
	aux.AddCodeList(c,12482652,42941100,79335209)
	-- 当「扰乱·绿」「扰乱·黄」「扰乱·黑」在自己场上以表侧表示存在时这张卡才能发动。破坏对方场上存在的所有卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c8251996.condition)
	e1:SetTarget(c8251996.target)
	e1:SetOperation(c8251996.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：用于检查场上是否存在指定的表侧表示的「扰乱」怪兽
function c8251996.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 发动条件：检查自己场上是否同时表侧表示存在「扰乱·绿」「扰乱·黄」「扰乱·黑」
function c8251996.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「扰乱·绿」
	return Duel.IsExistingMatchingCard(c8251996.cfilter,tp,LOCATION_ONFIELD,0,1,nil,12482652)
		-- 且检查自己场上是否存在表侧表示的「扰乱·黄」
		and Duel.IsExistingMatchingCard(c8251996.cfilter,tp,LOCATION_ONFIELD,0,1,nil,42941100)
		-- 且检查自己场上是否存在表侧表示的「扰乱·黑」
		and Duel.IsExistingMatchingCard(c8251996.cfilter,tp,LOCATION_ONFIELD,0,1,nil,79335209)
end
-- 发动准备：检查对方场上是否有卡，并向系统宣告将要破坏对方场上的所有卡
function c8251996.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息，表明将要破坏对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：获取对方场上的所有卡并将其全部破坏
function c8251996.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果破坏对方场上的所有卡
	Duel.Destroy(g,REASON_EFFECT)
end
