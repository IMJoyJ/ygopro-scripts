--ヒドゥン・ショット
-- 效果：
-- ①：把自己墓地最多2只「疾行机人」怪兽除外，以除外数量的场上的卡为对象才能发动。那些卡破坏。
function c15609017.initial_effect(c)
	-- ①：把自己墓地最多2只「疾行机人」怪兽除外，以除外数量的场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c15609017.cost)
	e1:SetTarget(c15609017.target)
	e1:SetOperation(c15609017.activate)
	c:RegisterEffect(e1)
end
-- 设置cost标签为1，表示需要支付费用
function c15609017.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数，用于判断是否为「疾行机人」怪兽且可以作为除外费用
function c15609017.costfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果处理时的target阶段，检查是否满足发动条件并选择除外和破坏对象
function c15609017.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己墓地是否存在至少1张「疾行机人」怪兽
			return Duel.IsExistingMatchingCard(c15609017.costfilter,tp,LOCATION_GRAVE,0,1,nil)
				-- 检查场上是否存在至少1张卡可以成为效果对象
				and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		else return false end
	end
	e:SetLabel(0)
	-- 获取场上满足条件的卡的数量
	local rt=Duel.GetTargetCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if rt>2 then rt=2 end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的墓地怪兽进行除外
	local cg=Duel.SelectMatchingCard(tp,c15609017.costfilter,tp,LOCATION_GRAVE,0,1,rt,nil)
	local ct=cg:GetCount()
	-- 将选中的卡除外作为发动代价
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上与除外数量相同的卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,e:GetHandler())
	-- 设置操作信息，记录将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动时的处理阶段，对选中的卡进行破坏
function c15609017.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象卡组中与效果相关的卡进行破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
