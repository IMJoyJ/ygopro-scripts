--列王詩篇
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。自己墓地没有怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：对方把场上的怪兽的效果发动时才能发动。那个效果无效。自己墓地有陷阱卡存在的场合，可以再从卡组把1张「统王」卡加入手卡。这张卡从手卡发动的场合，发动后，直到下个回合的结束时自己不能把手卡·墓地·除外状态的怪兽的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果，注册①效果（无效场上怪兽效果并检索）和手卡发动效果
function s.initial_effect(c)
	-- ①：对方把场上的怪兽的效果发动时才能发动。那个效果无效。自己墓地有陷阱卡存在的场合，可以再从卡组把1张「统王」卡加入手卡。
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
-- 检查①效果的发动条件：对方在场上发动了怪兽的效果，且该效果可以被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and rp==1-tp
		-- 检查效果发动的位置是否在场上，且该连锁效果是否可以被无效
		and re:GetActivateLocation()&LOCATION_ONFIELD~=0 and Duel.IsChainDisablable(ev)
end
-- ①效果的发动准备：设置无效效果的操作信息，并标记是否是从手卡发动
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：无效该发动效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		e:SetLabel(100)
	end
end
-- 过滤卡组中「统王」卡片且能加入手卡的过滤条件
function s.thfilter(c)
	return c:IsSetCard(0x1c6) and c:IsAbleToHand()
end
-- ①效果的处理：无效对方发动的效果，若自己墓地有陷阱卡且卡组有「统王」卡，可选择将其加入手卡
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 成功无效效果，且检查自己墓地是否存在陷阱卡
	if Duel.NegateEffect(ev) and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP)
		-- 检查卡组是否存在可检索的「统王」卡，并询问玩家是否将其加入手卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡加入手卡？"
		-- 给玩家发送提示信息：请选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足条件的「统王」卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续的加入手卡处理与无效效果不视为同时处理
			Duel.BreakEffect()
			-- 将选中的卡片加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if e:GetLabel()==100 then
		-- 这张卡从手卡发动的场合，发动后，直到下个回合的结束时自己不能把手卡·墓地·除外状态的怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 注册限制玩家发动怪兽效果的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制发动效果的过滤函数：禁止发动在手卡、墓地、除外状态的怪兽的效果
function s.aclimit(e,re,tp)
	return re:GetActivateLocation()&(LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)~=0 and re:IsActiveType(TYPE_MONSTER)
end
-- 手卡发动条件的判断函数：检查自己墓地是否存在怪兽
function s.handcon(e)
	-- 检查自己墓地的怪兽数量是否为0
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)==0
end
