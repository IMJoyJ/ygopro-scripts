--真竜戦士イグニスH
-- 效果：
-- 这张卡表侧表示上级召唤的场合，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。
-- ①：这张卡是已上级召唤的场合，1回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。从卡组选1张「真龙」永续魔法卡加入手卡或在自己场上发动。
function c22499034.initial_effect(c)
	-- 这张卡表侧表示上级召唤的场合，可以作为怪兽的代替而把自己场上的永续魔法·永续陷阱卡解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	-- 设置追加解放的筛选条件：只有自己场上的永续魔法·永续陷阱卡可以作为这张卡上级召唤时代替怪兽的解放素材。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_CONTINUOUS))
	e1:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e1)
	-- ①：这张卡是已上级召唤的场合，1回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。从卡组选1张「真龙」永续魔法卡加入手卡或在自己场上发动。
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
-- 该效果的发动条件：这张卡已经通过上级召唤出场，且对方玩家发动了魔法·陷阱·怪兽的效果（rp==1-tp）。
function c22499034.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and rp==1-tp
end
-- 检索的过滤条件：从卡组中筛选1张卡名属于「真龙」系列的永续魔法卡，并且该卡能够加入手卡，或者其自身的魔法卡发动效果在当前状态下可以被自己发动。
function c22499034.thfilter(c,tp)
	return c:IsSetCard(0xf9) and c:GetType()==0x20002
		and (c:IsAbleToHand() or c:GetActivateEffect():IsActivatable(tp))
end
-- 发动时点检查：确认自己卡组是否存在至少1张符合条件的「真龙」永续魔法卡，如果存在则本次效果可以发动，并设置操作信息为从卡组将卡加入手卡。
function c22499034.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查卡组中是否存在至少1张满足c22499034.thfilter条件的卡，作为发动是否合法的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c22499034.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置本次连锁的操作信息：预期将1张卡从卡组加入手卡（用于给其他卡或时点检测本效果的行为）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张符合条件的「真龙」永续魔法卡，根据玩家选择将其加入手卡，或在自己场上表侧表示发动；若选择发动则还需要支付该卡自身的魔法卡发动cost。
function c22499034.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择卡片的提示信息，提示文字为“请选择要操作的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从自己卡组中选出1张满足c22499034.thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c22499034.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		local b1=tc:IsAbleToHand()
		local b2=tc:GetActivateEffect():IsActivatable(tp)
		-- 如果该卡既能加入手卡又能发动，则让玩家选择“加入手卡”或“在自己场上发动”；若只能加入手卡（或玩家选择加入手卡），则执行加入手卡的分支，否则执行场上发动的分支。
		if b1 and (not b2 or Duel.SelectOption(tp,1190,1150)==0) then
			-- 将选中的那张卡以效果原因加入其持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示确认被加入手卡的那张卡。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的卡以表侧表示放置到自己的魔法与陷阱区域，即作为永续魔法卡在自己场上发动。
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local te=tc:GetActivateEffect()
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		end
	end
end
