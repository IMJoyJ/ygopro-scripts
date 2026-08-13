--ヘルカイトプテラ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方场上有风属性怪兽以外的表侧表示怪兽2只以上存在的场合，那些对方怪兽不能选择这张卡作为攻击对象。
-- ②：自己主要阶段才能发动。从卡组把1张「融合」加入手卡。
-- ③：这张卡被除外的场合才能发动。这张卡特殊召唤。那之后，可以从自己墓地把1张「融合」加入手卡。
function c50834074.initial_effect(c)
	-- ①：对方场上有风属性怪兽以外的表侧表示怪兽2只以上存在的场合，那些对方怪兽不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c50834074.atcon)
	e1:SetValue(c50834074.atlimit)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把1张「融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50834074,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,50834074)
	e2:SetTarget(c50834074.thtg)
	e2:SetOperation(c50834074.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合才能发动。这张卡特殊召唤。那之后，可以从自己墓地把1张「融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50834074,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,50834075)
	e2:SetTarget(c50834074.sptg)
	e2:SetOperation(c50834074.spop)
	c:RegisterEffect(e2)
end
-- 判断卡是否为表侧表示且属性不为风属性，用于筛选对方场上风属性以外的表侧表示怪兽。
function c50834074.filter(c)
	return c:GetAttribute()~=ATTRIBUTE_WIND and c:IsFaceup()
end
-- 获取对方场上满足filter条件的怪兽数量，若不少于2则满足①的发动条件。
function c50834074.atcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取对方场上满足filter条件的怪兽群（即风属性以外的表侧表示怪兽）。
	local g=Duel.GetMatchingGroup(c50834074.filter,tp,0,LOCATION_MZONE,nil)
	return #g>=2
end
-- 判断候选攻击怪兽是否为对方控制、属性不为风且不免疫此效果，若是则不能选择这张卡作为攻击对象。
function c50834074.atlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:GetAttribute()~=ATTRIBUTE_WIND and c:IsControler(1-tp) and not c:IsImmuneToEffect(e)
end
-- 检索条件：卡为「融合」（卡号24094653）且能够加入手卡。
function c50834074.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- ②的发动条件：卡组存在「融合」时，设置将卡组1张卡加入手卡的操作信息。
function c50834074.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张满足thfilter条件的「融合」。
	if chk==0 then return Duel.IsExistingMatchingCard(c50834074.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将从卡组把1张卡加入手卡，供相关连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②的解决处理：从卡组选择1张「融合」加入手卡，并向对方展示该卡。
function c50834074.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选出1张满足条件的「融合」。
	local g=Duel.SelectMatchingCard(tp,c50834074.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	-- 将选中的「融合」送入手卡。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 将加入手卡的「融合」展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
end
-- ③的发动条件：自己主要怪兽区有空位且这张卡能够被特殊召唤。
function c50834074.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理将特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③的解决处理：特殊召唤这张卡，成功后可询问是否从自己墓地选1张「融合」加入手卡。
function c50834074.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡仍与效果关联且特殊召唤成功，成功才继续后续墓地检索效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取自己墓地中满足thfilter且不受王家长眠之谷影响的「融合」。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50834074.thfilter),tp,LOCATION_GRAVE,0,nil)
		if #g==0 then return end
		-- 询问玩家是否从自己墓地把1张「融合」加入手卡。
		if Duel.SelectYesNo(tp,aux.Stringid(50834074,1)) then  --"是否从自己墓地把1张「融合」加入手卡？"
			-- 弹出选择提示，提示玩家选择要加入手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让玩家从自己墓地选择1张满足条件的「融合」。
			local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50834074.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			-- 中断当前效果，使此卡特殊召唤成功的时点独立出来，再进行后续从墓地加入手卡的处理。
			Duel.BreakEffect()
			-- 将玩家从墓地选择的「融合」加入手卡。
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		end
	end
end
