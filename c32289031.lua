--星騎士 セイクリッド・デルタテロス
-- 效果：
-- 4星怪兽×3只以上
-- ①：对方不能把自己场上的5阶以上的「星骑士」、「星圣」超量怪兽作为效果的对象。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只「星骑士」、「星圣」怪兽加入手卡。那之后，可以进行1只光属性怪兽的召唤。
-- ③：这张卡从场上以外送去墓地的场合才能发动。自己的手卡·除外状态的1只「星骑士」、「星圣」怪兽特殊召唤。
local s,id,o=GetID()
-- 卡片初始化函数：设定超量召唤条件（4星怪兽3只以上），并依次注册①的对对方效果对象抗性、②的检索+追加召唤、③的墓地特殊召唤这三个效果。
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：以4星怪兽3只以上（最多99只）叠放进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,3,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：对方不能把自己场上的5阶以上的「星骑士」、「星圣」超量怪兽作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.efftg)
	-- 设置该保护效果的Value函数，配合Target使对方的效果不能选择这些5阶以上「星骑士」「星圣」超量怪兽作为对象。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从卡组把1只「星骑士」、「星圣」怪兽加入手卡。那之后，可以进行1只光属性怪兽的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上以外送去墓地的场合才能发动。自己的手卡·除外状态的1只「星骑士」、「星圣」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果①的适用对象筛选：自己的「星圣」或「星骑士」怪兽且阶级在5阶以上。
function s.efftg(e,c)
	return c:IsSetCard(0x53,0x9c) and c:IsRankAbove(5)
end
-- 效果②的发动代价：检查并从这张卡取除1个超量素材。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索目标筛选：卡组中的「星骑士」或「星圣」怪兽，且可以被加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x53,0x9c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的目标检查和操作登记：确认卡组存在可检索的怪兽，并登记将卡加入手卡的处理信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在至少1只满足检索条件的「星骑士」或「星圣」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次连锁的处理信息：从卡组把1张卡加入手卡，供相关效果连锁判断使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 追加召唤目标的筛选：光属性怪兽，且当前可以不使用召唤权进行通常召唤。
function s.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果②的解决处理：从卡组检索1只「星骑士」或「星圣」怪兽加入手卡，给对方确认后，询问是否进行1只光属性怪兽的通常召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家弹出选择提示：选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足检索条件的「星骑士」或「星圣」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的怪兽加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 检查自己手牌或场上是否存在1只光属性且可以通常召唤的怪兽，以判断是否可进行追加召唤。
		if Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
			-- 让玩家选择是否进行1只光属性怪兽的通常召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行召唤？"
			-- 中断当前效果处理，使后续的通常召唤另起一个时点处理。
			Duel.BreakEffect()
			-- 向玩家弹出选择提示：选择要召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 选择1只光属性且可以通常召唤的怪兽。
			local sg=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
			if sg:GetCount()>0 then
				-- 将选择的怪兽进行通常召唤，并忽略每回合通常召唤次数限制。
				Duel.Summon(tp,sg:GetFirst(),true,nil)
			end
		end
	end
end
-- 效果③的发动条件：这张卡从场上以外的区域被送去墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤对象的筛选：是「星骑士」或「星圣」怪兽，且能够被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x53,0x9c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动条件：自己场上有空余的怪兽区域，且手牌·除外区中存在可特殊召唤的「星骑士」或「星圣」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在空的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌·除外区中是否存在1只满足条件且可特殊召唤的「星骑士」或「星圣」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 登记本次连锁的处理信息：从手牌·除外区特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end
-- 效果③的解决处理：从手牌·除外区选择1只符合条件的「星骑士」或「星圣」怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认场上仍有空的怪兽区域，否则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家弹出选择提示：选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌·除外区选择1只满足条件的「星骑士」或「星圣」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
