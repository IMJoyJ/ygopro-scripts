--星辰の刺毒
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方墓地的怪兽和魔法·陷阱卡各最多1张为对象才能发动。那些卡除外。那之后，以下效果可以适用。
-- ●「星辰的刺毒」以外的自己的墓地·除外状态的1张「星辰」卡回到卡组最下面。那之后，自己抽1张。
local s,id,o=GetID()
-- 注册卡片发动时的效果，该效果包含除外、回到卡组和抽卡的操作
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
-- 过滤出怪兽以及魔法·陷阱卡分别最多各1张的卡片组
function s.fselect(g)
	return g:FilterCount(Card.IsType,nil,TYPE_SPELL+TYPE_TRAP)<=1 and g:FilterCount(Card.IsType,nil,TYPE_MONSTER)<=1
end
-- 过滤出除「星辰的刺毒」以外的自己墓地或除外状态的可以回到卡组的「星辰」卡片
function s.tdfilter(c)
	return c:IsSetCard(0x1c9) and not c:IsCode(id) and c:IsAbleToDeck()
		and c:IsFaceupEx()
end
-- 过滤出对方墓地中可以被除外且可以作为效果对象的卡片
function s.rmfilter(c,e)
	return c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end
-- 处理卡片发动时的对象选择与效果分类操作，选择对方墓地怪兽和魔法·陷阱卡各最多1张作为对象，并设置除外操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在效果发动时，检查对方墓地是否存在可被除外的卡片
	if chk==0 then return Duel.GetMatchingGroupCount(s.rmfilter,tp,0,LOCATION_GRAVE,nil,e)>0 end
	-- 获取对方墓地中可被除外的所有卡片
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_GRAVE,nil,e)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,1,2)
	-- 将选择的卡片保存为效果的目标对象
	Duel.SetTargetCard(sg)
	-- 设置当前连锁的操作信息为除外选择的目标卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
-- 卡片发动效果的处理，将作为对象的目标卡片除外，并由玩家决定是否将自己墓地/除外状态的「星辰」卡送回卡组最下面并抽卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关且不受王家长眠之谷影响的已选择的目标卡片
	local rg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if #rg==0 then return end
	-- 将目标卡片除外，并判断是否成功除外了至少1张卡片
	if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
		-- 获取自己墓地及除外状态中所有符合条件的「星辰」卡片
		local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 检查是否存在可回到卡组的「星辰」卡片且自己是否能够抽卡
		if dg:GetCount()>0 and Duel.IsPlayerCanDraw(tp,1)
			-- 提示玩家是否选择适用回到卡组并抽卡的效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否回收并抽卡？"
			-- 提示玩家选择要回到卡组的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local sg=dg:Select(tp,1,1,nil)
			local dtc=sg:GetFirst()
			if dtc then
				-- 中断效果处理，使后续的回卡组和抽卡处理不视为与除外同时处理
				Duel.BreakEffect()
				-- 手动显示选择的回到卡组卡片的选定动画
				Duel.HintSelection(sg)
				-- 将选择的卡片送回卡组最下面，并确认其已成功送回卡组或额外卡组
				if Duel.SendtoDeck(dtc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and dtc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
					-- 中断效果处理，使后续的抽卡处理不视为与回卡组同时处理
					Duel.BreakEffect()
					-- 使玩家从卡组抽1张卡
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
		end
	end
end
