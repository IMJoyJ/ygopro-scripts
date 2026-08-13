--アブソーブポッド
-- 效果：
-- 反转∶场上盖放的魔法·陷阱卡全部破坏。破坏的卡的控制者从卡组抽出破坏数量的卡。这个回合，自己不能把卡盖放。
function c3900605.initial_effect(c)
	-- 反转∶场上盖放的魔法·陷阱卡全部破坏。破坏的卡的控制者从卡组抽出破坏数量的卡。这个回合，自己不能把卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c3900605.target)
	e1:SetOperation(c3900605.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：返回里侧表示的卡，用于筛选场上所有盖放的魔法·陷阱卡。
function c3900605.filter(c)
	return c:IsFacedown()
end
-- 反转效果的发动条件：效果必定满足发动条件；若发动，则取得场上所有里侧表示的魔法·陷阱卡，并将破坏这些卡的操作信息登记到连锁中。
function c3900605.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得双方场上所有里侧表示的魔法·陷阱卡（含场地魔法区域）作为破坏对象候选组。
	local g=Duel.GetMatchingGroup(c3900605.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 登记破坏效果的操作信息：需要破坏的卡为g中的所有卡，数量为g的卡数，用于连锁结算和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 反转效果处理：再次取得场上所有里侧表示的魔法·陷阱卡并全部破坏；统计被破坏卡中自己控制和对方控制的数量；错开时点后，双方各自抽取与己方被破坏卡数量相同的卡；最后给己方附加直到结束阶段的各种禁止盖放的限制。
function c3900605.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次取得双方场上所有里侧表示的魔法·陷阱卡，作为实际破坏的对象。
	local g=Duel.GetMatchingGroup(c3900605.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 以效果原因将这些里侧表示的魔法·陷阱卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
	-- 取得刚才破坏操作实际破坏的卡片组，用于统计双方被破坏的数量。
	local dg=Duel.GetOperatedGroup()
	local ct1=dg:FilterCount(Card.IsControler,nil,tp)
	local ct2=dg:GetCount()-ct1
	-- 中断当前效果处理，使后续的抽卡处理与破坏处理视为不同时处理，避免错过时点。
	Duel.BreakEffect()
	-- 若自己控制的被破坏卡数量不为0，则自己抽取与被破坏卡数量相同的卡。
	if ct1~=0 then Duel.Draw(tp,ct1,REASON_EFFECT) end
	-- 若对方控制的被破坏卡数量不为0，则对方抽取与被破坏卡数量相同的卡。
	if ct2~=0 then Duel.Draw(1-tp,ct2,REASON_EFFECT) end
	-- 这个回合，自己不能把卡盖放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 将该限制效果的目标条件设为始终成立，即对己方涉及盖放的行为均生效。
	e1:SetTarget(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能覆盖怪兽”的永续效果注册给己方，持续到回合结束阶段。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SSET)
	-- 将“不能覆盖魔法·陷阱卡”的永续效果注册给己方，持续到回合结束阶段。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TURN_SET)
	-- 将“不能变成里侧表示”的永续效果注册给己方，持续到回合结束阶段。
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e4:SetTarget(c3900605.sumlimit)
	-- 将“不能以里侧表示特殊召唤”的永续效果注册给己方，持续到回合结束阶段。
	Duel.RegisterEffect(e4,tp)
end
-- 特殊召唤位置限制的判定函数：若要使用的特殊召唤表示形式包含里侧表示，则禁止该特殊召唤。
function c3900605.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)~=0
end
