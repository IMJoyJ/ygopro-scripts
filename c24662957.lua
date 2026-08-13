--デモンズ・ゴーレム
-- 效果：
-- ①：以场上1只攻击力2000以上的怪兽为对象才能发动。那只怪兽直到下个回合的结束阶段除外。自己场上有着「红莲魔龙」或者有那个卡名记述的同调怪兽存在的状态把这张卡发动的场合，可以再从自己的卡组·墓地把1张「魔族之链」在自己场上盖放。
function c24662957.initial_effect(c)
	-- 将「红莲魔龙」登记为这张卡的记述卡片，用于后续判断“有那个卡名记述的同调怪兽”。
	aux.AddCodeList(c,70902743)
	-- ①：以场上1只攻击力2000以上的怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c24662957.target)
	e1:SetOperation(c24662957.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：对象必须是攻击力2000以上的表侧表示怪兽，并且能被除外。
function c24662957.rmfilter(c)
	return c:IsAttackAbove(2000) and c:IsFaceup() and c:IsAbleToRemove()
end
-- 定义条件：我方场上存在「红莲魔龙」本身，或存在效果文本记述了「红莲魔龙」的表侧表示同调怪兽。
function c24662957.cfilter(c)
	-- 判断是否为「红莲魔龙」本卡，或为场上表侧表示且卡名记述了「红莲魔龙」的同调怪兽。
	return (c:IsCode(70902743) or (aux.IsCodeListed(c,70902743) and c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_MZONE)))
		and c:IsFaceup()
end
-- 效果发动时的目标选择和条件记录：选择场上1只攻击力2000以上的表侧表示怪兽作为对象，登记除外信息，并统计追加盖放条件是否满足。
function c24662957.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c24662957.rmfilter(chkc) end
	-- 效果发动合法时，检查场上是否存在至少1只满足条件的可除外怪兽。
	if chk==0 then return Duel.IsExistingTarget(c24662957.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要除外的卡”的提示，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的怪兽作为效果对象，并将该卡设为连锁对象。
	local g=Duel.SelectTarget(tp,c24662957.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁将除外1张卡（即所选择的对象）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 统计我方场上满足追加盖放条件的卡的数量（「红莲魔龙」或记载其名的同调怪兽）。
	local ct=Duel.GetMatchingGroupCount(c24662957.cfilter,tp,LOCATION_ONFIELD,0,nil)
	e:SetLabel(ct)
end
-- 定义筛选条件：卡名是「魔族之链」且可以盖放到魔法与陷阱区域。
function c24662957.stfilter(c)
	return c:IsCode(50078509) and c:IsSSetable()
end
-- 效果处理：将对象怪兽暂时除外并安排其在下次结束阶段返回；若满足条件，追加从卡组·墓地盖放1张「魔族之链」。
function c24662957.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联且是怪兽，将其暂时除外；若除外成功则继续执行后续操作。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(24662957,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- 那只怪兽直到下个回合的结束阶段除外。自己场上有着「红莲魔龙」或者有那个卡名记述的同调怪兽存在的状态把这张卡发动的场合，可以再从自己的卡组·墓地把1张「魔族之链」在自己场上盖放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c24662957.retcon)
		e1:SetOperation(c24662957.retop)
		-- 记录当前回合数，用于判断“下个回合的结束阶段”的时机。
		e1:SetLabel(Duel.GetTurnCount())
		-- 将“返回场上”的持续效果注册到决斗中，使被除外的怪兽在下个回合结束阶段返回。
		Duel.RegisterEffect(e1,tp)
		-- 从自己的卡组·墓地筛选可盖放的「魔族之链」，且排除受「王家长眠之谷」影响无法移动的墓地卡。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c24662957.stfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		-- 若发动时满足追加条件（e标签值>0）且存在可盖放的「魔族之链」，则询问玩家是否发动追加盖放。
		if e:GetLabel()>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(24662957,0)) then  --"是否盖放「魔族之链」？"
			-- 中断当前效果处理，使追加的盖放作为独立效果处理，以避免时点问题。
			Duel.BreakEffect()
			-- 显示“请选择要盖放的卡”的提示，引导玩家选择要盖放的「魔族之链」。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sc=g:Select(tp,1,1,nil)
			-- 将选中的「魔族之链」里侧表示盖放到我方魔法与陷阱区域。
			Duel.SSet(tp,sc)
		end
	end
end
-- 定义返回条件：当前已进入不同回合（即“下个回合”）且对象仍带有被除外的标记。
function c24662957.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 返回条件判定：当前回合数不是记录回合数，且对象仍带有除外标记，确保只在次回合结束阶段返回。
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(24662957)~=0
end
-- 定义返回操作：将被暂时除外的怪兽返回场上。
function c24662957.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将标记的怪兽以离场前的形式返回场上。
	Duel.ReturnToField(e:GetLabelObject())
end
