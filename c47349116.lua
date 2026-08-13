--星刻の魔術師
-- 效果：
-- 4星「魔术师」灵摆怪兽×2
-- 这张卡用以上记的卡为超量素材的超量召唤才能从额外卡组特殊召唤。
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从自己的卡组·额外卡组（表侧）·墓地把1只魔法师族·暗属性怪兽加入手卡。
-- ②：1回合1次，自己的怪兽区域·灵摆区域的灵摆怪兽卡被战斗·效果破坏的场合，可以作为代替从自己卡组把1只魔法师族怪兽送去墓地。
function c47349116.initial_effect(c)
	c:EnableReviveLimit()
	-- 为『星刻之魔术师』添加超量召唤手续：可用2只4星且卡名含有『魔术师』的灵摆怪兽作为超量素材叠放进行超量召唤。
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
-- 超量素材过滤条件：该怪兽必须是含有『魔术师』字段的灵摆怪兽（等级由超量手续固定为4星）。
function c47349116.matfilter(c)
	return c:IsSetCard(0x98) and c:IsXyzType(TYPE_PENDULUM)
end
-- 特殊召唤限制：若这张卡从额外卡组以外的地方特殊召唤则不受限制；若从额外卡组特殊召唤，则必须是以超量召唤方式进行、且不能是通过其他效果进行的超量召唤。
function c47349116.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or (bit.band(st,SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ and not se)
end
-- ①效果的发动代价：先检查能否取除这张卡的1个超量素材，实际发动时取除1个超量素材作为COST。
function c47349116.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的检索对象条件：必须为魔法师族·暗属性怪兽；若位于额外卡组则必须表侧表示，且能够被加入手卡。
function c47349116.thfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)
		and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA)) and c:IsAbleToHand()
end
-- ①效果的发动时点判定：自己卡组·墓地·额外卡组（表侧）存在至少1只符合条件的魔法师族·暗属性怪兽；并设定效果处理时从对应区域检索1张加入手卡的操作信息。
function c47349116.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：是否存在至少1只满足thfilter的检索对象。
	if chk==0 then return Duel.IsExistingMatchingCard(c47349116.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：本次效果处理时将1张符合条件的手卡候选加入手卡（用于其他卡的连锁检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
-- ①效果处理时：提示玩家选择要加入手卡的卡片，从卡组·墓地·额外卡组（表侧）中选出1只符合条件的魔法师族·暗属性怪兽，加入持有者手卡，并向对方确认。
function c47349116.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作玩家显示选择提示文字：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组·墓地·额外卡组中选择1张满足thfilter条件的卡（额外卡组仅限表侧，且不受王家长眠之谷影响的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c47349116.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的卡片加入其持有者的手卡，处理原因记为效果。
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	-- 向对方玩家展示所选的卡片，确认加入手卡的卡片。
	Duel.ConfirmCards(1-tp,tc)
end
-- 判断被破坏的卡是否可被代替破坏：须是表侧表示、控制者为发动玩家、位于怪兽区或灵摆区、是灵摆怪兽，且破坏原因由战斗或效果造成而非“代替破坏”本身。
function c47349116.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE+LOCATION_PZONE)
		and c:IsType(TYPE_PENDULUM) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替送墓的素材条件：卡组中存在魔法师族怪兽且该怪兽可以送去墓地。
function c47349116.tgfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToGrave()
end
-- ②效果的触发条件判定：当前被破坏的怪兽中存在符合repfilter的卡，并且自己卡组中有可以送去墓地的魔法师族怪兽。
function c47349116.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c47349116.repfilter,1,nil,tp)
		-- 并且卡组中至少有1张满足tgfilter的魔法师族怪兽可供送去墓地。
		and Duel.IsExistingMatchingCard(c47349116.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 询问玩家是否发动②效果的代替破坏；选择“是”才继续执行送墓代替。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 给操作玩家显示选择提示文字：请选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1张满足tgfilter的魔法师族怪兽作为代替破坏的代价。
		local sg=Duel.SelectMatchingCard(tp,c47349116.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 展示星刻之魔术师的发动动画，向双方提示正在处理该代替破坏效果。
		Duel.Hint(HINT_CARD,0,47349116)
		-- 将选中的魔法师族怪兽送去墓地，原因记为效果，完成代替破坏的处理。
		Duel.SendtoGrave(sg,REASON_EFFECT)
		return true
	else return false end
end
-- 作为EFFECT_DESTROY_REPLACE的Value判定：判断某张要被破坏的卡是否满足②效果的代替条件，返回真则用送墓代替。
function c47349116.repval(e,c)
	return c47349116.repfilter(c,e:GetHandlerPlayer())
end
