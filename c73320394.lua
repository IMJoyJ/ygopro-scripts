--邪悪なる魔王－ゾーク
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌丢弃自身与手牌另1张卡检索8星恶魔族怪兽、②场上表侧恶魔族被战破从墓地特召自身、③场上掷骰子控制/破坏怪兽或破坏自己卡片效果
function s.initial_effect(c)
	-- ①：把手卡的这张卡和1张手卡丢弃才能发动。从卡组把1只8星·恶魔族怪兽加入手卡。
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
	-- ②：此卡在墓地存在，自己场上的表侧表示恶魔族怪兽被战斗破坏的场合才能发动。此卡特殊召唤。
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
	-- ③：1回合1次，自己主要阶段才能发动。掷1次骰子。根据掷出的数目适用以下效果。●1~4：选对方场上1只怪兽得到控制权或破坏。●5·6：选自己场上1张卡破坏。
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
-- Cost过滤条件：可丢弃的手牌
function s.costfilter(c)
	return c:IsDiscardable()
end
-- ①效果发动Cost：从手牌丢弃此卡和1张其他卡送去墓地
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- Cost检查：手牌中除自身外是否存在可丢弃的卡且自身可丢弃
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) and c:IsDiscardable() end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌选择1张除自身外的卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的卡与自身一同从手牌丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 检索卡片过滤条件：8星的恶魔族怪兽且可加入手牌
function s.thfilter(c)
	return c:IsLevel(8) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
-- ①效果发动准备：设置从卡组检索8星恶魔族怪兽的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组是否存在满足条件的8星恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组把1只8星恶魔族怪兽加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的8星恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 战斗破坏过滤条件：原本控制者为自己且原本种族为恶魔族的表侧表示怪兽
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousRaceOnField()&RACE_FIEND==RACE_FIEND and c:IsPreviousControler(tp)
end
-- ②效果发动条件：自己场上表侧表示恶魔族怪兽被战斗破坏送去墓地（不含自身）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果发动准备：设置特殊召唤墓地自身的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域有空位且自身可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：把墓地的此卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否关联连锁且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果发动准备：设置掷骰子的操作信息
function s.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：进行1次掷骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- ③效果处理：掷1次骰子并根据掷出的点数执行对应效果
function s.dcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 玩家掷1次骰子
	local dc=Duel.TossDice(tp,1)
	if dc>=1 and dc<=4 then
		-- 提示玩家选择要操作的对方怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从对方场上选择1只怪兽
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if g:GetCount()>0 then
			-- 高亮显示选择的目标怪兽
			Duel.HintSelection(g)
			-- 判断目标怪兽控制权能否变更及玩家是否选择得到控制权
			if not tc:IsControlerCanBeChanged() or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				-- 将选中的对方怪兽破坏
				Duel.Destroy(tc,REASON_EFFECT)
			elseif tc:IsControlerCanBeChanged() then
				-- 获得选中的对方怪兽的控制权
				Duel.GetControl(tc,tp)
			end
		end
	elseif dc==5 or dc==6 then
		-- 获取自己场上的所有卡片
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
		if g:GetCount()>0 then
			-- 提示玩家选择要破坏的自己卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 高亮显示选择的破坏目标
			Duel.HintSelection(sg)
			-- 将选中的自己卡片破坏
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
