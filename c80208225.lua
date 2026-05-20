--星辰の刺毒
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方墓地的怪兽和魔法·陷阱卡各最多1张为对象才能发动。那些卡除外。那之后，以下效果可以适用。
-- ●「星辰的刺毒」以外的自己的墓地·除外状态的1张「星辰」卡回到卡组最下面。那之后，自己抽1张。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
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
-- 定义选择子组的过滤条件：所选卡片中魔法·陷阱卡最多1张，且怪兽卡最多1张
function s.fselect(g)
	return g:FilterCount(Card.IsType,nil,TYPE_SPELL+TYPE_TRAP)<=1 and g:FilterCount(Card.IsType,nil,TYPE_MONSTER)<=1
end
-- 过滤自己墓地或除外状态下「星辰的刺毒」以外的「星辰」卡
function s.tdfilter(c)
	return c:IsSetCard(0x1c9) and not c:IsCode(id) and c:IsAbleToDeck()
		and c:IsFaceupEx()
end
-- 效果发动时的对象选择与目标确认处理
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动时检查对方墓地是否存在可作为效果对象并除外的卡
	if chk==0 then return Duel.GetMatchingGroupCount(aux.AND(Card.IsAbleToRemove,Card.IsCanBeEffectTarget),tp,0,LOCATION_GRAVE,nil,e)>0 end
	-- 获取对方墓地中所有可作为效果对象并除外的卡
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsAbleToRemove,Card.IsCanBeEffectTarget),tp,0,LOCATION_GRAVE,nil,e)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,1,2)
	-- 将选中的卡片注册为效果的对象
	Duel.SetTargetCard(sg)
	-- 设置除外操作的效果分类与对象卡片等连锁信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
-- 效果处理的激活函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与连锁相关且不受王家长眠之谷影响的对象卡片
	local rg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if #rg==0 then return end
	-- 将对象卡片表侧表示除外，若成功除外则继续处理
	if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
		-- 获取自己墓地及除外状态下所有可回到卡组的「星辰」卡
		local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		-- 检查是否存在可回到卡组的卡，且自己是否可以抽卡
		if dg:GetCount()>0 and Duel.IsPlayerCanDraw(tp,1)
			-- 询问玩家是否适用后续的回收并抽卡效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否回收并抽卡？"
			-- 提示玩家选择要返回卡组的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local sg=dg:Select(tp,1,1,nil)
			local dtc=sg:GetFirst()
			if dtc then
				-- 中断效果处理，使后续的回收操作与除外操作不视为同时进行
				Duel.BreakEffect()
				-- 在场上/卡片区域显式展示被选中的卡片
				Duel.HintSelection(sg)
				-- 将选中的卡片送回卡组最下方，若成功送回则继续处理
				if Duel.SendtoDeck(dtc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and dtc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
					-- 中断效果处理，使后续的抽卡操作与回到卡组操作不视为同时进行
					Duel.BreakEffect()
					-- 让玩家从卡组抽1张卡
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
		end
	end
end
