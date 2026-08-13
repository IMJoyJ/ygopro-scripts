--星辰の刺毒
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方墓地的怪兽和魔法·陷阱卡各最多1张为对象才能发动。那些卡除外。那之后，以下效果可以适用。
-- ●「星辰的刺毒」以外的自己的墓地·除外状态的1张「星辰」卡回到卡组最下面。那之后，自己抽1张。
local s,id,o=GetID()
-- 初始化效果e1：设置描述、效果分类（除外+回卡组+抽卡）、发动类型（魔法卡发动、自由时点、取对象）、1回合1次发动限制、时点提示、目标函数与处理函数，并注册到卡片上
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方墓地的怪兽和魔法·陷阱卡各最多1张为对象才能发动。那些卡除外。那之后，以下效果可以适用。●「星辰的刺毒」以外的自己的墓地·除外状态的1张「星辰」卡回到卡组最下面。那之后，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 子选择组过滤函数：保证所选卡中魔法·陷阱卡最多1张、怪兽卡最多1张
function s.fselect(g)
	return g:FilterCount(Card.IsType,nil,TYPE_SPELL+TYPE_TRAP)<=1 and g:FilterCount(Card.IsType,nil,TYPE_MONSTER)<=1
end
-- 回卡组对象的过滤函数：「星辰的刺毒」以外的「星辰」卡，表侧表示存在且能够回到卡组
function s.tdfilter(c)
	return c:IsSetCard(0x1c9) and not c:IsCode(id) and c:IsAbleToDeck()
		and c:IsFaceupEx()
end
-- 除外对象的过滤函数：能够除外且能够成为此效果对象的卡
function s.rmfilter(c,e)
	return c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end
-- 目标函数：检测对方墓地是否存在可取对象除外的卡，让玩家从中选择怪兽和魔法·陷阱各最多1张作为对象，设置对象卡并声明除外操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检测：对方墓地存在能够除外且能成为此效果对象的卡
	if chk==0 then return Duel.GetMatchingGroupCount(s.rmfilter,tp,0,LOCATION_GRAVE,nil,e)>0 end
	-- 取得对方墓地中所有能够除外且能成为此效果对象的卡
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_GRAVE,nil,e)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,1,2)
	-- 将选中的卡设置为本连锁的对象
	Duel.SetTargetCard(sg)
	-- 声明除外操作信息：将这些对象卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
-- 效果处理：将对象卡除外，若除外成功则可以让自己墓地·除外状态的1张「星辰」卡回到卡组最下面，然后自己抽1张
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本连锁相关的对象卡，并过滤掉受王家长眠之谷影响的卡
	local rg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if #rg==0 then return end
	-- 将对象卡以表侧表示除外，成功除外至少1张则继续后续处理
	if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
		-- 检索自己墓地·除外状态的「星辰的刺毒」以外能够回到卡组的「星辰」卡
		local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 确认存在可回到卡组的「星辰」卡且自己可以抽1张卡
		if dg:GetCount()>0 and Duel.IsPlayerCanDraw(tp,1)
			-- 询问玩家是否适用回收并抽卡的效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否回收并抽卡？"
			-- 提示玩家选择要返回卡组的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local sg=dg:Select(tp,1,1,nil)
			local dtc=sg:GetFirst()
			if dtc then
				-- 中断效果处理，使之后的回卡组处理与除外处理视为不同时处理（对应原文「那之后」）
				Duel.BreakEffect()
				-- 为选中的卡显示被选中的动画并记录这些卡被选择
				Duel.HintSelection(sg)
				-- 将选中的「星辰」卡回到持有者的卡组最下面，并确认其确实位于卡组或额外卡组
				if Duel.SendtoDeck(dtc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and dtc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
					-- 中断效果处理，使抽卡处理与回卡组处理视为不同时处理（对应原文「那之后」）
					Duel.BreakEffect()
					-- 自己抽1张卡
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
		end
	end
end
