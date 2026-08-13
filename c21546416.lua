--アームド・ドラゴン・サンダー LV5
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「武装龙 LV5」使用。
-- ②：从手卡把1只怪兽送去墓地才能发动。场上的这张卡送去墓地，从手卡·卡组把1只7星以下的「武装龙」怪兽特殊召唤。
-- ③：这张卡为让龙族怪兽的效果发动而被送去墓地的场合才能发动。从卡组把1只5星以上的龙族·风属性怪兽加入手卡。
function c21546416.initial_effect(c)
	-- 给这张卡注册一个在场上·墓地时卡名当作「武装龙 LV5」（46384672）的持续效果，实现①效果。
	aux.EnableChangeCode(c,46384672,LOCATION_MZONE+LOCATION_GRAVE)
	-- 对应②效果：从手卡把1只怪兽送去墓地才能发动。场上的这张卡送去墓地，从手卡·卡组把1只7星以下的「武装龙」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21546416,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21546416)
	e2:SetCost(c21546416.spcost)
	e2:SetTarget(c21546416.sptg)
	e2:SetOperation(c21546416.spop)
	c:RegisterEffect(e2)
	-- 对应③效果：这张卡为让龙族怪兽的效果发动而被送去墓地的场合才能发动。从卡组把1只5星以上的龙族·风属性怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21546416,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,21546417)
	e3:SetCondition(c21546416.thcon)
	e3:SetTarget(c21546416.thtg)
	e3:SetOperation(c21546416.thop)
	c:RegisterEffect(e3)
end
c21546416.lvup={46384672}
c21546416.lvdn={57030525}
-- 定义②发动代价的筛选函数：检查手牌怪兽能否作为cost送墓，并确认除该候选cost外，手卡·卡组仍有可特殊召唤的「武装龙」怪兽。
function c21546416.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 进一步确认除本次候选cost怪兽外，手卡·卡组中存在1只可特殊召唤的「武装龙」怪兽，保证效果处理时必有目标可特招。
		and Duel.IsExistingMatchingCard(c21546416.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp,e:GetLabel())
end
-- ②效果的发动代价函数：chk==0时检查能否发动；实际支付时从手牌选1只怪兽送去墓地，同时根据本卡当前卡名是否当作「武装龙 LV5」（46384672）设置label标记。
function c21546416.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:IsCode(46384672) then
			e:SetLabel(1)
		else
			e:SetLabel(0)
		end
		-- ②效果的发动条件检测：确认手牌中存在可以作为cost送去墓地且能确保后续特殊召唤的怪兽卡。
		return Duel.IsExistingMatchingCard(c21546416.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 显示选择提示信息，让玩家从手牌选择要送去墓地的1只怪兽作为cost。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手牌中选择1张满足costfilter的怪兽卡，作为②效果的发动代价。
	local g=Duel.SelectMatchingCard(tp,c21546416.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的cost怪兽以REASON_COST的原因送去墓地，完成代价支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义②特殊召唤对象的筛选函数：卡名属于「武装龙」字段（0x111）、等级7以下且可被特殊召唤；若label=1（本卡卡名当作「武装龙 LV5」），则额外允许无视召唤条件选择「武装龙 LV7」（73879377）。
function c21546416.spfilter(c,e,tp,label)
	return c:IsSetCard(0x111) and c:IsLevelBelow(7)
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or label==1 and c:IsCode(73879377) and c:IsCanBeSpecialSummoned(e,0,tp,true,false))
end
-- ②效果发动时的目标判定函数：确认本卡可被效果送墓、自己场上有空位、手卡·卡组存在可特招的「武装龙」，并设置送墓和特招的操作信息。
function c21546416.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:IsCode(46384672) then
			e:SetLabel(1)
		else
			e:SetLabel(0)
		end
		-- 检查这张卡能否被效果送去墓地，且自己场上在它离开后仍有可用的怪兽区空格，用于后续特殊召唤。
		return c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
			-- 确认手卡·卡组中存在1只符合条件的「武装龙」怪兽可以特殊召唤（不取对象，处理时选择）。
			and Duel.IsExistingMatchingCard(c21546416.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,e:GetLabel())
	end
	-- 设置效果处理信息：这张卡将被送去墓地（CATEGORY_TOGRAVE），供其他卡/效果连锁时判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
	-- 设置效果处理信息：将从手卡·卡组特殊召唤1只「武装龙」怪兽（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理函数：先将这张卡以效果原因送去墓地，成功且仍在墓地时，从手卡·卡组选1只「武装龙」特殊召唤；若是「武装龙 LV7」且满足条件则无视召唤条件特殊召唤。
function c21546416.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时判定：这张卡仍与效果关联，以效果原因送去墓地成功且位于墓地，同时自己场上有空的怪兽区，才继续执行特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0 then
		local label=e:GetLabel()
		-- 显示提示信息，让玩家选择要特殊召唤的「武装龙」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组中选择1张符合spfilter条件的「武装龙」怪兽，准备特殊召唤。
		local g=Duel.SelectMatchingCard(tp,c21546416.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,label)
		local tc=g:GetFirst()
		if tc then
			-- 若记录label=1（本卡名当作「武装龙 LV5」）且选择的卡是「武装龙 LV7」，则以无视召唤条件（nocheck=true）的方式将其特殊召唤，成功后调用CompleteProcedure完成其特殊召唤手续。
			if label==1 and tc:IsCode(73879377) and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 then
				tc:CompleteProcedure()
			else
				-- 通常情况：以不无视召唤条件、不无视苏生限制的方式，将选择的「武装龙」怪兽表侧表示特殊召唤到自己的怪兽区。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 定义③效果的发动条件：这张卡作为cost被送去墓地，且导致这次送墓的连锁是由怪兽效果发动，并且该效果的连锁信息中种族为龙族。
function c21546416.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		-- 确认当前连锁中触发效果发动的怪兽的种族为龙族，满足“为让龙族怪兽的效果发动”这一条件。
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE)&RACE_DRAGON>0
end
-- 定义③效果检索的筛选条件：等级5以上、龙族、风属性，且可以加入手卡。
function c21546416.thfilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToHand()
end
-- ③效果的目标判定函数：确认卡组中存在符合条件的检索目标，并设置操作信息为从卡组将1张卡加入手卡。
function c21546416.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在1只满足检索条件的龙族·风属性怪兽，有才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c21546416.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：将从卡组将1张卡加入手卡（CATEGORY_TOHAND），供其他卡效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理函数：从卡组选择1只5星以上龙族·风属性怪兽加入手卡，并让对方确认。
function c21546416.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示提示，让玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的怪兽卡，准备加入手卡。
	local g=Duel.SelectMatchingCard(tp,c21546416.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入其持有者的手卡（nil表示返回持有者手卡），原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家确认，完成检索效果。
		Duel.ConfirmCards(1-tp,g)
	end
end
