--アブソーブポッド
-- 效果：
-- 反转∶场上盖放的魔法·陷阱卡全部破坏。破坏的卡的控制者从卡组抽出破坏数量的卡。这个回合，自己不能把卡盖放。
function c3900605.initial_effect(c)
	-- 反转效果：场上盖放的魔法·陷阱卡全部破坏。破坏的卡的控制者从卡组抽出破坏数量的卡。这个回合，自己不能把卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c3900605.target)
	e1:SetOperation(c3900605.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为里侧表示。
function c3900605.filter(c)
	return c:IsFacedown()
end
-- 效果处理：检索场上所有里侧表示的魔法·陷阱卡并设置为破坏目标。
function c3900605.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有里侧表示的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c3900605.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 设置连锁操作信息，将破坏的卡作为目标并设定破坏数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：破坏所有里侧表示的魔法·陷阱卡，并让其控制者抽取相应数量的卡。
function c3900605.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有里侧表示的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c3900605.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 将目标卡破坏。
	Duel.Destroy(g,REASON_EFFECT)
	-- 获取实际被破坏的卡组。
	local dg=Duel.GetOperatedGroup()
	local ct1=dg:FilterCount(Card.IsControler,nil,tp)
	local ct2=dg:GetCount()-ct1
	-- 中断当前效果处理，使后续效果视为错时点处理。
	Duel.BreakEffect()
	-- 若破坏卡中属于自己的卡数量大于0，则让该玩家从卡组抽相应数量的卡。
	if ct1~=0 then Duel.Draw(tp,ct1,REASON_EFFECT) end
	-- 若破坏卡中不属于自己的卡数量大于0，则让该玩家从卡组抽相应数量的卡。
	if ct2~=0 then Duel.Draw(1-tp,ct2,REASON_EFFECT) end
	-- 设置永续效果：自己不能覆盖怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 设置效果目标为所有卡片（即无限制）。
	e1:SetTarget(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SSET)
	-- 将效果注册给玩家。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TURN_SET)
	-- 将效果注册给玩家。
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e4:SetTarget(c3900605.sumlimit)
	-- 将效果注册给玩家。
	Duel.RegisterEffect(e4,tp)
end
-- 限制特殊召唤位置：不能以里侧表示特殊召唤。
function c3900605.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)~=0
end
