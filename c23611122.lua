--急雷の泥沼
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，以下效果可以适用。
-- ●选自己1张手卡丢弃，除丢弃的卡外的1张持有把自身作为怪兽特殊召唤效果的永续陷阱卡从自己的卡组·墓地到自己场上盖放。
-- ②：自己场上的卡因战斗·效果而破坏，被送去墓地的场合或者被表侧除外的场合，以那之内的1张为对象才能发动。那1张同名卡从卡组加入手卡。
local s,id,o=GetID()
-- 注册卡的效果，包括发动时的效果和检索效果
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，以下效果可以适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 注册一个合并的延迟事件监听器，用于监听送去墓地或除外的事件
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,{EVENT_TO_GRAVE,EVENT_REMOVE})
	-- ②：自己场上的卡因战斗·效果而破坏，被送去墓地的场合或者被表侧除外的场合，以那之内的1张为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(custom_code)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤满足特殊召唤条件的永续陷阱卡
function s.setfilter(c)
	return c:IsAllTypes(TYPE_CONTINUOUS+TYPE_TRAP) and c:IsSSetable()
		and (c:GetOriginalLevel()>0
		or bit.band(c:GetOriginalRace(),0x3fffffff)~=0
		or bit.band(c:GetOriginalAttribute(),0x7f)~=0
		or c:GetBaseAttack()>0
		or c:GetBaseDefense()>0)
end
-- 发动时处理效果，选择丢弃手卡并从卡组·墓地盖放陷阱
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足特殊召唤条件的永续陷阱卡组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 获取玩家手卡组
	local dg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil,REASON_EFFECT+REASON_DISCARD)
	-- 判断是否满足发动条件，包括有可盖放的陷阱和可丢弃的手卡
	if g:GetCount()>0 and dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否丢弃手卡并盖放陷阱？"
		-- 丢弃1张手卡
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
		-- 获取丢弃的手卡
		local tg=Duel.GetOperatedGroup()
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(tp,1,1,tg)
		-- 将选中的卡盖放到场上
		Duel.SSet(tp,sg)
	end
end
-- 过滤满足检索条件的卡
function s.thfilter(c,e,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsFaceupEx()
		and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		-- 判断是否满足检索条件，即卡组中存在同名卡
		and c:IsCanBeEffectTarget(e) and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤满足加入手牌条件的卡
function s.thfilter2(c,code)
	return c:IsAbleToHand() and c:IsCode(code)
end
-- 设置检索效果的目标和操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:FilterCount(s.thfilter,nil,e,tp)>0 end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local tg
	if #eg==1 then
		tg=eg:Clone()
	else
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tg=eg:FilterSelect(tp,s.thfilter,1,1,nil,e,tp)
	end
	-- 设置当前连锁的效果对象
	Duel.SetTargetCard(tg)
	-- 设置操作信息，包括要加入手牌的卡数量和位置
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理检索效果，将符合条件的卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 判断效果对象是否有效且卡组中存在同名卡
	if tc:IsRelateToChain() and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,tc:GetCode()) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择要加入手牌的卡
		local sg=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode())
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
