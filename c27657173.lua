--真紅眼の黒星竜
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡·卡组把1只5星以上的通常怪兽送去墓地才能发动。这张卡从手卡特殊召唤。那之后，这张卡的等级上升1星。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从自己的卡组·墓地把1张「真红眼融合」加入手卡。
function c27657173.initial_effect(c)
	-- ①：从手卡·卡组把1只5星以上的通常怪兽送去墓地才能发动。这张卡从手卡特殊召唤。那之后，这张卡的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,27657173)
	e1:SetCost(c27657173.spcost)
	e1:SetTarget(c27657173.sptg)
	e1:SetOperation(c27657173.spop)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从自己的卡组·墓地把1张「真红眼融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,27657174)
	-- 效果发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 效果发动代价：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27657173.thtg)
	e2:SetOperation(c27657173.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：选择满足条件的通常怪兽（5星以上且能送去墓地）
function c27657173.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelAbove(5) and c:IsAbleToGraveAsCost()
end
-- 效果发动代价处理：选择1只满足条件的怪兽送去墓地
function c27657173.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽可作为发动代价
	if chk==0 then return Duel.IsExistingMatchingCard(c27657173.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c27657173.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 特殊召唤效果的目标确认处理
function c27657173.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以特殊召唤此卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理
function c27657173.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡可以特殊召唤且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 使此卡的等级上升1星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数：选择「真红眼融合」卡
function c27657173.thfilter(c)
	return c:IsCode(6172122) and c:IsAbleToHand()
end
-- 检索效果的目标确认处理
function c27657173.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有「真红眼融合」卡可加入手牌
	if chk==0 then return Duel.IsExistingMatchingCard(c27657173.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置检索的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索效果的处理
function c27657173.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张「真红眼融合」卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27657173.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
