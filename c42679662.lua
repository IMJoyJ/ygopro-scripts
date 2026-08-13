--ヴェルズ・アザトホース
-- 效果：
-- 反转：选择场上1只特殊召唤的怪兽回到持有者卡组。
function c42679662.initial_effect(c)
	-- 反转：选择场上1只特殊召唤的怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42679662,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c42679662.target)
	e1:SetOperation(c42679662.operation)
	c:RegisterEffect(e1)
end
-- 定义选择对象的过滤条件：怪兽必须是特殊召唤的怪兽，并且可以被送回持有者卡组。
function c42679662.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToDeck()
end
-- 效果发动时的目标选择处理：若正在检查取对象合法性则验证对象位置与条件；在可发动时提示玩家选择，从双方怪兽区域选择1只特殊召唤怪兽作为对象，并登记将对象返回卡组的操作信息。
function c42679662.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c42679662.filter(chkc) end
	if chk==0 then return true end
	-- 向操作玩家显示选择提示，提示文字为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从双方怪兽区域选择1只满足过滤器条件的特殊召唤怪兽，将其设置为该效果的对象。
	local g=Duel.SelectTarget(tp,c42679662.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理信息：本次效果的处理分类为回卡组，处理对象为已选择的怪兽，数量为该组卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理阶段：取得效果对象，若该对象仍与效果相关联，则将其返回持有者卡组并触发洗牌。
function c42679662.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第一张效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果为理由将对象卡送回持有者卡组，使用洗牌规则（弹回卡组后洗牌）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
