--黒・爆・裂・破・魔・導
-- 效果：
-- ①：自己场上有原本卡名是「黑魔术师」和「黑魔术少女」的怪兽存在的场合才能发动。对方场上的卡全部破坏。
function c75190122.initial_effect(c)
	-- 注册卡片关系，表明本卡记载了「黑魔术师」和「黑魔术少女」的卡名
	aux.AddCodeList(c,46986414,38033121)
	-- ①：自己场上有原本卡名是「黑魔术师」和「黑魔术少女」的怪兽存在的场合才能发动。对方场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c75190122.condition)
	e1:SetTarget(c75190122.target)
	e1:SetOperation(c75190122.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查卡片是否表侧表示且原本卡名与指定密码相同
function c75190122.cfilter(c,code)
	return c:IsFaceup() and c:IsOriginalCodeRule(code)
end
-- 发动条件：自己场上同时存在原本卡名是「黑魔术师」和「黑魔术少女」的怪兽
function c75190122.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示且原本卡名是「黑魔术师」的怪兽
	return Duel.IsExistingMatchingCard(c75190122.cfilter,tp,LOCATION_MZONE,0,1,nil,46986414)
		-- 以及检查自己场上是否存在表侧表示且原本卡名是「黑魔术少女」的怪兽
		and Duel.IsExistingMatchingCard(c75190122.cfilter,tp,LOCATION_MZONE,0,1,nil,38033121)
end
-- 效果发动靶向与操作信息设置
function c75190122.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动可行性检测，则检查对方场上是否存在可以作为破坏对象的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理信息，表明此效果将破坏对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：执行破坏对方场上所有卡的操作
function c75190122.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因破坏获取到的对方场上的卡
	Duel.Destroy(g,REASON_EFFECT)
end
