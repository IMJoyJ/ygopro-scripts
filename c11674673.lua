--サイバース・ウィッチ
-- 效果：
-- 电子界族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡所连接区有怪兽特殊召唤的场合，从自己墓地把1张魔法卡除外才能发动。从卡组把1只电子界族仪式怪兽和1张「电脑网仪式」加入手卡。
-- ②：这张卡的①的效果发动的回合的自己主要阶段，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
function c11674673.initial_effect(c)
	-- 添加连接召唤手续：电子界族怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	-- 记录该卡记载了「电脑网仪式」（34767865）的事实
	aux.AddCodeList(c,34767865)
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
-- 过滤条件：检查特殊召唤的怪兽是否在当前卡连接的区域（包括已离开场上的怪兽的原本位置）
function c11674673.thcfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- 发动条件：这张卡所连接区有怪兽特殊召唤的场合
function c11674673.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11674673.thcfilter,1,nil,e:GetHandler())
end
-- 过滤条件：自己墓地可以除外的魔法卡
function c11674673.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：从自己墓地把1张魔法卡除外
function c11674673.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己墓地是否存在可作为代价除外的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11674673.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择墓地中1张要除外的魔法卡
	local g=Duel.SelectMatchingCard(tp,c11674673.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的魔法卡以发动代价除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中可以加入手牌的电子界族仪式怪兽，且卡组中还存在可检索的「电脑网仪式」
function c11674673.thfilter1(c,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		-- 检查卡组中是否存在另一张可检索的「电脑网仪式」
		and Duel.IsExistingMatchingCard(c11674673.thfilter2,tp,LOCATION_DECK,0,1,c)
end
-- 过滤条件：卡组中可以加入手牌的「电脑网仪式」
function c11674673.thfilter2(c)
	return c:IsCode(34767865) and c:IsAbleToHand()
end
-- 效果靶向：确认卡组存在符合检索条件的卡，并设置操作信息为将卡组的2张卡加入手卡
function c11674673.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在符合检索条件的电子界族仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c11674673.thfilter1,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：从卡组把2张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组把1只电子界族仪式怪兽和1张「电脑网仪式」加入手卡，并为玩家注册本回合已发动①效果的标记
function c11674673.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择卡组中1只符合条件的电子界族仪式怪兽
	local g1=Duel.SelectMatchingCard(tp,c11674673.thfilter1,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g1:GetCount()>0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家选择卡组中1张「电脑网仪式」
		local g2=Duel.SelectMatchingCard(tp,c11674673.thfilter2,tp,LOCATION_DECK,0,1,1,g1:GetFirst())
		g1:Merge(g2)
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g1)
	end
	-- 为玩家注册本回合已发动过①效果的标记，持续到回合结束
	Duel.RegisterFlagEffect(tp,11674673,RESET_PHASE+PHASE_END,0,1)
end
-- 发动条件：这张卡的①的效果发动的回合的自己主要阶段
function c11674673.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家本回合是否已发动过①效果的标记
	return Duel.GetFlagEffect(tp,11674673)>0
end
-- 过滤条件：墓地中4星以下的电子界族怪兽且可以特殊召唤
function c11674673.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果靶向：选择墓地中1只符合条件的怪兽为对象，设置特殊召唤的操作信息
function c11674673.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c11674673.spfilter(chkc,e,tp) end
	-- 判断自己场上是否有空怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在符合特殊召唤条件的怪兽对象
		and Duel.IsExistingTarget(c11674673.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只4星以下的电子界族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c11674673.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤选中的对象怪兽（1只）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选中的墓地怪兽特殊召唤
function c11674673.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
