--魔鍵闘争
-- 效果：
-- ①：以自己墓地的通常怪兽、「魔键」怪兽、「魔键-马夫提亚」之内1张为对象才能发动。那张卡回到卡组。连锁对方的魔法·陷阱·怪兽的效果的发动把这张卡发动的场合，再让衍生物以外的自己场上的通常怪兽以及「魔键」怪兽不受那个对方的效果影响。
function c54408264.initial_effect(c)
	-- ①：以自己墓地的通常怪兽、「魔键」怪兽、「魔键-马夫提亚」之内1张为对象才能发动。那张卡回到卡组。连锁对方的魔法·陷阱·怪兽的效果的发动把这张卡发动的场合，再让衍生物以外的自己场上的通常怪兽以及「魔键」怪兽不受那个对方的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c54408264.target)
	e1:SetOperation(c54408264.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中满足通常怪兽、「魔键」怪兽或「魔键-马夫提亚」且能回到卡组的卡
function c54408264.filter(c)
	return (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_MONSTER) and c:IsSetCard(0x165) or c:IsCode(99426088)) and c:IsAbleToDeck()
end
-- 效果①的发动准备，包括合法性检查、选择对象以及设置操作信息
function c54408264.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c54408264.filter(chkc) end
	-- 检查自己墓地是否存在至少1张符合条件的卡可以作为对象
	if chk==0 then return Duel.IsExistingTarget(c54408264.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1张符合条件的卡作为效果的对象
	local g=Duel.SelectTarget(tp,c54408264.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果①的效果处理，执行将卡回到卡组，并判断是否满足追加不受对方效果影响的条件
function c54408264.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍适用此效果，则将其送回卡组洗牌，若成功送回则继续处理
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 获取当前正在处理的连锁序号
		local ct=Duel.GetCurrentChain()
		if ct<2 then return end
		-- 获取直接连锁本卡发动的上一个效果及其发动玩家
		local te,tep=Duel.GetChainInfo(ct-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tep==1-tp and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			-- 中断当前效果处理，使后续的不受影响效果与返回卡组不视为同时处理
			Duel.BreakEffect()
			-- 连锁对方的魔法·陷阱·怪兽的效果的发动把这张卡发动的场合，再让衍生物以外的自己场上的通常怪兽以及「魔键」怪兽不受那个对方的效果影响。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetTarget(c54408264.etarget)
			e1:SetValue(c54408264.efilter)
			e1:SetLabelObject(te)
			e1:SetReset(RESET_EVENT+RESET_CHAIN)
			-- 在全局注册该不受影响的耐性效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 过滤不受影响的效果，指定为上一个连锁中对方发动的那个效果
function c54408264.efilter(e,re)
	return re==e:GetLabelObject()
end
-- 过滤受耐性保护的怪兽，指定为自己场上衍生物以外的通常怪兽以及「魔键」怪兽
function c54408264.etarget(e,c)
	return not c:IsType(TYPE_TOKEN) and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165))
end
