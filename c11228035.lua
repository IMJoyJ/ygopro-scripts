--エクシーズ・ソウル
-- 效果：
-- 选择自己或者对方的墓地1只超量怪兽才能发动。自己场上存在的全部怪兽的攻击力直到结束阶段时上升选择的怪兽的阶级×200的数值。那之后，可以让选择的怪兽回到额外卡组。
function c11228035.initial_effect(c)
	-- 选择自己或者对方的墓地1只超量怪兽才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOEXTRA+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果不能在伤害计算后进行。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c11228035.target)
	e1:SetOperation(c11228035.activate)
	c:RegisterEffect(e1)
end
-- 效果的处理目标选择函数。
function c11228035.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsType(TYPE_XYZ) end
	-- 检查是否满足发动条件：自己墓地存在超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,TYPE_XYZ)
		-- 检查是否满足发动条件：自己场上存在表侧表示怪兽。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择目标怪兽。
	Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,TYPE_XYZ)
end
-- 效果的发动处理函数。
function c11228035.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 获取自己场上所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 and tc:IsRelateToEffect(e) then
		local atk=tc:GetRank()*200
		local sc=g:GetFirst()
		while sc do
			-- 使场上所有表侧表示怪兽的攻击力上升选择怪兽阶级×200。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(atk)
			sc:RegisterEffect(e1)
			sc=g:GetNext()
		end
		-- 判断目标怪兽是否可以送回额外卡组且未受王家长眠之谷影响。
		if tc:IsAbleToDeck() and aux.NecroValleyFilter()(tc)
			-- 询问玩家是否让选择的怪兽回到额外卡组。
			and Duel.SelectYesNo(tp,aux.Stringid(11228035,0)) then  --"是否要让选择的怪兽回到额外卡组？"
			-- 中断当前效果处理。
			Duel.BreakEffect()
			-- 将目标怪兽送回额外卡组。
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
