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
-- 在发动时首先将标签设为1，表示允许进入目标判定；实际除外墓地的动作推迟到目标选择阶段进行，并返回true作为代价条件成立。
function c15609017.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 定义代价过滤条件：该卡必须属于「疾行机人」系列、是怪兽类型，并且可以作为代价从墓地除外。
function c15609017.costfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 目标处理阶段：确认自己墓地存在可除外的疾行机人怪兽且场上存在可取对象的卡，然后选择1到2张墓地疾行机人怪兽除外，再选择与除外数量相同数量的场上卡作为破坏对象。
function c15609017.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己墓地是否存在至少1张满足代价过滤条件的「疾行机人」怪兽，以确保有卡可以除外。
			return Duel.IsExistingMatchingCard(c15609017.costfilter,tp,LOCATION_GRAVE,0,1,nil)
				-- 检查场上是否存在至少1张能够成为效果对象且不是本卡的卡，以满足取对象发动的条件。
				and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		else return false end
	end
	e:SetLabel(0)
	-- 计算场上当前能够成为效果对象的卡的数量，用于决定最多可除外几张疾行机人怪兽（上限2张）。
	local rt=Duel.GetTargetCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if rt>2 then rt=2 end
	-- 向玩家显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1到rt张满足代价过滤条件的「疾行机人」怪兽，准备作为代价除外，其中rt为场上对象数量且不超过2。
	local cg=Duel.SelectMatchingCard(tp,c15609017.costfilter,tp,LOCATION_GRAVE,0,1,rt,nil)
	local ct=cg:GetCount()
	-- 将选中的墓地「疾行机人」怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
	-- 向玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从双方场上选择与除外卡数量相同的卡作为效果对象，这些卡将在处理阶段被破坏。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,e:GetHandler())
	-- 登记当前连锁的处理信息为破坏效果，对象为g，数量为g中的卡数，用于其他卡的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：取出连锁对象，过滤掉已与效果失去联系的卡，将剩余仍然相关的对象卡破坏。
function c15609017.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁发动时选择的对象卡组，即要被破坏的场上卡片集合。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍与效果相关的对象卡以效果破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
