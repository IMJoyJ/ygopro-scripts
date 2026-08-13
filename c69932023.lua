--星辰の裂角
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1只攻击表示怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。那之后，以下效果可以适用。
-- ●「星辰的裂角」以外的自己的墓地·除外状态的1张「星辰」卡回到卡组最下面。那之后，自己抽1张。
local s,id,o=GetID()
-- 初始化效果e1：声明效果分类为回手卡/回卡组/回额外卡组/抽卡/墓地动作，类型为魔陷发动，取对象，自由时点可发动，设置发动提示时点（怪兽正面上场及结束阶段），并用「同名卡1回合1张」的誓约次数限制注册到这张卡上。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以场上1只攻击表示怪兽为对象才能发动。那只怪兽回到手卡·额外卡组。那之后，以下效果可以适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_TOEXTRA+CATEGORY_DRAW+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定卡片是否为攻击表示且能够回到手卡（可作为本卡效果对象的怪兽）。
function s.rthfilter(c)
	return c:IsPosition(POS_ATTACK) and c:IsAbleToHand()
end
-- 对象选择函数：确认连锁对象是否仍为怪兽区的攻击表示且可回手卡的卡；检查场上是否存在可作对象的攻击表示怪兽；提示玩家选择并让其在双方怪兽区选1只满足条件的怪兽作为对象，并登记回手卡的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rthfilter(chkc) end
	-- 发动条件检查：确认双方怪兽区存在至少1只可以被选为对象的攻击表示且可回到手卡的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示「请选择要返回手牌的卡」的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从双方怪兽区选择1只攻击表示且可回到手卡的怪兽作为本连锁的对象。
	local g=Duel.SelectTarget(tp,s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的操作信息为「回手卡」分类，目标为选中的那1只怪兽，供其他卡的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤函数：判定卡片是否为正面表示（含除外状态）、不是「星辰的裂角」本身、属于「星辰」系列且能够回到卡组。
function s.tdfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x1c9) and c:IsAbleToDeck()
end
-- 效果处理：取得对象怪兽，若其仍与本效果相关且是怪兽则将其送回手卡（额外卡组怪兽则回额外卡组）；成功移动后，若自己墓地·除外状态存在可回到卡组的「星辰」卡且自己可以抽卡，询问玩家是否适用回收抽卡效果；玩家同意后选择1张符合条件的卡，中断处理后将其回到卡组最下面，再中断处理让自己抽1张。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（即被选为对象的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与本效果相关且仍是怪兽，然后将其以效果原因送回持有者的手卡（额外卡组怪兽则回到额外卡组），并确认实际移动成功。
	if tc and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA)
		-- 确认自己的墓地·除外状态存在至少1张不受「王家长眠之谷」影响、满足条件的「星辰」卡（非「星辰的裂角」且可回到卡组）。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		-- 确认自己可以抽1张卡，然后询问玩家是否适用回收并抽卡的效果（玩家选「是」才继续处理）。
		and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否回收并抽卡？"
		-- 向玩家提示「请选择要返回卡组的卡」的选择消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从自己的墓地·除外状态选择1张不受「王家长眠之谷」影响、「星辰的裂角」以外的可回到卡组的「星辰」卡。
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		local dtc=sg:GetFirst()
		if dtc then
			-- 中断当前效果处理，使之后的回到卡组处理与前面的回手卡处理视为不同时进行（对应「那之后」）。
			Duel.BreakEffect()
			-- 为选中的卡显示被选为对象的动画，并记录这些卡被选为对象。
			Duel.HintSelection(sg)
			-- 将选中的卡以效果原因回到卡组最下面，并确认其确实移动到了卡组或额外卡组（灵摆等卡回额外卡组）。
			if Duel.SendtoDeck(dtc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and dtc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
				-- 中断当前效果处理，使之后的抽卡处理与回到卡组处理视为不同时进行（对应「那之后」）。
				Duel.BreakEffect()
				-- 让自己以效果原因抽1张卡。
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
