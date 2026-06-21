--剣の采配
-- 效果：
-- 对方的抽卡阶段时，对方通常抽卡时才能发动。抽到的卡给双方确认，确认的卡是魔法·陷阱卡的场合，从以下效果选择1个适用。
-- ●把抽到的卡丢弃。
-- ●选对方场上1张魔法·陷阱卡破坏。
function c12197543.initial_effect(c)
	-- 对方的抽卡阶段时，对方通常抽卡时才能发动。抽到的卡给双方确认，确认的卡是魔法·陷阱卡的场合，从以下效果选择1个适用。●把抽到的卡丢弃。●选对方场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_HANDES_OPPO+CATEGORY_DESTROY)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c12197543.condition)
	e1:SetOperation(c12197543.activate)
	c:RegisterEffect(e1)
end
-- 判断是否为对方玩家在抽卡阶段的通常抽卡
function c12197543.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and r==REASON_RULE
end
-- 过滤魔法·陷阱卡
function c12197543.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 卡片发动后的效果处理
function c12197543.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsLocation(LOCATION_HAND) then
		-- 将抽到的卡给双方确认
		Duel.ConfirmCards(tp,tc)
		if tc:IsType(TYPE_SPELL+TYPE_TRAP) then
			-- 获取对方场上的魔法·陷阱卡
			local g=Duel.GetMatchingGroup(c12197543.dfilter,tp,0,LOCATION_ONFIELD,nil)
			local opt=0
			if g:GetCount()==0 then
				-- 若对方场上没有魔法·陷阱卡，则只能选择丢弃该卡
				opt=Duel.SelectOption(tp,aux.Stringid(12197543,0))  --"把抽到的卡丢弃。"
			else
				-- 让玩家从“把抽到的卡丢弃”与“选对方场上1张魔法·陷阱卡破坏”中选择一项效果适用
				opt=Duel.SelectOption(tp,aux.Stringid(12197543,0),aux.Stringid(12197543,1))  --"把抽到的卡丢弃。/选对方场上1张魔法·陷阱卡破坏。"
			end
			-- 若选择丢弃选项，则将对方抽到的卡丢弃
			if opt==0 then Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)
			else
				-- 提示玩家选择要破坏的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				local dg=g:Select(tp,1,1,nil)
				-- 破坏被选中的魔法·陷阱卡
				Duel.Destroy(dg,REASON_EFFECT)
				-- 洗切对方的手牌
				Duel.ShuffleHand(1-tp)
			end
		end
	else
		-- 若抽到的卡已离开手牌，则洗切对方的手牌
		Duel.ShuffleHand(1-tp)
	end
end
