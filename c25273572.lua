--Gゴーレム・ペブルドッグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1只「G石人·卵石斗牛犬」加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
-- ②：这张卡从手卡送去墓地的场合才能发动。从卡组把1张「G石人」卡加入手卡。
function c25273572.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1只「G石人·卵石斗牛犬」加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25273572,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,25273572)
	e1:SetTarget(c25273572.sptg)
	e1:SetOperation(c25273572.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡从手卡送去墓地的场合才能发动。从卡组把1张「G石人」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25273572,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,25273573)
	e3:SetCondition(c25273572.thcon)
	e3:SetTarget(c25273572.thtg)
	e3:SetOperation(c25273572.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「G石人·卵石斗牛犬」卡片，可加入手卡或特殊召唤。
function c25273572.filter(c,e,tp,ft)
	return c:IsCode(25273572) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果处理时的判断函数，检查是否满足发动条件。
function c25273572.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 判断是否满足发动条件，即卡组中是否存在符合条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c25273572.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
end
-- 效果处理函数，选择目标卡片并执行特殊召唤或加入手卡操作。
function c25273572.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 提示玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择满足条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c25273572.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	if tc then
		if ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断是否选择特殊召唤或加入手卡，若不能加入手卡则选择特殊召唤。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将目标卡片特殊召唤到场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将目标卡片加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对方查看该卡片。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
	-- 设置一个永续效果，使玩家在本回合不能特殊召唤非电子界族怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c25273572.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该效果给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标为非电子界族怪兽。
function c25273572.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- 判断该卡是否从手卡送去墓地。
function c25273572.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤函数，用于筛选「G石人」卡组中的卡片。
function c25273572.thfilter(c)
	return c:IsSetCard(0x186) and c:IsAbleToHand()
end
-- 设置效果处理时的操作信息。
function c25273572.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即卡组中是否存在符合条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c25273572.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索一张「G石人」卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择目标卡片并将其加入手卡。
function c25273572.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c25273572.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将目标卡片加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看该卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
