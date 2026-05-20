--氷結界の龍 グングニール
-- 效果：
-- 调整＋调整以外的水属性怪兽1只以上
-- ①：1回合1次，把最多2张手卡丢弃去墓地，以丢弃数量的对方场上的卡为对象才能发动。那些卡破坏。
function c65749035.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的水属性怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_WATER),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，把最多2张手卡丢弃去墓地，以丢弃数量的对方场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65749035,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c65749035.cost)
	e1:SetTarget(c65749035.target)
	e1:SetOperation(c65749035.operation)
	c:RegisterEffect(e1)
end
-- 过滤可作为发动代价的卡片（手牌中可丢弃的卡，或墓地中可除外代替丢弃的「冰结界」卡）
function c65749035.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsDiscardable() and c:IsAbleToGraveAsCost()
	else
		return e:GetHandler():IsSetCard(0x2f) and c:IsAbleToRemove() and c:IsHasEffect(18319762,tp)
	end
end
-- 限制选择的卡片组中，来自墓地的卡最多只能有1张（用于墓地替代效果的限制）
function c65749035.fselect(g)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
-- 代价处理函数：计算可选择的对方场上卡片数量，并选择对应数量的手牌丢弃（或墓地卡片除外代替）
function c65749035.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查是否存在至少1张可作为代价的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c65749035.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取对方场上可以作为效果对象的卡片数量
	local rt=Duel.GetTargetCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if rt>2 then rt=2 end
	-- 获取所有满足代价过滤条件的卡片组（手牌和墓地）
	local g=Duel.GetMatchingGroup(c65749035.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	-- 提示玩家选择要丢弃的手牌（或作为代替除外的卡）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local cg=g:SelectSubGroup(tp,c65749035.fselect,false,1,rt)
	e:SetLabel(cg:GetCount())
	local tc=cg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	if tc then
		local te=tc:IsHasEffect(18319762,tp)
		te:UseCountLimit(tp)
		-- 将作为代替的墓地卡片表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		cg:RemoveCard(tc)
	end
	-- 将选中的手牌作为代价丢弃去墓地
	Duel.SendtoGrave(cg,REASON_COST+REASON_DISCARD)
end
-- 效果的目标选择函数：根据丢弃的卡片数量，选择对应数量的对方场上的卡作为对象
function c65749035.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 在发动阶段检查对方场上是否存在至少1张可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择与丢弃数量相同（ct张）的对方场上的卡作为效果对象
	local eg=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置连锁信息，表明该效果的操作为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,ct,0,0)
end
-- 效果的处理函数：破坏作为对象的卡
function c65749035.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if rg:GetCount()>0 then
		-- 因效果破坏所有仍存在于场上且与效果相关的对象卡
		Duel.Destroy(rg,REASON_EFFECT)
	end
end
