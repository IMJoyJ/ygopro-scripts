--猛突進
-- 效果：
-- 选择自己场上表侧表示存在的1只兽族怪兽破坏，选择对方场上存在的1只怪兽回到卡组。
function c32854013.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只兽族怪兽破坏，选择对方场上存在的1只怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c32854013.target)
	e1:SetOperation(c32854013.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤器：判断怪兽是否表侧表示且种族为兽族，用于筛选自己场上可被破坏的兽族怪兽。
function c32854013.dfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- 目标选择函数：若为连锁处理中二次确认对象（chkc非空）则不允许；在发动条件确认（chk==0）时，检查自己场上有表侧兽族怪兽且对方场上有可回卡组的怪兽，二者同时存在才可发动。
function c32854013.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：确认自己场上是否存在至少1张表侧表示的兽族怪兽，可作为破坏对象。
	if chk==0 then return Duel.IsExistingTarget(c32854013.dfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 发动合法性检查（续）：同时确认对方场上是否存在至少1张可以回到卡组的怪兽，可作为回卡组对象。
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，提示当前玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从自己场上选择1只满足过滤器条件的表侧兽族怪兽，将其登记为连锁对象（即破坏对象）。
	local g1=Duel.SelectTarget(tp,c32854013.dfilter,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 弹出选择提示，提示当前玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让当前玩家从对方场上选择1只可以回到卡组的怪兽，将其登记为连锁对象（即回卡组对象）。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设定操作信息：本次连锁将破坏g1这1张卡，分类为破坏效果，供其他卡的效果（如星尘龙）进行联动判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设定操作信息：本次连锁将g2这1张卡回到卡组，分类为回卡组效果，供其他卡的效果进行联动判定。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,1,0,0)
end
-- 效果处理函数：从效果标签中取出要破坏的兽族怪兽对象，从当前连锁信息中取出全部对象并区分另一个回卡组对象；若破坏对象仍与效果关联且仍为表侧兽族怪兽，并且破坏成功，且回卡组对象仍与效果关联，则将回卡组对象送回持有者卡组并洗牌。
function c32854013.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	-- 获取当前正在处理连锁的全部对象卡组，用于区分破坏目标和回卡组目标。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc2==tc1 then tc2=g:GetNext() end
	-- 判定处理条件：破坏目标仍与效果关联且仍为表侧兽族怪兽，且效果破坏成功，且回卡组目标仍与效果关联。
	if tc1:IsRelateToEffect(e) and c32854013.dfilter(tc1) and Duel.Destroy(tc1,REASON_EFFECT)~=0 and tc2:IsRelateToEffect(e) then
		-- 将回卡组目标怪兽回到持有者卡组，并执行洗牌。
		Duel.SendtoDeck(tc2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
