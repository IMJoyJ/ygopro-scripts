--アポピスの蛇神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡发动后变成通常怪兽（爬虫类族·地·4星·攻1600/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以从卡组把「阿匹卜之蛇神」以外的1张「阿匹卜」陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「阿匹卜之化神」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（发动并特招为怪兽，之后可从卡组盖放「阿匹卜」陷阱卡）和②效果（送去墓地时检索「阿匹卜之化神」）。
function s.initial_effect(c)
	-- 将「阿匹卜之化神」注册到该卡的关联卡片列表中。
	aux.AddCodeList(c,28649820)
	-- ①：这张卡发动后变成通常怪兽（爬虫类族·地·4星·攻1600/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以从卡组把「阿匹卜之蛇神」以外的1张「阿匹卜」陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把1张「阿匹卜之化神」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备与合法性检测，确认怪兽区域有空位且玩家可以特殊召唤该陷阱怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上的怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将该卡作为通常怪兽（爬虫类族·地·4星·攻1600/守1800）特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_NORMAL_TRAP_MONSTER,1600,1800,4,RACE_REPTILE,ATTRIBUTE_EARTH) end
	-- 设置连锁处理的操作信息，表明此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤卡组中「阿匹卜之蛇神」以外的「阿匹卜」陷阱卡，且该卡可以盖放到场上。
function s.setfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c8) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的处理函数，将自身作为怪兽特殊召唤，并可选择从卡组盖放一张「阿匹卜」陷阱卡，且该卡在盖放的回合也能发动。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次检查玩家是否仍能特殊召唤该陷阱怪兽，若不能则直接结束处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_NORMAL_TRAP_MONSTER,1600,1800,4,RACE_REPTILE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 将这张卡以表侧表示特殊召唤，并判断是否特殊召唤成功。
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		-- 获取卡组中满足条件的、可盖放的「阿匹卜」陷阱卡组。
		local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
		-- 若卡组中存在符合条件的卡，则询问玩家是否选择盖放。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把陷阱卡盖放？"
			-- 中断当前效果处理，使后续的盖放卡片处理与特殊召唤不视为同时处理。
			Duel.BreakEffect()
			-- 给玩家发送提示信息，提示选择要盖放的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			local tc=sg:GetFirst()
			-- 将选择的陷阱卡在自己场上盖放，并判断是否盖放成功。
			if Duel.SSet(tp,tc)~=0 then
				-- 这个效果盖放的卡在盖放的回合也能发动。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(id,0))  --"适用「阿匹卜之蛇神」的效果来发动"
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
-- 过滤卡组中的「阿匹卜之化神」且该卡可以加入手卡。
function s.thfilter(c)
	return c:IsCode(28649820) and c:IsAbleToHand()
end
-- ②效果的发动准备与合法性检测，确认卡组中是否存在「阿匹卜之化神」并设置检索的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「阿匹卜之化神」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表明此效果包含从卡组将1张卡加入手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数，从卡组选择1张「阿匹卜之化神」加入手卡并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「阿匹卜之化神」。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片通过效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
