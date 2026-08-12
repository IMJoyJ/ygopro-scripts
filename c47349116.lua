--星刻の魔術師
-- 效果：
-- 4星「魔术师」灵摆怪兽×2
-- 这张卡用以上记的卡为超量素材的超量召唤才能从额外卡组特殊召唤。
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从自己的卡组·额外卡组（表侧）·墓地把1只魔法师族·暗属性怪兽加入手卡。
-- ②：1回合1次，自己的怪兽区域·灵摆区域的灵摆怪兽卡被战斗·效果破坏的场合，可以作为代替从自己卡组把1只魔法师族怪兽送去墓地。
function c47349116.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续，使用满足条件的4星灵摆怪兽作为超量素材进行超量召唤
	aux.AddXyzProcedure(c,c47349116.matfilter,4,2)
	-- 这张卡用以上记的卡为超量素材的超量召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c47349116.splimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从自己的卡组·额外卡组（表侧）·墓地把1只魔法师族·暗属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47349116,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c47349116.thcost)
	e2:SetTarget(c47349116.thtg)
	e2:SetOperation(c47349116.thop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己的怪兽区域·灵摆区域的灵摆怪兽卡被战斗·效果破坏的场合，可以作为代替从自己卡组把1只魔法师族怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c47349116.reptg)
	e3:SetValue(c47349116.repval)
	c:RegisterEffect(e3)
end
-- 过滤条件函数，用于筛选满足条件的超量素材：必须是魔术师卡组且为灵摆怪兽
function c47349116.matfilter(c)
	return c:IsSetCard(0x98) and c:IsXyzType(TYPE_PENDULUM)
end
-- 特殊召唤限制函数，确保该卡只能通过指定方式从额外卡组特殊召唤
function c47349116.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (bit.band(st,SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ and not se)
end
-- 效果发动时的费用支付处理，移除自身1个超量素材作为代价
function c47349116.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索过滤条件函数，用于筛选魔法师族且暗属性的怪兽（包括表侧表示或非额外卡组中的怪兽）
function c47349116.thfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)
		and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA)) and c:IsAbleToHand()
end
-- 设置效果发动时的操作信息，确定将要处理的卡的数量和位置
function c47349116.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即在卡组、墓地和额外卡组中存在至少1张符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c47349116.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息，指定效果处理时将要从卡组·墓地·额外卡组中检索1张魔法师族暗属性怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 效果发动时的操作处理函数，选择并把符合条件的怪兽加入手牌
function c47349116.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组、墓地和额外卡组中选择满足条件的1张怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c47349116.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的怪兽以效果原因送入手牌
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	-- 向对方确认该怪兽已加入手牌
	Duel.ConfirmCards(1-tp,tc)
end
-- 代替破坏的过滤条件函数，用于判断是否为己方灵摆区域或主要怪兽区的灵摆怪兽被战斗或效果破坏
function c47349116.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE+LOCATION_PZONE)
		and c:IsType(TYPE_PENDULUM) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏时选择送去墓地的怪兽的过滤条件，必须是魔法师族且能被送去墓地
function c47349116.tgfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToGrave()
end
-- 代替破坏效果的目标判定函数，检查是否有满足条件的灵摆怪兽被破坏，并确认卡组中存在可选的魔法师族怪兽
function c47349116.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c47349116.repfilter,1,nil,tp)
		-- 检查卡组中是否存在至少1张符合条件的魔法师族怪兽用于代替破坏
		and Duel.IsExistingMatchingCard(c47349116.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组中选择1张满足条件的魔法师族怪兽送去墓地
		local sg=Duel.SelectMatchingCard(tp,c47349116.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 显示该卡发动动画，用于提示玩家该卡被使用
		Duel.Hint(HINT_CARD,0,47349116)
		-- 将选中的怪兽以效果原因送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
		return true
	else return false end
end
-- 代替破坏效果的值函数，返回是否满足代替破坏条件
function c47349116.repval(e,c)
	return c47349116.repfilter(c,e:GetHandlerPlayer())
end
