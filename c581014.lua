--ダイガスタ・エメラル
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。
-- ●以自己墓地3只怪兽为对象才能发动。那3只怪兽加入卡组洗切。那之后，自己从卡组抽1张。
-- ●以效果怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c581014.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。●以自己墓地3只怪兽为对象才能发动。那3只怪兽加入卡组洗切。那之后，自己从卡组抽1张。●以效果怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c581014.cost)
	e1:SetTarget(c581014.target1)
	e1:SetOperation(c581014.operation1)
	c:RegisterEffect(e1)
end
-- 效果发动代价（Cost）：取除这张卡的1个超量素材
function c581014.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件1：自己墓地的怪兽
function c581014.filter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤条件2：自己墓地效果怪兽以外的、且可以特殊召唤的怪兽
function c581014.filter2(c,e,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与处理分支判定
function c581014.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c581014.filter1(chkc)
		else
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c581014.filter2(chkc,e,tp)
		end
	end
	-- 检查是否满足效果1的发动条件：玩家可以抽卡，且自己墓地存在至少3只怪兽
	local b1=Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(c581014.filter1,tp,LOCATION_GRAVE,0,3,nil)
	-- 检查是否满足效果2的发动条件：自己场上有空余的怪兽区域，且自己墓地存在至少1只效果怪兽以外的怪兽
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c581014.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个效果都满足时，让玩家选择发动其中一个效果
		op=Duel.SelectOption(tp,aux.Stringid(581014,1),aux.Stringid(581014,2))  --"回收并抽卡/特殊召唤"
	elseif b1 then
		-- 仅满足效果1时，强制选择效果1
		op=Duel.SelectOption(tp,aux.Stringid(581014,1))  --"回收并抽卡"
	else
		-- 仅满足效果2时，强制选择效果2（并将选项索引加1以匹配分支）
		op=Duel.SelectOption(tp,aux.Stringid(581014,2))+1  --"特殊召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择自己墓地3只怪兽作为效果对象
		local g=Duel.SelectTarget(tp,c581014.filter1,tp,LOCATION_GRAVE,0,3,3,nil)
		-- 设置连锁信息：包含将选中的卡片送回卡组的操作
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
		-- 设置连锁信息：包含玩家抽1张卡的操作
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择自己墓地1只效果怪兽以外的怪兽作为效果对象
		local g=Duel.SelectTarget(tp,c581014.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 设置连锁信息：包含特殊召唤选中怪兽的操作
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果处理的核心逻辑
function c581014.operation1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取当前连锁中被选为对象的卡片组
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
		-- 将作为对象的怪兽加入卡组洗切
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 获取本次操作中实际移动位置的卡片组
		local g=Duel.GetOperatedGroup()
		-- 如果有卡片确实回到了卡组，则洗切卡组
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if ct==3 then
			-- 中断当前效果处理，使后续的抽卡处理不与返回卡组视为同时进行
			Duel.BreakEffect()
			-- 玩家从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	else
		-- 获取作为对象的第1个卡片（即要特殊召唤的怪兽）
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将目标怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
