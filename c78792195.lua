--六武衆の露払い
-- 效果：
-- 自己场上有这张卡以外的名字带有「六武众」的怪兽表侧表示存在的场合才能发动。可以把自己场上存在的1只名字带有「六武众」的怪兽解放，场上存在的1只怪兽破坏。
function c78792195.initial_effect(c)
	-- 自己场上有这张卡以外的名字带有「六武众」的怪兽表侧表示存在的场合才能发动。可以把自己场上存在的1只名字带有「六武众」的怪兽解放，场上存在的1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78792195,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c78792195.con)
	e2:SetCost(c78792195.cost)
	e2:SetTarget(c78792195.target)
	e2:SetOperation(c78792195.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的名字带有「六武众」的怪兽
function c78792195.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 发动条件判定：自己场上是否存在除这张卡以外的表侧表示「六武众」怪兽
function c78792195.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只除这张卡以外的表侧表示「六武众」怪兽
	return Duel.IsExistingMatchingCard(c78792195.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 发动代价处理：解放自己场上1只「六武众」怪兽
function c78792195.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查玩家场上是否存在可解放的「六武众」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x103d) end
	-- 玩家选择自己场上1只「六武众」怪兽作为解放对象
	local sg=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x103d)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(sg,REASON_COST)
end
-- 效果目标选择：选择场上1只怪兽作为破坏对象
function c78792195.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 在发动阶段，检查场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为“破坏选中的1只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果运行处理：破坏选中的目标怪兽
function c78792195.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
