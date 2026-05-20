--武神器－ムラクモ
-- 效果：
-- 自己的主要阶段时，自己场上有名字带有「武神」的兽战士族怪兽存在的场合，把墓地的这张卡从游戏中除外才能发动。选择对方场上表侧表示存在的1张卡破坏。「武神器-丛云」的效果1回合只能使用1次。
function c69723159.initial_effect(c)
	-- 自己的主要阶段时，自己场上有名字带有「武神」的兽战士族怪兽存在的场合，把墓地的这张卡从游戏中除外才能发动。选择对方场上表侧表示存在的1张卡破坏。「武神器-丛云」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69723159,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,69723159)
	e1:SetCondition(c69723159.descon)
	-- 设置把墓地的这张卡除外作为发动的代价
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c69723159.destg)
	e1:SetOperation(c69723159.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且名字带有「武神」的兽战士族怪兽
function c69723159.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR)
end
-- 发动条件：自己场上存在名字带有「武神」的兽战士族怪兽
function c69723159.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的名字带有「武神」的兽战士族怪兽
	return Duel.IsExistingMatchingCard(c69723159.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：表侧表示的卡
function c69723159.filter(c)
	return c:IsFaceup()
end
-- 效果目标：选择对方场上表侧表示的1张卡
function c69723159.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c69723159.filter(chkc) end
	-- 检查对方场上是否存在至少1张表侧表示的卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c69723159.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 发送系统提示：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,c69723159.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏该卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏选择的对象
function c69723159.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 因效果破坏该卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
