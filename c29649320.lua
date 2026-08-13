--ミラーフォース・ランチャー
-- 效果：
-- ①：1回合1次，自己主要阶段从手卡丢弃1只怪兽才能发动。从自己的卡组·墓地选1张「神圣防护罩 -反射镜力-」加入手卡。
-- ②：盖放的这张卡被对方的效果破坏送去墓地的场合才能发动。选墓地的这张卡和自己的手卡·卡组·墓地1张「神圣防护罩 -反射镜力-」，那张卡和这张卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
function c29649320.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段从手卡丢弃1只怪兽才能发动。从自己的卡组·墓地选1张「神圣防护罩 -反射镜力-」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c29649320.thcon)
	e2:SetCost(c29649320.thcost)
	e2:SetTarget(c29649320.thtg)
	e2:SetOperation(c29649320.thop)
	c:RegisterEffect(e2)
	-- ②：盖放的这张卡被对方的效果破坏送去墓地的场合才能发动。选墓地的这张卡和自己的手卡·卡组·墓地1张「神圣防护罩 -反射镜力-」，那张卡和这张卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c29649320.setcon)
	e3:SetTarget(c29649320.settg)
	e3:SetOperation(c29649320.setop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：必须是这张卡的控制者的回合，且当前阶段为主要阶段1或主要阶段2。
function c29649320.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者（即必须是自己回合才能发动）。
	return Duel.GetTurnPlayer()==tp
		-- 判断当前阶段是否为主要阶段1或主要阶段2。
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 筛选代价卡：手卡中满足是怪兽且可以丢弃的卡才能作为①的发动代价。
function c29649320.thcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果①的代价：从手卡丢弃1只怪兽作为发动代价。先检查是否存在可丢弃的怪兽，然后执行丢弃。
function c29649320.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：若在代价确认阶段，检查手卡中是否存在至少1只可丢弃的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c29649320.thcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手卡选择1只怪兽并以代价·丢弃的理由送去墓地。
	Duel.DiscardHand(tp,c29649320.thcfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选检索目标：卡组·墓地中卡名为「神圣防护罩 -反射镜力-」且可以加入手卡的卡。
function c29649320.thfilter(c)
	return c:IsCode(44095762) and c:IsAbleToHand()
end
-- 效果①的目标与操作信息设定：检查卡组·墓地存在符合条件的检索目标，并设置处理时将1张卡加入手卡。
function c29649320.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标合法性检查：在目标确认阶段，确认卡组·墓地存在至少1张符合条件的「神圣防护罩 -反射镜力-」。
	if chk==0 then return Duel.IsExistingMatchingCard(c29649320.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：声明本效果处理后会把1张卡从卡组·墓地加入手卡（用于连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①处理：从自己的卡组·墓地选1张「神圣防护罩 -反射镜力-」加入手卡，并展示给对方确认。
function c29649320.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示框，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 实际选择：从自己的卡组·墓地选择1张满足条件且不受王家长眠之谷影响的「神圣防护罩 -反射镜力-」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29649320.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡（不改变持有者）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：这张卡以里侧表示存在于自己场上，被对方的效果破坏并送去墓地。
function c29649320.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 筛选可盖放的卡：手卡·卡组·墓地中卡名为「神圣防护罩 -反射镜力-」且可以盖放到魔陷区的卡。
function c29649320.setfilter(c)
	return c:IsCode(44095762) and c:IsSSetable()
end
-- 效果②的目标与条件检查：需要己方魔陷区有至少2个空位、自身可以被盖放，且存在至少1张符合条件的「神圣防护罩 -反射镜力-」。
function c29649320.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认阶段检查：己方魔陷区是否有至少2个可用空格（用于同时盖放这张卡和另一张卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 确认阶段检查：自身必须可以被盖放，并且手卡·卡组·墓地存在至少1张符合条件的「神圣防护罩 -反射镜力-」。
		and e:GetHandler():IsSSetable() and Duel.IsExistingMatchingCard(c29649320.setfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 效果②处理：将墓地中的这张卡和选出的1张「神圣防护罩 -反射镜力-」一起盖放到己方魔陷区，并给这两张卡附加在盖放回合也能发动的效果。
function c29649320.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前最终校验：若魔陷区空位少于2个、自身与发动效果失去关联或自身不能被盖放，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<2 or not c:IsRelateToEffect(e) or not c:IsSSetable() then return end
	-- 显示选择提示框，提示玩家选择要盖放的「神圣防护罩 -反射镜力-」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 实际选择：从自己的手卡·卡组·墓地选择1张满足条件且不受王家长眠之谷影响的「神圣防护罩 -反射镜力-」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29649320.setfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local sg=Group.FromCards(c,tc)
		-- 将这张卡和选中的卡一起盖放到自己的魔陷区；若盖放成功则继续后续处理，否则中止。
		if Duel.SSet(tp,sg)==0 then return end
		-- 这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(29649320,0))  --"适用「反射镜力启动」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
	end
end
