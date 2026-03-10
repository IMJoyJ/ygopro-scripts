--氷結界の龍 ブリューナク
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的效果1回合只能使用1次。
-- ①：把手卡任意数量丢弃去墓地，以丢弃数量的对方场上的卡为对象才能发动。那些卡回到手卡。
function c50321796.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：把手卡任意数量丢弃去墓地，以丢弃数量的对方场上的卡为对象才能发动。那些卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50321796,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,50321796)
	e1:SetCost(c50321796.cost)
	e1:SetTarget(c50321796.target)
	e1:SetOperation(c50321796.operation)
	c:RegisterEffect(e1)
end
-- 定义费用过滤器，用于判断手牌或墓地中的卡是否可以作为费用
function c50321796.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsDiscardable() and c:IsAbleToGraveAsCost()
	else
		return e:GetHandler():IsSetCard(0x2f) and c:IsAbleToRemove() and c:IsHasEffect(18319762,tp)
	end
end
-- 筛选函数，确保选择的卡组中最多只有一张来自墓地
function c50321796.fselect(g)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
-- 处理效果的费用阶段，检索满足条件的卡并选择丢弃数量，若包含墓地卡则使用其效果次数限制并除外
function c50321796.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足费用条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c50321796.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取对方场上的可返回手牌的卡的数量
	local rt=Duel.GetTargetCount(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	-- 获取满足费用条件的所有卡
	local g=Duel.GetMatchingGroup(c50321796.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local cg=g:SelectSubGroup(tp,c50321796.fselect,false,1,rt)
	e:SetLabel(cg:GetCount())
	local tc=cg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	if tc then
		local te=tc:IsHasEffect(18319762,tp)
		te:UseCountLimit(tp)
		-- 将选中的墓地卡除外并使用其效果次数限制
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		cg:RemoveCard(tc)
	end
	-- 将选中的卡送入墓地作为费用
	Duel.SendtoGrave(cg,REASON_COST+REASON_DISCARD)
end
-- 设置效果的目标选择阶段，选择对方场上的卡作为对象
function c50321796.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查是否存在满足目标条件的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择指定数量的对方场上卡作为效果对象
	local tg=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置连锁操作信息，记录将要返回手牌的卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,ct,0,0)
end
-- 处理效果的发动阶段，将目标卡返回手牌
function c50321796.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if rg:GetCount()>0 then
		-- 将符合条件的卡送回手牌
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	end
end
