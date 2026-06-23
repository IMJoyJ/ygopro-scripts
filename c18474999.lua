--魔神儀－ブックストーン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把手卡1张仪式魔法卡给对方观看才能发动。「魔神仪-能量石书本」以外的卡组1只「魔神仪」怪兽和手卡的这张卡特殊召唤。
-- ②：这张卡从卡组的特殊召唤成功的场合，以自己墓地1张仪式魔法卡为对象才能发动。那张卡加入手卡。
-- ③：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
function c18474999.initial_effect(c)
	-- ①：把手卡1张仪式魔法卡给对方观看才能发动。「魔神仪-能量石书本」以外的卡组1只「魔神仪」怪兽和手卡的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18474999,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,18474999)
	e1:SetCost(c18474999.spcost)
	e1:SetTarget(c18474999.sptg)
	e1:SetOperation(c18474999.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从卡组的特殊召唤成功的场合，以自己墓地1张仪式魔法卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18474999,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,18474999)
	e2:SetCondition(c18474999.thcon)
	e2:SetTarget(c18474999.thtg)
	e2:SetOperation(c18474999.thop)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c18474999.sumlimit)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「魔神仪」怪兽（不包括自身）并可特殊召唤
function c18474999.filter(c,e,tp)
	return c:IsSetCard(0x117) and not c:IsCode(18474999) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，用于筛选手卡中未公开的仪式魔法卡
function c18474999.costfilter(c)
	return bit.band(c:GetType(),0x82)==0x82 and not c:IsPublic()
end
-- 效果处理：检查手卡是否存在未公开的仪式魔法卡，若存在则选择一张让对方确认并洗切手卡
function c18474999.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在未公开的仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c18474999.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择一张要给对方确认的仪式魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张手卡中的未公开仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,c18474999.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的仪式魔法卡
	Duel.ConfirmCards(1-tp,g)
	-- 将玩家手卡洗切
	Duel.ShuffleHand(tp)
end
-- 效果处理：检查是否满足特殊召唤条件（无青眼精灵龙效果影响、场上空位足够、自身可特殊召唤、卡组存在符合条件的怪兽）
function c18474999.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有至少2个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组是否存在符合条件的「魔神仪」怪兽
		and Duel.IsExistingMatchingCard(c18474999.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将特殊召唤2张卡（1张怪兽+1张自身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：检查是否满足特殊召唤条件（无青眼精灵龙效果影响、场上空位足够、自身可特殊召唤、卡组存在符合条件的怪兽），若满足则选择卡组中的怪兽并特殊召唤
function c18474999.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查玩家场上是否有至少2个空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一张符合条件的「魔神仪」怪兽
	local g=Duel.SelectMatchingCard(tp,c18474999.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		g:AddCard(e:GetHandler())
		-- 将所选怪兽与自身一起特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断此卡是否从卡组特殊召唤成功
function c18474999.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 过滤函数，用于筛选可加入手牌的仪式魔法卡
function c18474999.thfilter(c)
	return bit.band(c:GetType(),0x82)==0x82 and c:IsAbleToHand()
end
-- 效果处理：选择一张自己墓地中的仪式魔法卡作为对象
function c18474999.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c18474999.thfilter(chkc) end
	-- 检查自己墓地是否存在仪式魔法卡
	if chk==0 then return Duel.IsExistingTarget(c18474999.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的仪式魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张自己墓地中的仪式魔法卡
	local g=Duel.SelectTarget(tp,c18474999.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表示将一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将所选仪式魔法卡加入手牌
function c18474999.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断是否为额外卡组的怪兽
function c18474999.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
