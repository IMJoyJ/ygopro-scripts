--TG マイティ・ストライカー
-- 效果：
-- 调整＋调整以外的怪兽1只
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组把1张「科技属」魔法·陷阱卡加入手卡。
-- ②：对方主要阶段才能发动1次。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
-- ③：这张卡从怪兽区域送去墓地的场合才能发动。从卡组把1张「科技属」卡送去墓地。
local s,id,o=GetID()
-- 定义卡片的初始效果：启用苏生限制，设定同调召唤素材为调整＋调整以外怪兽1只，并依次注册②效果（对方主要阶段同调召唤）、①效果（同调召唤检索）和③效果（送墓堆墓）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加同调召唤手续：调整怪兽1只＋调整以外怪兽1只（即调整＋调整以外的怪兽1只）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	-- ②：对方主要阶段才能发动1次。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.scon)
	e1:SetTarget(s.stg)
	e1:SetOperation(s.sop)
	c:RegisterEffect(e1)
	-- ①：这张卡同调召唤的场合才能发动。从卡组把1张「科技属」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡从怪兽区域送去墓地的场合才能发动。从卡组把1张「科技属」卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 定义②效果的发动条件：当前必须是对方的主要阶段1或主要阶段2（即对方主要阶段）。
function s.scon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段并存入局部变量ph。
	local ph=Duel.GetCurrentPhase()
	-- 判定当前回合玩家是否为对手且当前阶段为主要阶段1或2，满足则②效果可发动。
	return Duel.GetTurnPlayer()==1-tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 定义②效果的发动目标：确认额外卡组存在可用这张卡作为素材进行同调召唤的怪兽，满足则设置特殊召唤的操作信息。
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时检查额外卡组是否存在可用这张卡进行同调召唤的同调怪兽（排除这张卡自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c) end
	-- 设置操作信息：本效果处理时将进行一次特殊召唤，对象来自额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义②效果的处理：确认此卡仍与效果关联且在自己怪兽区域表侧表示，若是则从额外卡组选择一只可以此卡为素材的同调怪兽，以包含此卡的己方场上怪兽为素材进行同调召唤。
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsFacedown() then return end
	-- 向操作玩家发出选择要特殊召唤的卡片的提示（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择一张可同调召唤的怪兽（排除这张卡自身）并取出第一张。
	local tc=Duel.SelectMatchingCard(tp,Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,1,nil,c):GetFirst()
	-- 若选择到了同调怪兽，则以这张卡为素材让玩家进行同调召唤。
	if tc then Duel.SynchroSummon(tp,tc,c) end
end
-- 定义①效果的发动条件：这张卡是以同调召唤方式特殊召唤成功（召唤类型为同调召唤）。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 定义检索过滤条件：卡组中的「科技属」魔法·陷阱卡，且能够加入手卡。
function s.filter(c)
	return c:IsSetCard(0x27) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 定义①效果的发动目标：确认卡组存在1张可加入手卡的「科技属」魔法·陷阱卡，满足则设置加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在1张符合条件的「科技属」魔法·陷阱卡且能够加入手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将把1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义①效果的处理：从卡组选择1张「科技属」魔法·陷阱卡加入手卡，并让对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家发出选择要加入手牌的卡片的提示（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「科技属」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将所选卡片加入手卡（加入持有者手卡，原因为效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义③效果的发动条件：这张卡从怪兽区域（主要怪兽区或额外怪兽区）被送去墓地。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 定义堆墓过滤条件：卡组中的「科技属」卡片，且能够送去墓地。
function s.gfilter(c)
	return c:IsSetCard(0x27) and c:IsAbleToGrave()
end
-- 定义③效果的发动目标：确认卡组存在1张可送去墓地的「科技属」卡，满足则设置送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在1张符合条件的「科技属」卡且能够送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(s.gfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将把1张卡从卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义③效果的处理：从卡组选择1张「科技属」卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家发出选择要送去墓地的卡片的提示（HINTMSG_TOGRAVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张符合条件的「科技属」卡。
	local g=Duel.SelectMatchingCard(tp,s.gfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将所选卡片送去墓地（原因为效果处理）。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
