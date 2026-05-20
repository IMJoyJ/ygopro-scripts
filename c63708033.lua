--春化精と花蕾
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以最多有从墓地特殊召唤的自己场上的地属性怪兽种类数量的对方场上的表侧表示的卡为对象才能发动。选作为对象的卡数量的自己场上的地属性怪兽回到持有者手卡，作为对象的卡回到持有者手卡。
function c63708033.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以最多有从墓地特殊召唤的自己场上的地属性怪兽种类数量的对方场上的表侧表示的卡为对象才能发动。选作为对象的卡数量的自己场上的地属性怪兽回到持有者手卡，作为对象的卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,63708033+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c63708033.target)
	e1:SetOperation(c63708033.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：从墓地特殊召唤的自己场上的表侧表示的地属性怪兽
function c63708033.cfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
end
-- 过滤条件：场上表侧表示且能回到手卡的卡
function c63708033.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果①的发动准备（检查、选择对象并设置操作信息）
function c63708033.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c63708033.thfilter(chkc) end
	-- 获取自己场上满足“从墓地特殊召唤的地属性”条件的怪兽组
	local g=Duel.GetMatchingGroup(c63708033.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查阶段：自己场上存在符合条件的怪兽，且对方场上存在至少1张可作为对象的表侧表示卡片
	if chk==0 then return #g>0 and Duel.IsExistingTarget(c63708033.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local ct=g:GetClassCount(Card.GetCode)
	-- 选择最多等同于上述地属性怪兽种类数量的对方场上的表侧表示卡片作为对象
	local sg=Duel.SelectTarget(tp,c63708033.thfilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息：将双方场上合计为对象数量2倍的卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount()*2,0,0)
end
-- 过滤条件：自己场上表侧表示且能回到手卡的地属性怪兽
function c63708033.sfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup() and c:IsAbleToHand()
end
-- 效果①的执行（将自己场上的地属性怪兽和作为对象的对方卡片回到手卡）
function c63708033.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	local ct=tg:GetCount()
	-- 获取自己场上表侧表示且能回到手卡的地属性怪兽组
	local g2=Duel.GetMatchingGroup(c63708033.sfilter,tp,LOCATION_MZONE,0,nil)
	if g2:GetCount()<ct then return end
	-- 提示玩家选择要返回手卡的自己场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g2:Select(tp,ct,ct,nil)
	-- 将选中的自己场上的地属性怪兽送回手卡，并确认其中至少有1张成功回到手卡
	if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 and sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		-- 将作为对象的对方场上的卡片送回手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
