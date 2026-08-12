--真竜拳士ダイナマイトK
-- 效果：
-- 这张卡表侧表示上级召唤的场合，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。
-- ①：这张卡是已上级召唤的场合，1回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。从卡组选1张「真龙」永续陷阱卡加入手卡或在自己场上发动。
function c58984738.initial_effect(c)
	-- 这张卡表侧表示上级召唤的场合，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	-- 设置解放代替的目标为永续卡（永续魔法或永续陷阱）
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_CONTINUOUS))
	e1:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e1)
	-- ①：这张卡是已上级召唤的场合，1回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。从卡组选1张「真龙」永续陷阱卡加入手卡或在自己场上发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58984738,1))  --"加入手卡或在自己场上发动"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c58984738.thcon)
	e2:SetTarget(c58984738.thtg)
	e2:SetOperation(c58984738.thop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为上级召唤成功，且当前连锁的发动方为对方
function c58984738.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and rp==1-tp
end
-- 过滤卡组中属于「真龙」字段的永续陷阱卡，且该卡可以加入手卡或在场上发动
function c58984738.thfilter(c,tp)
	return c:IsSetCard(0xf9) and c:GetType()==0x20004
		and (c:IsAbleToHand() or c:GetActivateEffect():IsActivatable(tp))
end
-- 效果发动的靶向与可行性检测，并设置操作信息
function c58984738.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张满足条件的「真龙」永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c58984738.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置当前连锁的操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选1张「真龙」永续陷阱卡，由玩家选择将其加入手卡或在场上发动
function c58984738.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送提示信息，要求玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「真龙」永续陷阱卡
	local g=Duel.SelectMatchingCard(tp,c58984738.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		local b1=tc:IsAbleToHand()
		local b2=tc:GetActivateEffect():IsActivatable(tp)
		-- 判断是否将卡加入手卡（若不能发动，或玩家在“加入手卡”与“在场上发动”中选择了“加入手卡”）
		if b1 and (not b2 or Duel.SelectOption(tp,1190,1150)==0) then
			-- 将选中的卡片加入玩家手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的永续陷阱卡在自己的魔法与陷阱区域表侧表示放置并适用其效果（即在场上发动）
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local te=tc:GetActivateEffect()
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		end
	end
end
