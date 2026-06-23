--魔導天士 トールモンド
-- 效果：
-- 这张卡用魔法师族怪兽或者名字带有「魔导书」的魔法卡的效果特殊召唤成功时，可以选择自己墓地2张名字带有「魔导书」的魔法卡加入手卡。这个效果发动的回合，自己不能把其他怪兽特殊召唤。这个效果把卡加入手卡时，把手卡的名字带有「魔导书」的魔法卡4种类给对方观看才能发动。这张卡以外的场上的卡全部破坏。
function c29146185.initial_effect(c)
	-- 这张卡用魔法师族怪兽或者名字带有「魔导书」的魔法卡的效果特殊召唤成功时，可以选择自己墓地2张名字带有「魔导书」的魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29146185,0))  --"返回手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c29146185.retcon)
	e1:SetCost(c29146185.retcost)
	e1:SetTarget(c29146185.rettg)
	e1:SetOperation(c29146185.retop)
	c:RegisterEffect(e1)
	-- 这张卡以外的场上的卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29146185,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_CUSTOM+29146185)
	e2:SetCost(c29146185.descost)
	e2:SetTarget(c29146185.destg)
	e2:SetOperation(c29146185.desop)
	c:RegisterEffect(e2)
end
-- 判断特殊召唤方式是否为魔法师族怪兽或名字带有「魔导书」的魔法卡。
function c29146185.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local typ,race=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return (typ&TYPE_MONSTER~=0 and race&RACE_SPELLCASTER~=0) or (typ&TYPE_SPELL~=0 and c:IsSpecialSummonSetCard(0x106e))
end
-- 设置效果发动时不能再次特殊召唤的限制。
function c29146185.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否为该回合第一次特殊召唤。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==1 end
	-- 注册不能特殊召唤的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 定义过滤器，用于筛选名字带有「魔导书」的魔法卡。
function c29146185.filter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置选择目标的条件，从墓地选择2张名字带有「魔导书」的魔法卡。
function c29146185.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c29146185.filter(chkc) end
	-- 检查是否存在满足条件的2张目标卡。
	if chk==0 then return Duel.IsExistingTarget(c29146185.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的2张目标卡。
	local g=Duel.SelectTarget(tp,c29146185.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置操作信息，将选择的卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 处理效果发动后的操作。
function c29146185.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中选定的目标卡组并筛选出与效果相关的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将卡送入手牌。
	if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 向对方确认手牌中的卡。
		Duel.ConfirmCards(1-tp,g)
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 触发自定义事件，用于发动破坏效果。
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+29146185,re,r,rp,0,0)
		end
	end
end
-- 定义过滤器，用于筛选手牌中名字带有「魔导书」且未公开的魔法卡。
function c29146185.cffilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 设置破坏效果的发动条件，需要确认4种类手牌。
function c29146185.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手牌中满足条件的卡组。
	local g=Duel.GetMatchingGroup(c29146185.cffilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=4 end
	-- 提示玩家选择给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择4种类不同的卡。
	local cg=g:SelectSubGroup(tp,aux.dncheck,false,4,4)
	-- 向对方确认选择的卡。
	Duel.ConfirmCards(1-tp,cg)
	-- 洗切自己的手牌。
	Duel.ShuffleHand(tp)
end
-- 设置破坏效果的目标条件。
function c29146185.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上所有卡的卡组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置操作信息，将场上所有卡破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 处理破坏效果的操作。
function c29146185.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有卡的卡组，排除自身。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将卡破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
