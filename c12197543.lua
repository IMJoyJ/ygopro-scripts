--剣の采配
-- 效果：
-- 对方的抽卡阶段时，对方通常抽卡时才能发动。抽到的卡给双方确认，确认的卡是魔法·陷阱卡的场合，从以下效果选择1个适用。
-- ●把抽到的卡丢弃。
-- ●选对方场上1张魔法·陷阱卡破坏。
function c12197543.initial_effect(c)
	-- 效果原文内容：对方的抽卡阶段时，对方通常抽卡时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DESTROY)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c12197543.condition)
	e1:SetOperation(c12197543.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断是否为对方通常抽卡阶段发动
function c12197543.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and r==REASON_RULE
end
-- 规则层面作用：过滤函数，用于筛选魔法·陷阱卡
function c12197543.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 规则层面作用：效果发动时执行的操作
function c12197543.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsLocation(LOCATION_HAND) then
		-- 规则层面作用：给玩家确认抽到的卡
		Duel.ConfirmCards(tp,tc)
		if tc:IsType(TYPE_SPELL+TYPE_TRAP) then
			-- 规则层面作用：获取对方场上满足条件的魔法·陷阱卡
			local g=Duel.GetMatchingGroup(c12197543.dfilter,tp,0,LOCATION_ONFIELD,nil)
			local opt=0
			if g:GetCount()==0 then
				-- 规则层面作用：选择丢弃抽到的卡
				opt=Duel.SelectOption(tp,aux.Stringid(12197543,0))  --"把抽到的卡丢弃。"
			else
				-- 规则层面作用：选择丢弃抽到的卡或破坏对方场上一张魔法·陷阱卡
				opt=Duel.SelectOption(tp,aux.Stringid(12197543,0),aux.Stringid(12197543,1))  --"把抽到的卡丢弃。" / "选对方场上1张魔法·陷阱卡破坏。"
			end
			-- 规则层面作用：将抽到的卡丢弃
			if opt==0 then Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)
			else
				-- 规则层面作用：提示玩家选择要破坏的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local dg=g:Select(tp,1,1,nil)
				-- 规则层面作用：破坏选择的魔法·陷阱卡
				Duel.Destroy(dg,REASON_EFFECT)
				-- 规则层面作用：洗切对方手牌
				Duel.ShuffleHand(1-tp)
			end
		end
	else
		-- 规则层面作用：洗切对方手牌
		Duel.ShuffleHand(1-tp)
	end
end
