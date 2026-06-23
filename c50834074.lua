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
-- 过滤函数：返回属性不为风且表侧表示的怪兽
function c50834074.filter(c)
	return c:GetAttribute()~=ATTRIBUTE_WIND and c:IsFaceup()
end
-- 条件函数：判断对方场上有2只以上非风属性的表侧表示怪兽
function c50834074.atcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取对方场上所有非风属性的表侧表示怪兽数量
	local g=Duel.GetMatchingGroup(c50834074.filter,tp,0,LOCATION_MZONE,nil)
	return #g>=2
end
-- 限制函数：使非风属性的对方怪兽不能成为攻击对象
function c50834074.atlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:GetAttribute()~=ATTRIBUTE_WIND and c:IsControler(1-tp) and not c:IsImmuneToEffect(e)
end
-- 过滤函数：返回卡号为24094653（融合）且能加入手牌的卡
function c50834074.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果处理目标函数：检查是否满足检索条件并设置操作信息
function c50834074.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c50834074.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将要从卡组加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：选择并把符合条件的卡加入手牌
function c50834074.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c50834074.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	-- 将选中的卡送入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 确认对方看到被送入手牌的卡
	Duel.ConfirmCards(1-tp,g)
end
-- 特殊召唤效果处理目标函数：检查是否可以特殊召唤并设置操作信息
function c50834074.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果处理函数：特殊召唤自身并可选择从墓地加入手牌
function c50834074.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否可以特殊召唤自身
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取满足条件的墓地中的「融合」卡组
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50834074.thfilter),tp,LOCATION_GRAVE,0,nil)
		if #g==0 then return end
		-- 询问玩家是否要从墓地加入手牌
		if Duel.SelectYesNo(tp,aux.Stringid(50834074,1)) then  --"是否从自己墓地把1张「融合」加入手卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 选择满足条件的墓地中的「融合」卡
			local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50834074.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将选中的卡送入手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		end
	end
end
