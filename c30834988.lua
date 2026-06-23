--召喚制限－猛突するモンスター
-- 效果：
-- 这张卡在场上存在的场合怪兽特殊召唤成功时，那些怪兽变成表侧攻击表示。那个回合那些怪兽可以攻击的场合必须作出攻击。
function c30834988.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建并注册一个诱发效果，用于在怪兽特殊召唤成功时触发，使那些怪兽变成表侧攻击表示，并强制其必须攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30834988,0))  --"变成攻击表示"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c30834988.target)
	e2:SetOperation(c30834988.operation)
	c:RegisterEffect(e2)
end
-- 设置连锁处理的目标卡片组为怪兽特殊召唤时的参与怪兽。
function c30834988.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前处理的连锁对象设置为怪兽特殊召唤时的参与怪兽。
	Duel.SetTargetCard(eg)
	-- 设置当前处理的连锁操作信息为改变表示形式效果，目标为参与特殊召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
end
-- 处理特殊召唤成功后的效果，将符合条件的怪兽变为表侧攻击表示，并为它们添加必须攻击的效果。
function c30834988.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsRelateToEffect,nil,e)
	-- 将符合条件的怪兽改变为表侧攻击表示。
	Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	local tc=g:GetFirst()
	while tc do
		-- 为每个符合条件的怪兽添加必须攻击的效果，该效果在回合结束时重置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	local ct,last_turn,last_lp_0,last_lp_1,last_deck_0,last_deck_1=e:GetLabel()
	-- 获取当前回合数，用于判断是否需要重置计数器。
	local turn=Duel.GetTurnCount()
	-- 获取玩家0的当前LP值，用于判断是否需要重置计数器。
	local lp_0=Duel.GetLP(0)
	-- 获取玩家1的当前LP值，用于判断是否需要重置计数器。
	local lp_1=Duel.GetLP(1)
	-- 获取玩家0卡组剩余卡数，用于判断是否需要重置计数器。
	local deck_0=Duel.GetFieldGroupCount(0,LOCATION_DECK,0)
	-- 获取玩家1卡组剩余卡数，用于判断是否需要重置计数器。
	local deck_1=Duel.GetFieldGroupCount(1,LOCATION_DECK,0)
	if ct==nil
		or last_turn~=turn or last_lp_0~=lp_0 or last_lp_1~=lp_1 or last_deck_0-deck_0>5 or last_deck_1-deck_1>5 then
		e:SetLabel(0,turn,lp_0,lp_1,deck_0,deck_1)
	else
		ct=ct+1
		if ct>10 then
			-- 当满足条件时，将该卡送入墓地以防止无限循环。
			Duel.SendtoGrave(c,REASON_RULE)
			return
		end
		e:SetLabel(ct,turn,lp_0,lp_1,last_deck_0,last_deck_1)
	end
end
