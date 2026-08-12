--魔神儀－キャンドール
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡在手卡存在的场合，把手卡1张仪式魔法卡给对方观看才能发动。「魔神仪-蜡烛人偶」以外的卡组1只「魔神仪」怪兽和这张卡特殊召唤。
-- ②：这张卡从卡组特殊召唤的场合才能发动。从卡组把1张仪式魔法卡加入手卡。
-- ③：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
function c53303460.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，把手卡1张仪式魔法卡给对方观看才能发动。「魔神仪-蜡烛人偶」以外的卡组1只「魔神仪」怪兽和这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53303460,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,53303460)
	e1:SetCost(c53303460.spcost)
	e1:SetTarget(c53303460.sptg)
	e1:SetOperation(c53303460.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从卡组特殊召唤的场合才能发动。从卡组把1张仪式魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53303460,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,53303460)
	e2:SetCondition(c53303460.thcon)
	e2:SetTarget(c53303460.thtg)
	e2:SetOperation(c53303460.thop)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c53303460.sumlimit)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「魔神仪」怪兽（不包括蜡烛人偶本身）并可特殊召唤。
function c53303460.filter(c,e,tp)
	return c:IsSetCard(0x117) and not c:IsCode(53303460) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，用于筛选手卡中未公开的仪式魔法卡。
function c53303460.costfilter(c)
	return c:GetType()==0x82 and not c:IsPublic()
end
-- 效果处理：检查手卡是否存在未公开的仪式魔法卡，若有则选择一张让对方确认并洗切手牌。
function c53303460.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否满足发动条件：手卡存在未公开的仪式魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c53303460.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡中选择一张未公开的仪式魔法卡作为效果代价。
	local g=Duel.SelectMatchingCard(tp,c53303460.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的仪式魔法卡。
	Duel.ConfirmCards(1-tp,g)
	-- 将发动者手牌洗切。
	Duel.ShuffleHand(tp)
end
-- 效果处理：检测是否满足特殊召唤条件，包括未受青眼精灵龙影响、场上空位足够、自身可特殊召唤、卡组存在符合条件的怪兽。
function c53303460.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测场上是否有至少两个空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检测卡组是否存在符合条件的「魔神仪」怪兽。
		and Duel.IsExistingMatchingCard(c53303460.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤两只怪兽（一张手牌+一张卡组怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：若满足条件则选择一只卡组中的「魔神仪」怪兽并加入自身，然后一起特殊召唤。
function c53303460.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检测场上是否至少有两个空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一只符合条件的「魔神仪」怪兽。
	local g=Duel.SelectMatchingCard(tp,c53303460.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		g:AddCard(e:GetHandler())
		-- 将所选怪兽与自身一起特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 条件函数：判断此效果是否由从卡组特殊召唤触发。
function c53303460.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 过滤函数，用于筛选可加入手牌的仪式魔法卡。
function c53303460.thfilter(c)
	return c:GetType()==0x82 and c:IsAbleToHand()
end
-- 效果处理：检测是否满足检索条件，若有则设置操作信息准备将一张仪式魔法卡加入手牌。
function c53303460.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组是否存在可加入手牌的仪式魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c53303460.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：准备将一张仪式魔法卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择一张仪式魔法卡加入手牌并确认给对方。
function c53303460.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张仪式魔法卡作为效果对象。
	local g=Duel.SelectMatchingCard(tp,c53303460.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选仪式魔法卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选仪式魔法卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 限制函数：禁止在额外卡组特殊召唤怪兽。
function c53303460.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
