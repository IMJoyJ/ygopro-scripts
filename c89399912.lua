--嵐征竜－テンペスト
-- 效果：
-- 这个卡名的①～④的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡把这张卡和1只风属性怪兽丢弃去墓地才能发动。从卡组把1只龙族怪兽加入手卡。
-- ②：把2只龙族或风属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从手卡·墓地特殊召唤。
-- ③：这张卡特殊召唤的场合，对方结束阶段发动。这张卡回到手卡。
-- ④：这张卡被除外的场合才能发动。从卡组把1只龙族·风属性怪兽加入手卡。
function c89399912.initial_effect(c)
	-- ②：把2只龙族或风属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89399912,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,89399912)
	e1:SetCost(c89399912.hspcost)
	e1:SetTarget(c89399912.hsptg)
	e1:SetOperation(c89399912.hspop)
	c:RegisterEffect(e1)
	-- ③：这张卡特殊召唤的场合，对方结束阶段发动。这张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89399912,1))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1,89399912)
	e2:SetCondition(c89399912.retcon)
	e2:SetTarget(c89399912.rettg)
	e2:SetOperation(c89399912.retop)
	c:RegisterEffect(e2)
	-- ①：从手卡把这张卡和1只风属性怪兽丢弃去墓地才能发动。从卡组把1只龙族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89399912,2))  --"从卡组把1只龙族怪兽加入手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,89399912)
	e3:SetCost(c89399912.shcost)
	e3:SetTarget(c89399912.shtg)
	e3:SetOperation(c89399912.shop)
	c:RegisterEffect(e3)
	-- ④：这张卡被除外的场合才能发动。从卡组把1只龙族·风属性怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(89399912,3))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,89399912)
	e4:SetTarget(c89399912.thtg)
	e4:SetOperation(c89399912.thop)
	c:RegisterEffect(e4)
	c89399912.Dragon_Ruler_handes_effect=e3
end
-- 过滤条件：手牌·墓地中可作为发动成本除外的龙族或风属性怪兽
function c89399912.rfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_WIND)) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动成本：从手牌·墓地将自身以外的2只龙族或风属性怪兽除外
function c89399912.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌·墓地是否存在除自身以外共2只可除外的龙族或风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89399912.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择2张满足条件的龙族或风属性怪兽
	local g=Duel.SelectMatchingCard(tp,c89399912.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 将选中的2张卡作为发动成本除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的靶向：检查怪兽区域空格并确认自身是否可以特殊召唤，设置特殊召唤的操作信息
function c89399912.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：将自身特殊召唤
function c89399912.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果的发动条件：对方回合的结束阶段，且这张卡是通过特殊召唤出场的
function c89399912.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
		and e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- ③效果的靶向：设置将自身送回手牌的操作信息
function c89399912.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将自身送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③效果的处理：将表侧表示的自身送回手牌
function c89399912.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡送回持有者的手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 过滤条件：手牌中可作为发动成本丢弃去墓地的风属性怪兽
function c89399912.dfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- ①效果的发动成本：从手牌将自身和1只风属性怪兽丢弃去墓地
function c89399912.shcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() and e:GetHandler():IsAbleToGraveAsCost()
		-- 检查手牌中是否存在除自身以外可丢弃的风属性怪兽
		and Duel.IsExistingMatchingCard(c89399912.dfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家选择1张手牌中的风属性怪兽
	local g=Duel.SelectMatchingCard(tp,c89399912.dfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的风属性怪兽和这张卡一起作为发动成本丢弃去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡组中可加入手牌的龙族怪兽
function c89399912.shfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- ①效果的靶向：检查卡组中是否存在可检索的龙族怪兽，设置检索的操作信息
function c89399912.shtg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查卡组中是否存在可加入手牌的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89399912.shfilter,tp,LOCATION_DECK,0,1,exc) end
	-- 设置从卡组将1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组将1只龙族怪兽加入手牌并给对方确认
function c89399912.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c89399912.shfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：卡组中可加入手牌的龙族·风属性怪兽
function c89399912.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToHand()
end
-- ④效果的靶向：检查卡组中是否存在可检索的龙族·风属性怪兽，设置检索的操作信息
function c89399912.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可加入手牌的龙族·风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89399912.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组将1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ④效果的处理：从卡组将1只龙族·风属性怪兽加入手牌并给对方确认
function c89399912.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只龙族·风属性怪兽
	local g=Duel.SelectMatchingCard(tp,c89399912.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
