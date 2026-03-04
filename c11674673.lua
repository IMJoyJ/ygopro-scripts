--サイバース・ウィッチ
-- 效果：
-- 电子界族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡所连接区有怪兽特殊召唤的场合，从自己墓地把1张魔法卡除外才能发动。从卡组把1只电子界族仪式怪兽和1张「电脑网仪式」加入手卡。
-- ②：这张卡的①的效果发动的回合的自己主要阶段，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
function c11674673.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2只电子界族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡所连接区有怪兽特殊召唤的场合，从自己墓地把1张魔法卡除外才能发动。从卡组把1只电子界族仪式怪兽和1张「电脑网仪式」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11674673,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,11674673)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c11674673.thcon)
	e1:SetCost(c11674673.thcost)
	e1:SetTarget(c11674673.thtg)
	e1:SetOperation(c11674673.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果发动的回合的自己主要阶段，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11674673,1))  --"墓地苏生"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,11674674)
	e2:SetCondition(c11674673.spcon)
	e2:SetTarget(c11674673.sptg)
	e2:SetOperation(c11674673.spop)
	c:RegisterEffect(e2)
end
-- 用于判断连接区的怪兽是否与当前处理的卡片有关联
function c11674673.thcfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- 判断是否满足①效果的发动条件，即连接区有怪兽被特殊召唤
function c11674673.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11674673.thcfilter,1,nil,e:GetHandler())
end
-- 用于过滤墓地中的魔法卡作为cost
function c11674673.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 处理①效果的cost，从墓地除外1张魔法卡
function c11674673.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足cost条件，即墓地存在至少1张魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11674673.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择1张满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c11674673.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的魔法卡除外作为cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 用于筛选卡组中的电子界族仪式怪兽
function c11674673.thfilter1(c,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		-- 检查是否存在满足条件的「电脑网仪式」卡
		and Duel.IsExistingMatchingCard(c11674673.thfilter2,tp,LOCATION_DECK,0,1,c)
end
-- 用于筛选卡组中的「电脑网仪式」卡
function c11674673.thfilter2(c)
	return c:IsCode(34767865) and c:IsAbleToHand()
end
-- 设置①效果的目标，检查是否满足检索条件
function c11674673.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即卡组存在1只电子界族仪式怪兽和1张「电脑网仪式」
	if chk==0 then return Duel.IsExistingMatchingCard(c11674673.thfilter1,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置效果处理信息，表示将从卡组检索2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 处理①效果的发动效果，从卡组检索1只电子界族仪式怪兽和1张「电脑网仪式」
function c11674673.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要检索的电子界族仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择1只满足条件的电子界族仪式怪兽
	local g1=Duel.SelectMatchingCard(tp,c11674673.thfilter1,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g1:GetCount()>0 then
		-- 提示玩家选择要检索的「电脑网仪式」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- 选择1张满足条件的「电脑网仪式」
		local g2=Duel.SelectMatchingCard(tp,c11674673.thfilter2,tp,LOCATION_DECK,0,1,1,g1:GetFirst())
		g1:Merge(g2)
		-- 将检索到的2张卡送入手牌
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g1)
	end
	-- 注册标识效果，标记①效果已发动，用于②效果的发动条件
	Duel.RegisterFlagEffect(tp,11674673,RESET_PHASE+PHASE_END,0,1)
end
-- 判断②效果是否可以发动，即是否满足①效果已发动的条件
function c11674673.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已注册①效果发动的标识
	return Duel.GetFlagEffect(tp,11674673)>0
end
-- 用于筛选墓地中的4星以下电子界族怪兽
function c11674673.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置②效果的目标选择函数
function c11674673.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c11674673.spfilter(chkc,e,tp) end
	-- 检查是否满足②效果的发动条件，即场上有空位且墓地存在满足条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足②效果的发动条件，即墓地存在1只4星以下电子界族怪兽
		and Duel.IsExistingTarget(c11674673.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择1只满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c11674673.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理②效果的发动效果，将墓地中的怪兽特殊召唤
function c11674673.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
