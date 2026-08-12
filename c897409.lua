--銀河百式
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「光子」卡或「银河」卡送去墓地。
-- ②：自己场上有「银河眼光子龙」特殊召唤的场合才能发动。把对方的额外卡组确认。那之后，可以从以下效果让1个适用。
-- ●那之内的1只怪兽除外。
-- ●那之内的1只「No.」怪兽在自己场上特殊召唤。
function c897409.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「光子」卡或「银河」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,897409+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c897409.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「银河眼光子龙」特殊召唤的场合才能发动。把对方的额外卡组确认。那之后，可以从以下效果让1个适用。●那之内的1只怪兽除外。●那之内的1只「No.」怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,897410)
	e2:SetCondition(c897409.cfcon)
	e2:SetTarget(c897409.cftg)
	e2:SetOperation(c897409.cfop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「光子」或「银河」卡片且能送去墓地的过滤函数
function c897409.filter(c)
	return c:IsSetCard(0x55,0x7b) and c:IsAbleToGrave()
end
-- 效果①的发动时效果处理
function c897409.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足过滤条件的「光子」或「银河」卡片
	local g=Duel.GetMatchingGroup(c897409.filter,tp,LOCATION_DECK,0,nil)
	-- 若存在满足条件的卡，则由玩家选择是否发动该效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(897409,0)) then  --"是否从卡组把卡送去墓地？"
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 过滤自己场上表侧表示的「银河眼光子龙」的过滤函数
function c897409.cfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsCode(93717133)
end
-- 效果②的触发条件：检查是否有「银河眼光子龙」在自己场上特殊召唤成功
function c897409.cfcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c897409.cfilter,1,nil,tp)
end
-- 效果②的发动准备：确认对方额外卡组是否有卡
function c897409.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方额外卡组是否至少有1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,1-tp,LOCATION_EXTRA,0,1,nil) end
end
-- 过滤额外卡组中可以特殊召唤的「No.」怪兽的过滤函数
function c897409.spfilter(c,e,tp)
	-- 检查卡片是否为「No.」怪兽、能否特殊召唤，且自己场上有可用于从额外卡组特殊召唤的空位
	return c:IsSetCard(0x48) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②的效果处理：确认对方额外卡组并选择适用其中一个效果
function c897409.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	-- 让己方玩家确认对方的额外卡组
	Duel.ConfirmCards(tp,g)
	local g1=g:Filter(Card.IsAbleToRemove,nil,tp,POS_FACEUP)
	local g2=g:Filter(c897409.spfilter,nil,e,tp)
	local b1=g1:GetCount()>0
	local b2=g2:GetCount()>0
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(897409,1)  --"除外"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(897409,2)  --"特殊召唤"
		opval[off-1]=2
		off=off+1
	end
	ops[off]=aux.Stringid(897409,3)  --"什么都不做"
	opval[off-1]=3
	off=off+1
	-- 提示玩家选择要适用的效果（除外、特殊召唤或什么都不做）
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		-- 中断当前效果，使后续的除外处理与确认额外卡组不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g1:Select(tp,1,1,nil)
		if #sg>0 then
			-- 将选中的怪兽表侧表示除外
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
		-- 洗切对方的额外卡组
		Duel.ShuffleExtra(1-tp)
	elseif opval[op]==2 then
		-- 中断当前效果，使后续的特殊召唤处理与确认额外卡组不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g2:Select(tp,1,1,nil)
		if #sg>0 then
			-- 将选中的「No.」怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 洗切对方的额外卡组
		Duel.ShuffleExtra(1-tp)
	end
end
