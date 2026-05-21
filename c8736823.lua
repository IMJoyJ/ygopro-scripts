--電脳堺姫－娘々
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在，自己场上有3星怪兽召唤·特殊召唤的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡当作调整使用，从场上离开的场合除外。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
-- ②：这张卡被除外的场合，以这张卡以外的除外的1张自己的卡为对象才能发动。那张卡回到卡组。
function c8736823.initial_effect(c)
	-- 注册一个用于检测此卡是否已在墓地的辅助效果，以确保在召唤/特殊召唤的同时送墓时能正确发动效果
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：这张卡在墓地存在，自己场上有3星怪兽召唤·特殊召唤的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡当作调整使用，从场上离开的场合除外。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8736823,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,8736823)
	e1:SetLabelObject(e0)
	e1:SetCondition(c8736823.spcon)
	e1:SetTarget(c8736823.sptg)
	e1:SetOperation(c8736823.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的场合，以这张卡以外的除外的1张自己的卡为对象才能发动。那张卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(8736823,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,8736824)
	e3:SetTarget(c8736823.tdtg)
	e3:SetOperation(c8736823.tdop)
	c:RegisterEffect(e3)
end
c8736823.treat_itself_tuner=true
-- 过滤条件：自己场上表侧表示的3星怪兽，且排除当前正在处理的效果
function c8736823.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsLevel(3) and c:IsControler(tp) and (se==nil or c:GetReasonEffect()~=se)
end
-- 特殊召唤效果的发动条件：自己场上有3星怪兽召唤·特殊召唤
function c8736823.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c8736823.cfilter,1,nil,tp,se)
end
-- 特殊召唤效果的靶向与发动准备：检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c8736823.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位，以及此卡是否能特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：特殊召唤自身，并适用当作调整、离场除外以及特殊召唤限制的效果
function c8736823.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其以表侧表示特殊召唤到自己场上，并判断是否特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡当作调整使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 从场上离开的场合除外
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e2)
	end
	-- 这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c8736823.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内限制玩家特殊召唤的全局效果
	Duel.RegisterEffect(e3,tp)
end
-- 限制条件：不能特殊召唤等级或阶级小于3的怪兽
function c8736823.splimit(e,c)
	return not (c:IsLevelAbove(3) or c:IsRankAbove(3))
end
-- 回卡组效果的靶向与发动准备：选择除自身以外的1张除外的自己的卡作为对象
function c8736823.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and chkc:IsAbleToDeck() and chkc~=c end
	-- 检查除外的卡中是否存在除自身以外可以回到卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,c) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择除自身以外的1张除外的自己的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,1,c)
	-- 设置连锁处理中的操作信息为：将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 回卡组效果的处理：将作为对象的卡回到卡组并洗牌
function c8736823.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
