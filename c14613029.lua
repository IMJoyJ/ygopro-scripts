--ブレンD
-- 效果：
-- 自己场上名字带有「变形斗士」的怪兽有2只以上表侧表示存在的场合，选择对方场上存在的2张卡发动。对方从那之中选择1张，对方选择的1张卡破坏。
function c14613029.initial_effect(c)
	-- 自己场上名字带有「变形斗士」的怪兽有2只以上表侧表示存在的场合，选择对方场上存在的2张卡发动。对方从那之中选择1张，对方选择的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c14613029.condition)
	e1:SetTarget(c14613029.target)
	e1:SetOperation(c14613029.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查以玩家来看的场上是否存在至少2只表侧表示的「变形斗士」怪兽
function c14613029.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x26)
end
-- 效果发动的条件判断函数
function c14613029.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家来看的场上是否存在至少2只表侧表示的「变形斗士」怪兽
	return Duel.IsExistingMatchingCard(c14613029.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 效果的对象选择函数
function c14613029.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查以玩家来看的对方场上是否存在至少2张可以成为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 向玩家提示选择对方场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	-- 选择对方场上的2张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,2,2,nil)
	-- 设置效果处理时要破坏的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果的处理函数
function c14613029.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中已选定的对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()==0 then return
	elseif sg:GetCount()==1 then
		-- 将满足条件的卡组全部破坏
		Duel.Destroy(sg,REASON_EFFECT)
	else
		-- 向对方提示选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)
		local dg=sg:Select(1-tp,1,1,nil)
		-- 将对方选择的卡破坏
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
