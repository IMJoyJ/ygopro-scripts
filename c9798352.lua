--奇采のプルフィネス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，从卡组把1张陷阱卡除外才能发动。这张卡的等级上升1星。
-- ②：以自己或者对方的墓地1张陷阱卡为对象才能发动。那张卡除外，这张卡的等级上升1星。
-- ③：这张卡被对方破坏的场合才能发动。选除外的1张自己的通常陷阱卡在自己场上盖放。
function c9798352.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，从卡组把1张陷阱卡除外才能发动。这张卡的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9798352,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,9798352)
	e1:SetCost(c9798352.lvcost)
	e1:SetTarget(c9798352.lvtg)
	e1:SetOperation(c9798352.lvop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以自己或者对方的墓地1张陷阱卡为对象才能发动。那张卡除外，这张卡的等级上升1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9798352,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,9798353)
	e3:SetTarget(c9798352.lvtg2)
	e3:SetOperation(c9798352.lvop2)
	c:RegisterEffect(e3)
	-- ③：这张卡被对方破坏的场合才能发动。选除外的1张自己的通常陷阱卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(9798352,2))
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,9798354)
	e4:SetCondition(c9798352.setcon)
	e4:SetTarget(c9798352.settg)
	e4:SetOperation(c9798352.setop)
	c:RegisterEffect(e4)
end
-- 过滤卡组中可以作为发动代价除外的陷阱卡
function c9798352.costfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- ①号效果的代价处理：从卡组将1张陷阱卡除外
function c9798352.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以作为代价除外的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c9798352.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组中选择1张满足条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,c9798352.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①号效果的发动检查：检查自身是否在场且等级大于等于1
function c9798352.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsRelateToEffect(e) and c:IsLevelAbove(1) end
end
-- ①号效果的效果处理：使这张卡的等级上升1星
function c9798352.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤墓地中可以被除外的陷阱卡
function c9798352.lvfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToRemove()
end
-- ②号效果的对象选择与发动检查：选择双方墓地1张陷阱卡作为对象
function c9798352.lvtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c9798352.lvfilter(chkc) end
	local c=e:GetHandler()
	-- 检查自身等级是否大于等于1，且双方墓地是否存在可除外的陷阱卡
	if chk==0 then return c:IsLevelAbove(1) and Duel.IsExistingTarget(c9798352.lvfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择双方墓地1张陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c9798352.lvfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②号效果的效果处理：将对象卡除外，这张卡的等级上升1星
function c9798352.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否仍符合效果，并将其成功除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED)
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ③号效果的发动条件：这张卡被对方破坏
function c9798352.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤除外状态的、可以盖放的自身通常陷阱卡
function c9798352.setfilter(c)
	return c:IsFaceup() and c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- ③号效果的发动检查：检查除外状态是否存在可盖放的自身通常陷阱卡
function c9798352.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查除外状态是否存在满足盖放条件的自身通常陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c9798352.setfilter,tp,LOCATION_REMOVED,0,1,nil) end
end
-- ③号效果的效果处理：选择除外的1张自己的通常陷阱卡在自己场上盖放
function c9798352.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从除外的卡中选择1张自己的通常陷阱卡
	local g=Duel.SelectMatchingCard(tp,c9798352.setfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
