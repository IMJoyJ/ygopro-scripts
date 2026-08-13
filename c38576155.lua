--女神スクルドの託宣
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，自己场上的怪兽只有「女武神」怪兽的场合，可以从卡组把1张「女神薇儿丹蒂的引导」加入手卡。
-- ②：1回合1次，自己主要阶段才能发动。从对方卡组上面把3张卡确认，用喜欢的顺序回到卡组上面。这个效果的发动后，直到回合结束时自己不是天使族怪兽不能召唤·特殊召唤。
function c38576155.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，自己场上的怪兽只有「女武神」怪兽的场合，可以从卡组把1张「女神薇儿丹蒂的引导」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38576155+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c38576155.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。从对方卡组上面把3张卡确认，用喜欢的顺序回到卡组上面。这个效果的发动后，直到回合结束时自己不是天使族怪兽不能召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c38576155.target)
	e2:SetOperation(c38576155.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：若卡片为里侧表示或不属于「女武神」（0x122）字段则返回 true，用于检测场上是否存在不符合条件的怪兽。
function c38576155.thcfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x122)
end
-- ①的发动条件：自己主要怪兽区存在怪兽，且场上没有里侧表示或非「女武神」字段的怪兽（即自己场上的怪兽只有「女武神」怪兽）。
function c38576155.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己主要怪兽区存在至少1只怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 判定自己场上不存在不满足条件的怪兽（不存在里侧表示或非「女武神」字段的怪兽）。
		and not Duel.IsExistingMatchingCard(c38576155.thcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：检索对象为卡号64961254（女神薇儿丹蒂的引导）且能够加入手卡的卡片。
function c38576155.thfilter(c)
	return c:IsCode(64961254) and c:IsAbleToHand()
end
-- ①发动时的效果处理：从卡组检索「女神薇儿丹蒂的引导」，满足条件时由玩家选择是否加入手卡，加入手卡后向对方展示。
function c38576155.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中满足thfilter条件的全部卡片，用于检索「女神薇儿丹蒂的引导」。
	local g=Duel.GetMatchingGroup(c38576155.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and c38576155.thcon(e,tp,eg,ep,ev,re,r,rp) and
		-- 弹出发动确认，询问玩家是否将「女神薇儿丹蒂的引导」加入手卡。
		Duel.SelectYesNo(tp,aux.Stringid(38576155,0)) then  --"是否把「女神薇儿丹蒂的引导」加入手卡？"
		-- 显示选择提示，要求玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片以效果原因加入持有者的手卡（此处即自己手卡）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片，确认检索内容。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- ②的发动条件判定：自己主要阶段且对方卡组至少有3张卡时才能发动（chk==0时检查）。
function c38576155.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 对方卡组剩余张数大于2（即至少有3张卡），满足发动条件。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>2 end
end
-- ②效果处理：确认对方卡组上方3张卡并按任意顺序放回，然后给己方附加直到回合结束不能召唤·特殊召唤天使族以外怪兽的自肃效果。
function c38576155.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让己方玩家对对方卡组最上方3张卡进行排序，最先选的在最上面，实现按喜欢的顺序放回对方卡组上面。
	Duel.SortDecktop(tp,1-tp,3)
	-- 这个效果的发动后，直到回合结束时自己不是天使族怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c38576155.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将『不能召唤天使族以外怪兽』的永续效果注册给己方玩家，直到回合结束生效。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 将『不能特殊召唤天使族以外怪兽』的永续效果（由e1克隆而来）注册给己方玩家，直到回合结束生效。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃判定函数：若怪兽不是天使族（RACE_FAIRY）则返回 true，即禁止该怪兽的召唤/特殊召唤。
function c38576155.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_FAIRY)
end
