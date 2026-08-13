--焔征竜－ブラスター
-- 效果：
-- 这个卡名的①～④的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡把这张卡和1只炎属性怪兽丢弃去墓地，以场上1张卡为对象才能发动。那张破坏。
-- ②：把2只龙族或炎属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从手卡·墓地特殊召唤。
-- ③：这张卡特殊召唤的场合，对方结束阶段发动。这张卡回到手卡。
-- ④：这张卡被除外的场合才能发动。从卡组把1只龙族·炎属性怪兽加入手卡。
function c53804307.initial_effect(c)
	-- ②效果：把2只龙族或炎属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从手卡·墓地特殊召唤。
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
	-- ③效果：这张卡特殊召唤的场合，对方结束阶段发动。这张卡回到手卡。
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
	-- ①效果：从手卡把这张卡和1只炎属性怪兽丢弃去墓地，以场上1张卡为对象才能发动。那张破坏。
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
	-- ④效果：这张卡被除外的场合才能发动。从卡组把1只龙族·炎属性怪兽加入手卡。
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
-- 定义②效果代价的过滤器：满足龙族或炎属性之一，且可作为代价除外。
function c53804307.rfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_FIRE)) and c:IsAbleToRemoveAsCost()
end
-- ②效果的代价函数：支付时从手卡·墓地选择2只龙族或炎属性怪兽（除外自己以外的卡）作为代价除外。
function c53804307.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：检查自己的手卡·墓地是否存在至少2只满足rfilter（龙族或炎属性）且不是本卡的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c53804307.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 弹出提示，提示当前玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己的手卡·墓地选择2张满足rfilter且不是本卡的怪兽卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c53804307.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 将选择的2张怪兽卡以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标判定：自己主要怪兽区有空位，且这张卡本身可以被特殊召唤。
function c53804307.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设定本次连锁的操作信息：将特殊召唤这张卡的信息登记为CATEGORY_SPECIAL_SUMMON。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的特殊召唤处理：若这张卡仍与效果关联，则将其从手卡·墓地特殊召唤到场上。
function c53804307.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 把这张卡以表侧表示特殊召唤到自己的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果的发动条件：当前回合玩家是对方，且这张卡是特殊召唤成功过的状态。
function c53804307.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方的回合。
	return Duel.GetTurnPlayer()==1-tp
		and e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- ③效果的目标判定：无条件成立，登记将这张卡返回手卡的操作信息。
function c53804307.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定操作信息：将这张卡返回手卡，分类为CATEGORY_TOHAND。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③效果处理：若这张卡仍与效果关联且表侧表示，则将其返回手卡。
function c53804307.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡从场上送回持有者手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 定义①效果代价的过滤器：炎属性怪兽且可丢弃并送去墓地。
function c53804307.dfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- ①效果的代价判定：本卡自身可丢弃去墓地，且手卡中存在至少1只满足dfilter的炎属性怪兽。
function c53804307.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() and e:GetHandler():IsAbleToGraveAsCost()
		-- 检查手卡中是否存在1张除本卡以外的炎属性怪兽可以作为丢弃代价。
		and Duel.IsExistingMatchingCard(c53804307.dfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 弹出提示，提示当前玩家选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手卡选择1张满足dfilter的炎属性怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c53804307.dfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选择的炎属性怪兽和本卡一起送去墓地，作为丢弃代价。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- ①效果的目标选定：取场上1张卡为对象；效果处理时破坏该卡。
function c53804307.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 目标检测：场上是否存在至少1张可以被选择为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出提示，提示当前玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设定操作信息：将选择的卡登记为破坏对象，分类为CATEGORY_DESTROY。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：取得对象卡，若仍与效果关联则将其破坏。
function c53804307.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 定义④效果检索的过滤器：龙族且炎属性，并且可以被加入手卡。
function c53804307.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- ④效果的目标判定：卡组中存在至少1张满足thfilter的怪兽，并登记检索操作信息。
function c53804307.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张龙族·炎属性怪兽且能被加入手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c53804307.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：从卡组将1张卡加入手卡，分类为CATEGORY_TOHAND与CATEGORY_SEARCH。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ④效果处理：从卡组选择1张龙族·炎属性怪兽加入手卡，并让对方确认。
function c53804307.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出提示，提示当前玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足thfilter的龙族·炎属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c53804307.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
