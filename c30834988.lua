--召喚制限－猛突するモンスター
-- 效果：
-- 这张卡在场上存在的场合怪兽特殊召唤成功时，那些怪兽变成表侧攻击表示。那个回合那些怪兽可以攻击的场合必须作出攻击。
function c30834988.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这张卡在场上存在的场合怪兽特殊召唤成功时，那些怪兽变成表侧攻击表示。
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
-- 效果发动时的判定函数：无条件通过判定（chk==0即返回true），将特殊召唤成功的所有怪兽登记为当前连锁的对象，并设置操作信息为“变更表示形式”，用于后续相关效果判定。
function c30834988.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次特殊召唤成功的怪兽组（eg）设为当前连锁处理的（广义）对象，确保后续处理时能正确关联这些怪兽。
	Duel.SetTargetCard(eg)
	-- 设置连锁操作信息：效果类别为变更表示形式（CATEGORY_POSITION），对象为eg，数量为eg:GetCount()，且未指定玩家和位置，供其他效果（如星尘龙等）进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
end
-- 效果处理：先筛选出与本次效果关联的特殊召唤成功的怪兽，将它们全部变为表侧攻击表示；再给这些怪兽各注册一个“必须攻击”的效果（持续到结束阶段）。后续代码为防无限循环保护：记录当前回合数、双方LP和卡组数量，若在状态几乎未变化的情况下连续触发超过10次，则将此卡以规则理由送入墓地以终止循环。
function c30834988.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选出的特殊召唤成功怪兽全部变为表侧攻击表示。
	Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	local tc=g:GetFirst()
	while tc do
		-- 那个回合那些怪兽可以攻击的场合必须作出攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	local ct,last_turn,last_lp_0,last_lp_1,last_deck_0,last_deck_1=e:GetLabel()
	-- 获取当前回合数，用于防无限循环保护中判断是否处于同一回合状态。
	local turn=Duel.GetTurnCount()
	-- 获取玩家0的当前LP，用于检测LP是否发生变化以判断是否陷入重复触发循环。
	local lp_0=Duel.GetLP(0)
	-- 获取玩家1的当前LP，用于检测LP是否发生变化以判断是否陷入重复触发循环。
	local lp_1=Duel.GetLP(1)
	-- 获取玩家0卡组当前剩余卡数，用于检测卡组数量是否骤减，作为循环检测依据之一。
	local deck_0=Duel.GetFieldGroupCount(0,LOCATION_DECK,0)
	-- 获取玩家1卡组当前剩余卡数，用于检测卡组数量是否骤减，作为循环检测依据之一。
	local deck_1=Duel.GetFieldGroupCount(1,LOCATION_DECK,0)
	if ct==nil
		or last_turn~=turn or last_lp_0~=lp_0 or last_lp_1~=lp_1 or last_deck_0-deck_0>5 or last_deck_1-deck_1>5 then
		e:SetLabel(0,turn,lp_0,lp_1,deck_0,deck_1)
	else
		ct=ct+1
		if ct>10 then
			-- 当检测到疑似无限循环时，将这张卡以规则理由（REASON_RULE）送入墓地，强制终止该效果的反复处理。
			Duel.SendtoGrave(c,REASON_RULE)
			return
		end
		e:SetLabel(ct,turn,lp_0,lp_1,last_deck_0,last_deck_1)
	end
end
