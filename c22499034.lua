--真竜戦士イグニスH
-- 效果：
-- 这张卡表侧表示上级召唤的场合，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。
-- ①：这张卡是已上级召唤的场合，1回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。从卡组选1张「真龙」永续魔法卡加入手卡或在自己场上发动。
function c22499034.initial_effect(c)
	-- 效果原文：这张卡表侧表示上级召唤的场合，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	-- 规则层面：设置效果目标为场上的永续魔法·永续陷阱卡（LOCATION_SZONE位置，且类型为TYPE_CONTINUOUS）
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_CONTINUOUS))
	e1:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡是已上级召唤的场合，1回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。从卡组选1张「真龙」永续魔法卡加入手卡或在自己场上发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22499034,1))  --"加入手卡或在自己场上发动"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c22499034.thcon)
	e2:SetTarget(c22499034.thtg)
	e2:SetOperation(c22499034.thop)
	c:RegisterEffect(e2)
end
-- 规则层面：判断此卡是否为上级召唤且对方发动了效果
function c22499034.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and rp==1-tp
end
-- 规则层面：过滤满足条件的「真龙」永续魔法卡（类型为TYPE_CONTINUOUS且可加入手卡或可发动）
function c22499034.thfilter(c,tp)
	return c:IsSetCard(0xf9) and c:GetType()==0x20002
		and (c:IsAbleToHand() or c:GetActivateEffect():IsActivatable(tp))
end
-- 规则层面：检测卡组中是否存在满足条件的卡，并设置操作信息为检索1张卡加入手牌
function c22499034.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检测卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c22499034.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 规则层面：设置连锁操作信息为检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果原文：从卡组选1张「真龙」永续魔法卡加入手卡或在自己场上发动。
function c22499034.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 规则层面：从卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c22499034.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		local b1=tc:IsAbleToHand()
		local b2=tc:GetActivateEffect():IsActivatable(tp)
		-- 规则层面：根据选择决定将卡加入手牌或在场上发动
		if b1 and (not b2 or Duel.SelectOption(tp,1190,1150)==0) then
			-- 规则层面：将选中的卡加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 规则层面：确认对方看到该卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 规则层面：将选中的卡移至场上（魔法陷阱区）并发动其效果
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local te=tc:GetActivateEffect()
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		end
	end
end
