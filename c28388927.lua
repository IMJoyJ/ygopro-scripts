--B・F－毒針のニードル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「蜂军-毒针之针刺蜂」以外的1只「蜂军」怪兽加入手卡。
-- ②：把这张卡以外的自己场上1只昆虫族怪兽解放，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c28388927.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「蜂军-毒针之针刺蜂」以外的1只「蜂军」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28388927,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,28388927)
	e1:SetTarget(c28388927.thtg)
	e1:SetOperation(c28388927.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把这张卡以外的自己场上1只昆虫族怪兽解放，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28388927,1))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,28388928)
	e3:SetCost(c28388927.cost)
	e3:SetTarget(c28388927.distg)
	e3:SetOperation(c28388927.disop)
	c:RegisterEffect(e3)
end
-- 检索过滤函数，用于筛选卡组中除自身外的「蜂军」怪兽
function c28388927.thfilter(c)
	return c:IsSetCard(0x12f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(28388927)
end
-- 效果处理时的条件判断，检查卡组中是否存在满足条件的卡片
function c28388927.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c28388927.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡牌类别为回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行卡组检索并加入手牌的操作
function c28388927.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c28388927.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 解放怪兽作为费用的处理函数
function c28388927.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在满足条件的可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,c,RACE_INSECT) end
	-- 选择场上满足条件的怪兽进行解放
	local rg=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,c,RACE_INSECT)
	-- 执行怪兽解放操作
	Duel.Release(rg,REASON_COST)
end
-- 无效化目标怪兽效果的处理函数
function c28388927.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断目标是否满足无效化条件
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查对方场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上满足条件的怪兽作为目标
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 执行怪兽效果无效化操作
function c28388927.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 使目标怪兽的效果在回合结束时恢复
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
