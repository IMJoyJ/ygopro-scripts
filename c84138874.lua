--ヴォルカニック・インフェルノ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把场上的怪兽的效果发动时，从自己墓地把1只炎族怪兽除外才能发动。给与对方500伤害。把「火山」怪兽除外发动的场合，可以再把那个发动的效果无效。
-- ②：对方结束阶段，以自己的墓地·除外状态的最多2只「火山」怪兽为对象才能发动。那些怪兽用喜欢的顺序回到卡组下面。
function c84138874.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方把场上的怪兽的效果发动时，从自己墓地把1只炎族怪兽除外才能发动。给与对方500伤害。把「火山」怪兽除外发动的场合，可以再把那个发动的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84138874,0))  --"给与对方伤害"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,84138874)
	e2:SetCondition(c84138874.discon)
	e2:SetCost(c84138874.discost)
	e2:SetTarget(c84138874.distg)
	e2:SetOperation(c84138874.disop)
	c:RegisterEffect(e2)
	-- ②：对方结束阶段，以自己的墓地·除外状态的最多2只「火山」怪兽为对象才能发动。那些怪兽用喜欢的顺序回到卡组下面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84138874,1))  --"回收墓地·除外的怪兽"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,84138875)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCondition(c84138874.tdcon)
	e3:SetTarget(c84138874.tdtg)
	e3:SetOperation(c84138874.tdop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定函数
function c84138874.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否为对方在场上发动的怪兽效果，且该效果可以被无效
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		and re:GetActivateLocation()==LOCATION_MZONE
end
-- 过滤自己墓地中可以作为cost除外的炎族怪兽
function c84138874.cfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果①的发动代价处理函数，除外1只炎族怪兽并记录其是否为「火山」怪兽
function c84138874.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己墓地是否存在至少1只可以除外的炎族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84138874.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的炎族怪兽
	local g=Duel.SelectMatchingCard(tp,c84138874.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	if g:GetFirst():IsSetCard(0x32) then e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 效果①的发动准备与效果分类声明函数
function c84138874.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	-- 设置效果处理的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的伤害数值为500
	Duel.SetTargetParam(500)
	-- 声明该效果包含给与对方500点伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果①的效果处理函数，给与对方伤害并根据代价决定是否无效该发动
function c84138874.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的伤害对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 判定是否成功给与对方伤害，且发动代价除外的是「火山」怪兽
	if Duel.Damage(p,d,REASON_EFFECT)>0 and e:GetLabel()>0
		-- 询问玩家是否选择将该发动的效果无效
		and Duel.SelectYesNo(tp,aux.Stringid(84138874,2)) then  --"是否把发动的效果无效？"
		-- 中断当前效果处理，使后续的无效处理不与伤害同时发生
		Duel.BreakEffect()
		-- 将该发动的效果无效
		Duel.NegateEffect(ev)
	end
end
-- 效果②的发动条件判定函数
function c84138874.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合的结束阶段
	return Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_END
end
-- 过滤自己墓地或除外状态可以回到卡组的「火山」怪兽
function c84138874.tdfilter(c)
	return c:IsSetCard(0x32) and c:IsType(TYPE_MONSTER) and c:IsFaceupEx() and c:IsAbleToDeck()
end
-- 效果②的发动准备与取对象函数
function c84138874.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c84138874.tdfilter(chkc) end
	-- 判定自己墓地或除外状态是否存在至少1只可以回到卡组的「火山」怪兽
	if chk==0 then return Duel.IsExistingTarget(c84138874.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1到2只满足条件的「火山」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c84138874.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,2,nil)
	-- 声明该效果包含将选中的卡片送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果②的效果处理函数
function c84138874.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在连锁处理时仍符合条件的对象卡片
	local sg=Duel.GetTargetsRelateToChain()
	if #sg==0 then return end
	-- 将目标卡片以玩家选择的顺序放回卡组最下方
	aux.PlaceCardsOnDeckBottom(tp,sg)
end
