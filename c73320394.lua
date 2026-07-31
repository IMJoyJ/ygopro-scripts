--邪悪なる魔王－ゾーク
local s,id,o=GetID()
-- 初始化卡片效果：注册手牌舍弃检索8星恶魔族、墓地战场被破坏诱发特召、以及场上掷骰子破坏/夺取控制权效果
function s.initial_effect(c)
	-- ①：把手卡的这张卡和1张手卡丢弃才能发动。从卡组把1只8星·恶魔族怪兽加入手卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：此卡在墓地存在，自己场上的恶魔族怪兽被战斗破坏时才能发动。这张卡特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己主要阶段才能发动。掷1次骰子，根据掷出的点数适用效果（1-4：选对方1只怪兽破坏或移交控制权；5-6：破坏自己场上1张卡）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DICE+CATEGORY_DESTROY+CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.dctg)
	e3:SetOperation(s.dcop)
	c:RegisterEffect(e3)
end
-- Cost过滤条件：可以丢弃的手牌
function s.costfilter(c)
	return c:IsDiscardable()
end
-- ①效果Cost：把手卡的这张卡和另外1张手卡丢弃
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手牌中除自身外是否存在可丢弃的卡且自身可丢弃
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) and c:IsDiscardable() end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌选择自身以外的1张卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的卡和自身丢弃去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 检索过滤条件：8星的恶魔族怪兽且可加入手牌
function s.thfilter(c)
	return c:IsLevel(8) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
-- ①效果发动准备：检查卡组中是否有8星恶魔族怪兽并设置检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的8星恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组把1只8星恶魔族怪兽加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只符合条件的8星恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 战斗破坏过滤条件：原本由己方控制且在场上为表侧表示的恶魔族怪兽
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousRaceOnField()&RACE_FIEND==RACE_FIEND and c:IsPreviousControler(tp)
end
-- ②效果发动条件：己方表侧表示的恶魔族怪兽被战斗破坏且不包含自身
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果发动准备：检查怪兽区域空位与自身特召可行性并设置特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方怪兽区域是否有空位且自身能否特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将墓地的自身表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍关联连锁且不受王家的眠谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果发动准备：设置掷骰子的操作信息
function s.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：掷1次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- ③效果处理：掷1次骰子，根据点数执行对应效果（1-4：选对方1只怪兽破坏或夺取控制权；5-6：破坏己方1张卡）
function s.dcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 掷1次骰子获取点数结果
	local dc=Duel.TossDice(tp,1)
	if dc>=1 and dc<=4 then
		-- 提示玩家选择要操作的对方怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 选择对方怪兽区域的1只怪兽
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if g:GetCount()>0 then
			-- 高亮显示选择的目标怪兽
			Duel.HintSelection(g)
			-- 判断是否无法转移控制权或玩家选择不转移控制权（选择破坏）
			if not tc:IsControlerCanBeChanged() or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				-- 将选中的对方怪兽破坏
				Duel.Destroy(tc,REASON_EFFECT)
			elseif tc:IsControlerCanBeChanged() then
				-- 获得选中的对方怪兽的控制权
				Duel.GetControl(tc,tp)
			end
		end
	elseif dc==5 or dc==6 then
		-- 获取己方场上的所有卡
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
		if g:GetCount()>0 then
			-- 提示玩家选择要破坏的己方卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 高亮显示选择的目标卡片
			Duel.HintSelection(sg)
			-- 将选中的己方卡片破坏
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
