--機海竜プレシオン
-- 效果：
-- 自己场上有海龙族怪兽存在的场合，这张卡可以不用解放作召唤。1回合1次，可以通过把自己场上1只水属性怪兽解放，选择对方场上表侧表示存在的1张卡破坏。
function c40160226.initial_effect(c)
	-- 效果原文：自己场上有海龙族怪兽存在的场合，这张卡可以不用解放作召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40160226,0))  --"不进行解放作召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c40160226.ntcon)
	c:RegisterEffect(e1)
	-- 效果原文：1回合1次，可以通过把自己场上1只水属性怪兽解放，选择对方场上表侧表示存在的1张卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40160226,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c40160226.cost)
	e2:SetTarget(c40160226.target)
	e2:SetOperation(c40160226.operation)
	c:RegisterEffect(e2)
end
-- 规则层面：判断场上是否存在表侧表示的海龙族怪兽
function c40160226.ntfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SEASERPENT)
end
-- 规则层面：判断是否满足不需解放召唤的条件（等级5以上、有空场、场上有海龙族怪兽）
function c40160226.ntcon(e,c,minc)
	if c==nil then return true end
	-- 规则层面：判断召唤者等级是否大于等于5且场上存在空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 规则层面：判断自己场上是否存在至少1只表侧表示的海龙族怪兽
		and Duel.IsExistingMatchingCard(c40160226.ntfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 规则层面：支付效果代价，解放1只水属性怪兽
function c40160226.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查是否满足解放条件（场上存在1只水属性怪兽）
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_WATER) end
	-- 规则层面：选择1只水属性怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_WATER)
	-- 规则层面：将选中的怪兽解放作为效果代价
	Duel.Release(g,REASON_COST)
end
-- 规则层面：过滤函数，判断目标是否为表侧表示的怪兽
function c40160226.filter(c)
	return c:IsFaceup()
end
-- 规则层面：设置效果目标，选择对方场上1张表侧表示的卡
function c40160226.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c40160226.filter(chkc) end
	-- 规则层面：检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c40160226.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 规则层面：向玩家发送提示信息“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面：选择对方场上1张表侧表示的卡作为破坏对象
	local g=Duel.SelectTarget(tp,c40160226.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 规则层面：设置效果操作信息，确定破坏的卡数量和类型
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 规则层面：执行效果操作，破坏选中的卡
function c40160226.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 规则层面：将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
