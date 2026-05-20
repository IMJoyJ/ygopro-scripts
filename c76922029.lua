--首領・ザルーグ
-- 效果：
-- 这张卡给与对方玩家战斗伤害时，可以选择下面1个效果发动：
-- ●对方随机丢弃1张手卡。
-- ●对方的卡组最上面的2张卡送去墓地。
function c76922029.initial_effect(c)
	-- 这张卡给与对方玩家战斗伤害时，可以选择下面1个效果发动：●对方随机丢弃1张手卡。●对方的卡组最上面的2张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76922029,0))  --"选择一个效果发动"
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c76922029.condition)
	e1:SetTarget(c76922029.target)
	e1:SetOperation(c76922029.operation)
	c:RegisterEffect(e1)
end
-- 判定受到伤害的玩家是否为对方玩家（即给与对方玩家战斗伤害时）
function c76922029.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动时的合法性检测、分支选择处理以及设置对应的操作信息
function c76922029.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检测对方手牌是否大于0，或者对方是否能将卡组顶端2张卡送去墓地
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 or Duel.IsPlayerCanDiscardDeck(1-tp,2) end
	local op=0
	-- 在系统提示栏显示“选择一个效果发动”
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(76922029,0))  --"选择一个效果发动"
	-- 如果对方手牌数量大于0，且对方卡组可以被送去墓地2张卡
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.IsPlayerCanDiscardDeck(1-tp,2) then
		-- 让玩家选择“对方随机丢弃1张手牌”或“对方的卡组最上面的2张卡送去墓地”
		op=Duel.SelectOption(tp,aux.Stringid(76922029,1),aux.Stringid(76922029,2))  --"对方随机丢弃1张手牌。/对方的卡组最上面的2张卡送去墓地。"
	-- 如果只有对方手牌数量大于0
	elseif Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
		-- 强制选择“对方随机丢弃1张手牌”效果
		Duel.SelectOption(tp,aux.Stringid(76922029,1))  --"对方随机丢弃1张手牌。"
		op=0
	else
		-- 强制选择“对方的卡组最上面的2张卡送去墓地”效果
		Duel.SelectOption(tp,aux.Stringid(76922029,2))  --"对方的卡组最上面的2张卡送去墓地。"
		op=1
	end
	e:SetLabel(op)
	-- 如果选择丢弃手牌效果，则设置操作信息为对方丢弃1张手牌
	if op==0 then Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
	-- 如果选择卡组送墓效果，则设置操作信息为对方卡组送去墓地2张卡
	else Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,2) end
end
-- 效果处理函数，根据玩家的选择执行丢弃手牌或卡组送墓的操作
function c76922029.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取受到伤害的玩家（对方）的手牌组
		local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
		local sg=g:RandomSelect(ep,1)
		-- 将随机选出的1张手牌以效果丢弃的形式送去墓地
		Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
	else
		-- 将对方卡组最上面的2张卡因效果送去墓地
		Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
	end
end
