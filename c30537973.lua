--捕食植物スパイダー・オーキッド
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：这张卡发动的回合的自己主要阶段，以这张卡以外的魔法与陷阱区域1张表侧表示的卡为对象才能发动。那张卡破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的回合的结束阶段，从手卡丢弃1只植物族怪兽才能发动。从卡组把1只4星以下的植物族怪兽加入手卡。
function c30537973.initial_effect(c)
	-- 为这张卡附加灵摆怪兽属性（灵摆召唤/灵摆卡发动），但不注册灵摆卡‘卡的发动’的效果，因此后续手动注册从手卡发动并打上誓约标记的效果。
	aux.EnablePendulumAttribute(c,false)
	-- 这张卡发动的回合
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c30537973.reg)
	c:RegisterEffect(e1)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：这张卡发动的回合的自己主要阶段，以这张卡以外的魔法与陷阱区域1张表侧表示的卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30537973,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,30537973)
	e2:SetCondition(c30537973.descon)
	e2:SetTarget(c30537973.destg)
	e2:SetOperation(c30537973.desop)
	c:RegisterEffect(e2)
	-- 这个卡名的怪兽效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的回合的结束阶段，从手卡丢弃1只植物族怪兽才能发动。从卡组把1只4星以下的植物族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30537973,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,30537974)
	e3:SetCost(c30537973.thcost)
	e3:SetTarget(c30537973.thtg)
	e3:SetOperation(c30537973.thop)
	c:RegisterEffect(e3)
	if not c30537973.global_check then
		c30537973.global_check=true
		-- 这张卡召唤·特殊召唤成功的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(30537973)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置该全局效果的操作为 aux.sumreg，当怪兽召唤成功时给它打上‘本回合召唤成功’的标记，用于后续判断‘召唤成功的回合’。
		ge1:SetOperation(aux.sumreg)
		-- 将通常召唤成功的全局监听效果注册进决斗环境，使所有玩家的怪兽通常召唤成功时都触发该标记处理。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(30537973)
		-- 将特殊召唤成功的全局监听效果注册进决斗环境，使所有玩家的怪兽特殊召唤成功时都触发该标记处理。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 作为灵摆卡发动时要支付的代价：检查可发动后，给这张卡附加一个持续到结束阶段的誓约标记（30537973），用于记录本回合这张卡发动过。
function c30537973.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(30537973,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 灵摆效果①的发动条件：检查这张卡是否拥有30537973标记（即本回合是否发动过这张卡），确保只能在该卡发动的回合的主要阶段使用。
function c30537973.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(30537973)~=0
end
-- 对象筛选函数：选择表侧表示且位于魔法与陷阱区域（序号小于5，即魔陷区，不含场地）的卡。
function c30537973.desfilter(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- 灵摆效果①的发动目标处理：先检查是否存在合法对象；然后提示玩家选择要破坏的卡，选择1张（不能是自身）并登记为对象，同时设置破坏的操作信息。
function c30537973.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and chkc~=c and c30537973.desfilter(chkc) end
	-- 效果发动合法性检查：确认场上是否存在1张满足条件的对象卡可供选择。
	if chk==0 then return Duel.IsExistingTarget(c30537973.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,c) end
	-- 向玩家显示‘请选择要破坏的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 由玩家从双方魔法与陷阱区域选择1张符合条件的表侧卡片作为效果对象，该卡会自动登记为当前连锁的联系对象。
	local g=Duel.SelectTarget(tp,c30537973.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,c)
	-- 设置本次连锁的操作信息：声明将破坏对象组中的1张卡，供星尘龙等相关效果正确判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆效果①的处理：取得对象卡，确认双方（这张卡与对象）都与效果仍有联系后，以效果原因将对象卡破坏。
function c30537973.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将取得的对象卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 代价筛选函数：选择手卡中种族为植物族且可以丢弃的怪兽。
function c30537973.costfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsDiscardable()
end
-- 怪兽效果①的代价检查与支付：确认这张卡在本回合召唤/特殊召唤成功（拥有标记30537973），且手卡存在可丢弃的植物族怪兽；支付时丢弃1只植物族怪兽并清除召唤成功标记。
function c30537973.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(30537973)~=0
		-- 代价检查的一部分：确认手卡中是否存在至少1张可丢弃的植物族怪兽。
		and Duel.IsExistingMatchingCard(c30537973.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 作为代价，从手卡选择并丢弃1张符合条件的植物族怪兽。
	Duel.DiscardHand(tp,c30537973.costfilter,1,1,REASON_DISCARD+REASON_COST)
	e:GetHandler():ResetFlagEffect(30537973)
end
-- 检索筛选函数：选择卡组中4星以下、植物族且可以加入手卡的怪兽。
function c30537973.thfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end
-- 怪兽效果①的发动目标处理：确认卡组中存在符合条件的植物族怪兽，并登记‘从卡组将1张卡加入手卡’的操作信息。
function c30537973.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中是否存在至少1张符合条件的植物族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c30537973.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：声明将把1张卡从卡组加入手卡（具体卡片处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果①的解决：从卡组选择1张4星以下植物族怪兽加入手卡，并展示给对方确认。
function c30537973.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示‘请选择要加入手牌的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的植物族怪兽。
	local g=Duel.SelectMatchingCard(tp,c30537973.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
