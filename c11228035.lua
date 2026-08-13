--エクシーズ・ソウル
-- 效果：
-- 选择自己或者对方的墓地1只超量怪兽才能发动。自己场上存在的全部怪兽的攻击力直到结束阶段时上升选择的怪兽的阶级×200的数值。那之后，可以让选择的怪兽回到额外卡组。
function c11228035.initial_effect(c)
	-- 选择自己或者对方的墓地1只超量怪兽才能发动。自己场上存在的全部怪兽的攻击力直到结束阶段时上升选择的怪兽的阶级×200的数值。那之后，可以让选择的怪兽回到额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOEXTRA+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件为伤害步骤限制：仅在伤害步骤且伤害计算前才能发动，不能在伤害计算后发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c11228035.target)
	e1:SetOperation(c11228035.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动时的目标选择函数：检查是否满足取对象条件（墓地存在超量怪兽）以及自己场上存在表侧表示怪兽，并在发动时让玩家选择符合条件的对象。
function c11228035.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsType(TYPE_XYZ) end
	-- 在发动效果合法性检查时，确认自己或对方的墓地中存在1只超量怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,TYPE_XYZ)
		-- 同时确认自己场上有表侧表示怪兽存在，以保证后续攻击力上升能够适用。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择效果的对象”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从双方墓地选择1只超量怪兽作为效果对象，并将其与该连锁关联。
	Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,TYPE_XYZ)
end
-- 定义效果处理时的操作：取得对象怪兽和自己场上的表侧怪兽，若对象仍与效果关联且场上有怪兽，则使己方全场怪兽攻击力上升对应值，然后询问是否让对象返回额外卡组。
function c11228035.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的墓地超量怪兽作为对象卡tc。
	local tc=Duel.GetFirstTarget()
	-- 获取自己场上所有表侧表示怪兽，作为攻击力上升的适用对象组。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 and tc:IsRelateToEffect(e) then
		local atk=tc:GetRank()*200
		local sc=g:GetFirst()
		while sc do
			-- 自己场上存在的全部怪兽的攻击力直到结束阶段时上升选择的怪兽的阶级×200的数值。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(atk)
			sc:RegisterEffect(e1)
			sc=g:GetNext()
		end
		-- 检查选择的超量怪兽是否能够返回卡组（额外卡组），且不受王家长眠之谷等效果影响而无法从墓地移动。
		if tc:IsAbleToDeck() and aux.NecroValleyFilter()(tc)
			-- 询问玩家“是否要让选择的怪兽回到额外卡组？”，由玩家确认是否执行后续返回动作。
			and Duel.SelectYesNo(tp,aux.Stringid(11228035,0)) then  --"是否要让选择的怪兽回到额外卡组？"
			-- 中断当前效果处理，使后续的返回额外卡组处理与之前的攻击力上升处理视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的超量怪兽返回持有者额外卡组，处理原因为效果。
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
