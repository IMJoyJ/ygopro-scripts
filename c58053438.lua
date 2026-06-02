--列王詩篇
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。自己墓地没有怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：对方把场上的怪兽的效果发动时才能发动。那个效果无效。自己墓地有陷阱卡存在的场合，可以再从卡组把1张「统王」卡加入手卡。这张卡从手卡发动的场合，发动后，直到下个回合的结束时自己不能把手卡·墓地·除外状态的怪兽的效果发动。
local s,id,o=GetID()
-- 注册卡片的发动效果①（对方把场上怪兽效果发动时使其无效，且自己墓地有陷阱卡时可检索卡组「统王」卡，从手卡发动时自身直到下个回合结束时不能把手卡·墓地·除外状态怪兽效果发动）以及支持手卡发动的条件效果
function s.initial_effect(c)
	-- ①：对方把场上的怪兽的效果发动时才能发动。那个效果无效。自己墓地有陷阱卡存在的场合，可以再从卡组把1张「统王」卡加入手卡。这张卡从手卡发动的场合，发动后，直到下个回合的结束时自己不能把手卡·墓地·除外状态的怪兽的效果发动。这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- 自己墓地没有怪兽存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"适用「列王诗篇」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：对方发动场上的怪兽的效果时，且该效果可以被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and rp==1-tp
		-- 检查对方发动效果时怪兽是在场上，且该发动在连锁中能够被无效
		and re:GetActivateLocation()&LOCATION_ONFIELD~=0 and Duel.IsChainDisablable(ev)
end
-- 效果①的发动准备：设置无效效果的操作信息，并在该卡是从手牌发动时标记状态标签
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	if chk==0 then return true end
	-- 设置当前效果处理的操作信息为使该效果发动无效，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		e:SetLabel(100)
	end
end
-- 过滤条件：卡组中可以加入手牌的「统王」卡
function s.thfilter(c)
	return c:IsSetCard(0x1c6) and c:IsAbleToHand()
end
-- 效果①的效果处理：使对方的效果发动无效，满足条件时可以检索卡组「统王」卡，且若从手卡发动则适用限制自己不能把手手卡·墓地·除外状态怪兽效果发动的效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方发动的效果无效，并检查自己墓地是否存在至少1张陷阱卡
	if Duel.NegateEffect(ev) and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP)
		-- 检查自己卡组是否存在符合条件的「统王」卡，并询问玩家是否将卡片加入手牌
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡加入手卡？"
		-- 向玩家发送选择提示信息：“请选择要加入手牌的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组选择1张「统王」卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果，使前后的无效效果与加入手牌效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的「统王」卡加入玩家手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家展示并确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if e:GetLabel()==100 then
		-- 这张卡从手卡发动的场合，发动后，直到下个回合的结束时自己不能把手卡·墓地·除外状态的怪兽的效果发动。自己墓地没有怪兽存在的场合，这张卡的发动从手卡也能用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))  --"「列王诗篇」效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将不能把手卡·墓地·除外状态怪兽效果发动的限制效果注册给玩家自身
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制的条件：不能把在手牌、墓地、除外状态的怪兽效果发动
function s.aclimit(e,re,tp)
	return re:GetActivateLocation()&(LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)~=0 and re:IsActiveType(TYPE_MONSTER)
end
-- 从手手卡发动的条件：检查自己墓地中是否存在怪兽卡
function s.handcon(e)
	-- 检查玩家自身墓地中的怪兽卡数量是否为0
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)==0
end
