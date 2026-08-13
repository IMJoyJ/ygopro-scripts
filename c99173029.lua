--霊子エネルギー固定装置
-- 效果：
-- 只要这张卡在场上存在，灵魂怪兽持续留在场上。自己的结束阶段时丢弃1张手卡，若不丢弃，这张卡破坏。并且，这张卡从场上离开时，在场上存在的表侧表示的灵魂怪兽全部回到持有者的手卡。
function c99173029.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，灵魂怪兽持续留在场上。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPIRIT_DONOT_RETURN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	c:RegisterEffect(e2)
	-- 并且，这张卡从场上离开时，在场上存在的表侧表示的灵魂怪兽全部回到持有者的手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c99173029.levop)
	c:RegisterEffect(e3)
	-- 自己的结束阶段时丢弃1张手卡，若不丢弃，这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c99173029.mtcon)
	e4:SetOperation(c99173029.mtop)
	c:RegisterEffect(e4)
end
c99173029.has_text_type=TYPE_SPIRIT
-- 筛选场上表侧表示的灵魂怪兽，作为后续返回手牌的对象。
function c99173029.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPIRIT)
end
-- 这张卡从场上离开时，将场上所有表侧表示的灵魂怪兽加入持有者手牌。
function c99173029.levop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有表侧表示的灵魂怪兽。
	local g=Duel.GetMatchingGroup(c99173029.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 以效果原因将这些灵魂怪兽返回持有者手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 该效果的发动条件：仅在当前回合玩家为自己时才能执行。
function c99173029.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- 自己的结束阶段时，选择丢弃一张手牌或破坏此卡；若不丢弃手牌则这张卡破坏。
function c99173029.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己手牌数量大于0且玩家选择丢弃一张手牌来维持此卡，则执行丢弃；否则破坏此卡。
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Duel.SelectYesNo(tp,aux.Stringid(99173029,0)) then  --"是否要丢弃一张手牌维持「灵子能固定装置」？"
		-- 从自己手牌中选择1张丢弃作为维持代价（COST）。
		Duel.DiscardHand(tp,nil,1,1,REASON_COST+REASON_DISCARD)
	else
		-- 因未丢弃手牌而用规则代价破坏这张卡。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
