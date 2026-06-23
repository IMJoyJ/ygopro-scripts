--ベイオネット・パニッシャー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的场上·墓地的「枪管」怪兽种类的以下效果适用。自己场上有攻击力3000以上的怪兽存在的场合，对方不能对应这张卡的发动把效果发动。
-- ●融合：选对方场上1只怪兽除外。
-- ●同调：从对方的额外卡组把里侧表示的卡随机3张除外。
-- ●超量：选对方场上1张魔法·陷阱卡除外。
-- ●连接：从对方墓地选最多3张卡除外。
function c36092504.initial_effect(c)
	-- 创建效果，设置为魔陷发动，自由时点，发动次数限制为1次，设置目标函数和发动函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,36092504+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c36092504.target)
	e1:SetOperation(c36092504.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的「枪管」怪兽（在场上或墓地）
function c36092504.cfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x10f)
end
-- 过滤额外卡组中里侧表示的卡
function c36092504.rmfilter1(c)
	return c:IsFacedown() and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤场上魔法·陷阱卡
function c36092504.rmfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsOnField()
end
-- 过滤场上攻击力3000以上的怪兽
function c36092504.lmfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(3000)
end
-- 判断是否满足任意一种「枪管」怪兽种类的效果发动条件
function c36092504.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上或墓地的「枪管」怪兽组
	local g1=Duel.GetMatchingGroup(c36092504.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 获取对方场上·额外·墓地可除外的卡组
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_EXTRA+LOCATION_GRAVE,nil)
	if chk==0 then return (g1:IsExists(Card.IsType,1,nil,TYPE_FUSION) and g2:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE))
		or (g1:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO) and g2:IsExists(c36092504.rmfilter1,3,nil))
		or (g1:IsExists(Card.IsType,1,nil,TYPE_XYZ) and g2:IsExists(c36092504.rmfilter2,1,nil))
		or (g1:IsExists(Card.IsType,1,nil,TYPE_LINK) and g2:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)) end
	-- 判断自己场上是否存在攻击力3000以上的怪兽，若存在则设置连锁限制
	if Duel.IsExistingMatchingCard(c36092504.lmfilter,tp,LOCATION_MZONE,0,1,nil) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制，使对方不能对应此卡发动效果
		Duel.SetChainLimit(c36092504.chainlm)
	end
end
-- 连锁限制函数，仅允许自己发动效果
function c36092504.chainlm(e,rp,tp)
	return tp==rp
end
-- 效果发动处理，根据「枪管」怪兽种类执行对应除外效果
function c36092504.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上或墓地的「枪管」怪兽组
	local g1=Duel.GetMatchingGroup(c36092504.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 获取对方场上·额外·墓地可除外的卡组
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD+LOCATION_EXTRA+LOCATION_GRAVE,nil)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	local res=0
	if g1:IsExists(Card.IsType,1,nil,TYPE_FUSION) and g2:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then
		-- 提示选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg=g2:FilterSelect(tp,Card.IsLocation,1,1,nil,LOCATION_MZONE)
		-- 显示被选为对象的动画效果
		Duel.HintSelection(rg)
		-- 将选中的卡除外
		res=Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
	-- 获取自己场上或墓地的「枪管」怪兽组
	g1=Duel.GetMatchingGroup(c36092504.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 获取对方场上·额外·墓地可除外的卡组
	g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD+LOCATION_EXTRA+LOCATION_GRAVE,nil)
	if g1:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO) and g2:IsExists(c36092504.rmfilter1,3,nil) then
		-- 若之前已执行效果则中断当前效果处理
		if res~=0 then Duel.BreakEffect() end
		-- 洗切对方额外卡组
		Duel.ShuffleExtra(1-tp)
		local rg=g2:Filter(c36092504.rmfilter1,nil):RandomSelect(tp,3)
		-- 将随机选中的3张卡除外
		res=Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
	-- 获取自己场上或墓地的「枪管」怪兽组
	g1=Duel.GetMatchingGroup(c36092504.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 获取对方场上·额外·墓地可除外的卡组
	g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD+LOCATION_EXTRA+LOCATION_GRAVE,nil)
	if g1:IsExists(Card.IsType,1,nil,TYPE_XYZ) and g2:IsExists(c36092504.rmfilter2,1,nil) then
		-- 若之前已执行效果则中断当前效果处理
		if res~=0 then Duel.BreakEffect() end
		-- 提示选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg=g2:FilterSelect(tp,c36092504.rmfilter2,1,1,nil)
		-- 显示被选为对象的动画效果
		Duel.HintSelection(rg)
		-- 将选中的卡除外
		res=Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
	-- 获取自己场上或墓地的「枪管」怪兽组
	g1=Duel.GetMatchingGroup(c36092504.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 获取对方场上·额外·墓地可除外的卡组
	g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD+LOCATION_EXTRA+LOCATION_GRAVE,nil)
	if g1:IsExists(Card.IsType,1,nil,TYPE_LINK) and g2:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 若之前已执行效果则中断当前效果处理
		if res~=0 then Duel.BreakEffect() end
		-- 提示选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg=g2:FilterSelect(tp,Card.IsLocation,1,3,nil,LOCATION_GRAVE)
		-- 显示被选为对象的动画效果
		Duel.HintSelection(rg)
		-- 将选中的卡除外
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
