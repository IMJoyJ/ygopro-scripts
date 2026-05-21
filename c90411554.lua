--巌征竜－レドックス
-- 效果：
-- 这个卡名的①～④的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡把这张卡和1只地属性怪兽丢弃去墓地，以自己墓地1只怪兽为对象才能发动。那只特殊召唤。
-- ②：把2只龙族或地属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从手卡·墓地特殊召唤。
-- ③：这张卡特殊召唤的场合，对方结束阶段发动。这张卡回到手卡。
-- ④：这张卡被除外的场合才能发动。从卡组把1只龙族·地属性怪兽加入手卡。
function c90411554.initial_effect(c)
	-- ②：把2只龙族或地属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90411554,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,90411554)
	e1:SetCost(c90411554.hspcost)
	e1:SetTarget(c90411554.hsptg)
	e1:SetOperation(c90411554.hspop)
	c:RegisterEffect(e1)
	-- ③：这张卡特殊召唤的场合，对方结束阶段发动。这张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90411554,1))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1,90411554)
	e2:SetCondition(c90411554.retcon)
	e2:SetTarget(c90411554.rettg)
	e2:SetOperation(c90411554.retop)
	c:RegisterEffect(e2)
	-- ①：从手卡把这张卡和1只地属性怪兽丢弃去墓地，以自己墓地1只怪兽为对象才能发动。那只特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90411554,2))  --"选择自己墓地1只怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,90411554)
	e3:SetCost(c90411554.spcost)
	e3:SetTarget(c90411554.sptg)
	e3:SetOperation(c90411554.spop)
	c:RegisterEffect(e3)
	-- ④：这张卡被除外的场合才能发动。从卡组把1只龙族·地属性怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(90411554,3))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,90411554)
	e4:SetTarget(c90411554.thtg)
	e4:SetOperation(c90411554.thop)
	c:RegisterEffect(e4)
	c90411554.Dragon_Ruler_handes_effect=e3
end
-- 过滤条件：手卡·墓地中可作为cost除外的龙族或地属性怪兽
function c90411554.rfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_EARTH)) and c:IsAbleToRemoveAsCost()
end
-- 效果②的连锁发动准备：检查并从手卡或墓地将2只龙族或地属性怪兽除外作为发动成本
function c90411554.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0），检查手卡或墓地是否存在至少2只除自身以外、可作为cost除外的龙族或地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90411554.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡或墓地选择2张除自身以外、满足过滤条件的龙族或地属性怪兽
	local g=Duel.SelectMatchingCard(tp,c90411554.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 将选择的怪兽表侧表示除外作为发动成本
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备与合法性检查：检查怪兽区域是否有空位，以及自身是否可以特殊召唤
function c90411554.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0），检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：若自身仍存在于原本位置，则将自身特殊召唤
function c90411554.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果③的发动条件：当前回合是对方回合，且这张卡是通过特殊召唤出场的
function c90411554.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()==1-tp
		and e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果③的发动准备：设置连锁处理信息，此效果包含将自身送回手牌的操作
function c90411554.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息：此效果包含将自身送回手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理：若这张卡在场上表侧表示存在，则将其送回持有者手牌
function c90411554.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡送回持有者的手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 过滤条件：手卡中可作为cost丢弃去墓地的地属性怪兽
function c90411554.dfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 效果①的连锁发动准备：检查并从手卡将自身和1只地属性怪兽丢弃去墓地作为发动成本
function c90411554.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() and e:GetHandler():IsAbleToGraveAsCost()
		-- 并检查手卡中是否存在除自身以外、可作为cost丢弃的地属性怪兽
		and Duel.IsExistingMatchingCard(c90411554.dfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手卡选择1张除自身以外、满足过滤条件的地属性怪兽
	local g=Duel.SelectMatchingCard(tp,c90411554.dfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选择的怪兽作为发动成本丢弃去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：可以进行特殊召唤的怪兽
function c90411554.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检查：检查怪兽区域是否有空位，并选择自己墓地1只怪兽作为效果对象
function c90411554.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c90411554.spfilter(chkc,e,tp) end
	-- 在发动阶段（chk==0），检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己墓地是否存在至少1只可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c90411554.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只满足特殊召唤条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c90411554.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetFirst()==e:GetHandler() then
		e:GetHandler():ReleaseEffectRelation(e)
	end
	-- 设置连锁处理信息：此效果包含将选择的对象怪兽特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将选择的墓地怪兽特殊召唤（需进行王家之谷等墓地干涉判定）
function c90411554.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 检查对象怪兽是否受到「王家长眠之谷」的影响，若受影响则不处理效果
	if not aux.NecroValleyFilter()(tc) then return end
	if tc:IsRelateToChain() or (tc==c and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_HAND) and c:GetReasonEffect()==e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中可加入手牌的龙族·地属性怪兽
function c90411554.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 效果④的发动准备与合法性检查：检查卡组中是否存在可检索的龙族·地属性怪兽，并设置连锁处理信息
function c90411554.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0），检查自己卡组中是否存在至少1只满足过滤条件的龙族·地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90411554.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：此效果包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果④的效果处理：从卡组选择1只龙族·地属性怪兽加入手牌，并向对方展示
function c90411554.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的龙族·地属性怪兽
	local g=Duel.SelectMatchingCard(tp,c90411554.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
