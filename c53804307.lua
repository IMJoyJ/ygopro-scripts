--焔征竜－ブラスター
-- 效果：
-- 这个卡名的①～④的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡把这张卡和1只炎属性怪兽丢弃去墓地，以场上1张卡为对象才能发动。那张破坏。
-- ②：把2只龙族或炎属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从手卡·墓地特殊召唤。
-- ③：这张卡特殊召唤的场合，对方结束阶段发动。这张卡回到手卡。
-- ④：这张卡被除外的场合才能发动。从卡组把1只龙族·炎属性怪兽加入手卡。
function c53804307.initial_effect(c)
	-- ②：把2只龙族或炎属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53804307,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,53804307)
	e1:SetCost(c53804307.hspcost)
	e1:SetTarget(c53804307.hsptg)
	e1:SetOperation(c53804307.hspop)
	c:RegisterEffect(e1)
	-- ③：这张卡特殊召唤的场合，对方结束阶段发动。这张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53804307,1))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,53804307)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(c53804307.retcon)
	e2:SetTarget(c53804307.rettg)
	e2:SetOperation(c53804307.retop)
	c:RegisterEffect(e2)
	-- ①：从手卡把这张卡和1只炎属性怪兽丢弃去墓地，以场上1张卡为对象才能发动。那张破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53804307,2))  --"选择场上1张卡破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,53804307)
	e3:SetCost(c53804307.descost)
	e3:SetTarget(c53804307.destg)
	e3:SetOperation(c53804307.desop)
	c:RegisterEffect(e3)
	-- ④：这张卡被除外的场合才能发动。从卡组把1只龙族·炎属性怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(53804307,3))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,53804307)
	e4:SetTarget(c53804307.thtg)
	e4:SetOperation(c53804307.thop)
	c:RegisterEffect(e4)
	c53804307.Dragon_Ruler_handes_effect=e3
end
-- 过滤函数：满足龙族或炎属性并且可以除外的卡
function c53804307.rfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_FIRE)) and c:IsAbleToRemoveAsCost()
end
-- 效果处理：检查是否满足除外2只龙族或炎属性怪兽的条件并选择除外
function c53804307.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外2只龙族或炎属性怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c53804307.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张卡进行除外
	local g=Duel.SelectMatchingCard(tp,c53804307.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 将选择的卡以除外形式处理
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：检查是否满足特殊召唤的条件
function c53804307.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：执行特殊召唤操作
function c53804307.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡以特殊召唤形式处理到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果处理：判断是否满足返回手牌的条件
function c53804307.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
		and e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果处理：设置返回手牌的操作信息
function c53804307.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：执行返回手牌操作
function c53804307.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将卡送回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 过滤函数：满足炎属性并且可以丢弃的卡
function c53804307.dfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 效果处理：检查是否满足丢弃手牌的条件
function c53804307.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() and e:GetHandler():IsAbleToGraveAsCost()
		-- 检查是否满足丢弃1张炎属性手牌的条件
		and Duel.IsExistingMatchingCard(c53804307.dfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的1张手牌进行丢弃
	local g=Duel.SelectMatchingCard(tp,c53804307.dfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选择的卡以丢弃形式处理
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果处理：设置破坏操作的目标
function c53804307.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否满足选择场上1张卡作为破坏对象的条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：执行破坏操作
function c53804307.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以破坏形式处理
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数：满足龙族和炎属性并且可以加入手牌的卡
function c53804307.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 效果处理：设置检索操作信息
function c53804307.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索龙族炎属性怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c53804307.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：执行检索操作
function c53804307.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c53804307.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
