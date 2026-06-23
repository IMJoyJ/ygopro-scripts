--天空聖騎士アークパーシアス
-- 效果：
-- ①：这张卡在手卡·墓地存在，自己把反击陷阱卡发动的场合或者自己把怪兽的效果·魔法·陷阱卡的发动无效的场合，从自己的手卡·场上·墓地把这张卡以外的2只天使族怪兽除外才能发动。这张卡特殊召唤。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：这张卡给与对方战斗伤害时才能发动。从卡组把1张「珀耳修斯」卡或者反击陷阱卡加入手卡。
function c16261341.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己把反击陷阱卡发动的场合或者自己把怪兽的效果·魔法·陷阱卡的发动无效的场合，从自己的手卡·场上·墓地把这张卡以外的2只天使族怪兽除外才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16261341,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c16261341.spcon1)
	e3:SetCost(c16261341.spcost)
	e3:SetTarget(c16261341.sptg)
	e3:SetOperation(c16261341.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_CHAIN_NEGATED)
	e4:SetCondition(c16261341.spcon2)
	c:RegisterEffect(e4)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e5)
	-- ③：这张卡给与对方战斗伤害时才能发动。从卡组把1张「珀耳修斯」卡或者反击陷阱卡加入手卡。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(16261341,1))
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BATTLE_DAMAGE)
	e6:SetCondition(c16261341.thcon)
	e6:SetTarget(c16261341.thtg)
	e6:SetOperation(c16261341.thop)
	c:RegisterEffect(e6)
end
-- 自己把反击陷阱卡发动的场合触发效果
function c16261341.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_COUNTER)
end
-- 自己把怪兽的效果·魔法·陷阱卡的发动无效的场合触发效果
function c16261341.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁无效的玩家
	local dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_PLAYER)
	return dp==tp and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 过滤满足条件的天使族怪兽（场上正面表示或非场上位置且可除外）
function c16261341.cfilter(c)
	return c:IsRace(RACE_FAIRY) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and c:IsAbleToRemoveAsCost()
end
-- 过滤满足条件的场上怪兽（位置在MZONE且序号小于5）
function c16261341.mzfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
-- 处理效果发动时的除外费用，选择2只天使族怪兽除外
function c16261341.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取满足条件的天使族怪兽组
	local rg=Duel.GetMatchingGroup(c16261341.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,c)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	if chk==0 then return ft>-2 and rg:GetCount()>1 and (ft>0 or rg:IsExists(c16261341.mzfilter,ct,nil)) end
	local g=nil
	if ft>0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=rg:Select(tp,2,2,nil)
	elseif ft==0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=rg:FilterSelect(tp,c16261341.mzfilter,1,1,nil)
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local g2=rg:Select(tp,1,1,g:GetFirst())
		g:Merge(g2)
	else
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=rg:FilterSelect(tp,c16261341.mzfilter,2,2,nil)
	end
	-- 将选择的怪兽除外作为发动费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置特殊召唤的处理目标
function c16261341.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c16261341.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 造成战斗伤害时触发效果
function c16261341.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤满足条件的「珀耳修斯」卡或反击陷阱卡
function c16261341.thfilter(c)
	return (c:IsSetCard(0x10a) or c:IsType(TYPE_COUNTER)) and c:IsAbleToHand()
end
-- 设置检索效果的处理目标
function c16261341.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c16261341.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果操作
function c16261341.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c16261341.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方手牌
		Duel.ConfirmCards(1-tp,g)
	end
end
