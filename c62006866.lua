--ズバババナイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，可以从以下效果选择1个发动。
-- ●从卡组把「刷拉拉拉骑士」以外的1只「刷拉拉」怪兽加入手卡。这张卡的等级变成和这个效果加入手卡的怪兽相同。
-- ●对方场上1只4星以下的守备表示怪兽破坏。
-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。从卡组把1只「我我我」怪兽加入手卡。
local s,id,o=GetID()
-- 初始化效果：注册召唤·特殊召唤成功时选一发动的诱发效果，以及作为超量素材被取除时的检索诱发效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。从卡组把1只「我我我」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_MOVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「刷拉拉拉骑士」以外的「刷拉拉」怪兽
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x8f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤对方场上表侧表示且等级4以下的守备表示怪兽
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsPosition(POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备：检查并让玩家选择发动「检索并改变等级」或「破坏怪兽」效果，并设置对应的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己卡组是否存在满足条件的「刷拉拉」怪兽
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查对方场上是否存在满足条件的守备表示怪兽
	local b2=Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,e:GetHandler())
	if chk==0 then return b1 or b2 end
	-- 让玩家从可发动的效果中选择一个
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},  --"检索效果"
		{b2,aux.Stringid(id,3),2})  --"破坏怪兽"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置将卡组的1张卡加入手卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 获取对方场上所有满足破坏条件的怪兽
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
		-- 设置破坏1只怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果①的处理：根据玩家的选择，执行「检索并改变等级」或「破坏怪兽」的效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 提示玩家选择要加入手卡的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只满足条件的「刷拉拉」怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,g)
			local lv=g:GetFirst():GetLevel()
			if c:IsRelateToChain() and c:IsFaceup() and not c:IsLevel(lv) then
				-- 这张卡的等级变成和这个效果加入手卡的怪兽相同。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
			end
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家从对方场上选择1只满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 在场上显式示出被选择的卡片
			Duel.HintSelection(g)
			-- 破坏选择的怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 效果②的发动条件：此卡作为超量素材因发动超量怪兽的效果而被取除
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 过滤卡组中的「我我我」怪兽
function s.thfilter2(c)
	return c:IsSetCard(0x54) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组是否存在「我我我」怪兽并设置检索的操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在可检索的「我我我」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组选择1只「我我我」怪兽加入手卡并给对方确认
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的「我我我」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
