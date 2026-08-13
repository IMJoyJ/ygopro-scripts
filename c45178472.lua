--フルハウス
-- 效果：
-- 选择这张卡以外的场上表侧表示存在的2张魔法·陷阱卡和盖放的3张魔法·陷阱卡才能发动。选择的卡破坏。
function c45178472.initial_effect(c)
	-- 选择这张卡以外的场上表侧表示存在的2张魔法·陷阱卡和盖放的3张魔法·陷阱卡才能发动。选择的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c45178472.target)
	e1:SetOperation(c45178472.activate)
	c:RegisterEffect(e1)
end
-- 筛选出场上表侧表示的魔法·陷阱卡，用于选择“表侧表示存在的2张魔法·陷阱卡”的对象。
function c45178472.up(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 筛选出场上的里侧表示魔法·陷阱卡，用于选择“盖放的3张魔法·陷阱卡”的对象。
function c45178472.down(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的目标函数：连锁中对已选对象的合法性检查直接返回false；发动时检查场上是否存在2张表侧魔陷和3张盖放魔陷（均除本卡外）可作为对象，满足后进入选择流程。
function c45178472.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查场上是否存在至少2张表侧表示的魔法·陷阱卡（除本卡外）可以作为对象，作为发动条件之一。
	if chk==0 then return Duel.IsExistingTarget(c45178472.up,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,e:GetHandler())
		-- 检查场上是否存在至少3张里侧表示的魔法·陷阱卡（除本卡外）可以作为对象，作为发动条件之一。
		and Duel.IsExistingTarget(c45178472.down,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,3,e:GetHandler()) end
	-- 给玩家显示“请选择要破坏的卡”的选择提示，用于选择表侧魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上选择2张表侧表示的魔法·陷阱卡（除本卡外）作为效果对象，并登记为连锁对象。
	local g1=Duel.SelectTarget(tp,c45178472.up,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,e:GetHandler())
	-- 再次给玩家显示“请选择要破坏的卡”的选择提示，用于选择里侧（盖放）的魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上选择3张里侧表示的魔法·陷阱卡（除本卡外）作为效果对象，并登记为连锁对象。
	local g2=Duel.SelectTarget(tp,c45178472.down,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,3,3,e:GetHandler())
	g1:Merge(g2)
	-- 将破坏分类及合计5张对象卡写入连锁信息，供后续处理与时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,5,0,0)
end
-- 效果处理时取得连锁对象，筛除已不关联的卡后全部破坏。
function c45178472.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取对象卡组，并筛选出仍与本次效果有关的卡（排除已离场或关系重置的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因破坏筛选后的对象卡。
	Duel.Destroy(g,REASON_EFFECT)
end
