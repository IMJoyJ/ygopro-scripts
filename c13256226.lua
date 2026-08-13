--E・HERO スピリット・オブ・ネオス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡守备表示特殊召唤。这个效果特殊召唤的这张卡不会被战斗破坏。
-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1张有「元素英雄」怪兽的卡名记述的魔法·陷阱卡或者「融合」加入手卡。
-- ③：自己主要阶段才能发动。这张卡回到持有者卡组，从卡组把1只「元素英雄」通常怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果：创建并注册①诱发效果、②诱发效果、③起动效果，并分别设置1回合1次的发动次数限制。
function s.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡守备表示特殊召唤。这个效果特殊召唤的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1张有「元素英雄」怪兽的卡名记述的魔法·陷阱卡或者「融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段才能发动。这张卡回到持有者卡组，从卡组把1只「元素英雄」通常怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,id+o*2)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定：判定当前攻击宣言的怪兽为对方怪兽（攻击怪兽的控制者是对方玩家）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击宣言怪兽的控制者是对方玩家（1-tp），以确认满足①的发动条件。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果①的发动目标判定：检查自己场上有空闲怪兽区，且这张卡能够以表侧守备表示从手卡特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域（要求大于0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 登记操作信息：本次效果处理将把这张卡特殊召唤（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理：把这张卡以表侧守备表示特殊召唤，若成功则赋予其不会被战斗破坏的效果，最后完成特殊召唤处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 通过特殊召唤步骤函数尝试把这张卡以表侧守备表示特殊召唤，并返回是否成功。
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的这张卡不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤的所有步骤，结束本次特殊召唤处理。
	Duel.SpecialSummonComplete()
end
-- 定义效果②的检索筛选器：用于判定可以作为检索对象的魔法·陷阱卡或「融合」。
function s.thfilter(c)
	-- 筛选条件：卡片可以加入手卡，并且（是效果文本中记述了「元素英雄」怪兽的魔法·陷阱卡，或者是「融合」）。
	return c:IsAbleToHand() and (c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsSetNameMonsterListed(c,0x3008) or c:IsCode(24094653))
end
-- 效果②的发动目标判定：检查卡组存在至少1张满足thfilter的卡，并登记从卡组检索加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足thfilter条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：从卡组将1张卡加入手卡，对象为卡组的卡（尚不确定具体是哪张）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的发动处理：从卡组选择1张符合条件的卡加入手卡，并向对方确认加入手卡的卡片。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从卡组选择1张满足thfilter条件的卡（检索1张）。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手卡的卡片，用于确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义效果③的特殊召唤筛选器：用于判定可以作为特殊召唤对象的「元素英雄」通常怪兽。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动目标判定：检查此卡可以返回卡组、自己场上有空余怪兽区，且卡组存在符合条件的「元素英雄」通常怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查此卡是否能够返回持有者卡组，并且在自己场上（此卡离开后）有足够的怪兽区域用于特殊召唤。
	if chk==0 then return c:IsAbleToDeck() and Duel.GetMZoneCount(tp,c)>0
		-- 检查卡组中是否存在至少1只满足spfilter2条件的「元素英雄」通常怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：这张卡将返回持有者卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	-- 登记操作信息：将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③的发动处理：先把此卡返回持有者卡组并洗牌；若成功返回且仍在卡组，则从卡组选择1只符合条件的「元素英雄」通常怪兽特殊召唤到场上。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与效果有联系后，将其返回持有者卡组（洗牌），并确认返回成功且卡片位于卡组，才继续后续处理。
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_DECK) then
		-- 再次确认自己场上仍有可用的怪兽区域，若无空位则终止特殊召唤处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 显示选择提示消息，提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让当前玩家从卡组选择1只满足spfilter2条件的「元素英雄」通常怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己的场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
