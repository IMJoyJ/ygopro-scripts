--深淵の獣マグナムート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己或对方的墓地1只光·暗属性怪兽为对象才能发动（对方场上有怪兽存在的场合，这个效果在对方回合也能发动）。那只怪兽除外，这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。这个回合的结束阶段，从自己的卡组·墓地把「深渊之兽 玛格巨龙」以外的1只龙族怪兽加入手卡。
local s,id,o=GetID()
-- 创建并注册3个效果：e1为①的起动效果（手牌发动、取对象、除外墓地光暗怪兽并特殊召唤自身）；e2为对方场上有怪兽时①可在对方回合发动的诱发即时效果版；e3为②特殊召唤成功时发动的检索效果。三者分别以id和id+o设置同名卡1回合1次限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己或对方的墓地1只光·暗属性怪兽为对象才能发动（对方场上有怪兽存在的场合，这个效果在对方回合也能发动）。那只怪兽除外，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.spcon2)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤的场合才能发动。这个回合的结束阶段，从自己的卡组·墓地把「深渊之兽 玛格巨龙」以外的1只龙族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- ①效果作为起动效果的发动条件：对方场上没有怪兽时，回合玩家才能在手牌发动此效果（对应通常的1速发动时机）。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以tp方为视角的对方场上怪兽数量是否为0。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
end
-- ①效果作为诱发即时效果的发动条件：对方场上有怪兽存在时，可以在对方回合从手牌发动（满足原文括号内的条件）。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以tp方为视角的对方场上怪兽数量是否大于0。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤器：选择墓地中属性为光或暗且当前可以被除外的怪兽。
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemove()
end
-- ①效果的目标函数：确认取对象目标时必须位于墓地且符合光暗属性；判定发动条件（存在合法对象、自己主怪兽区有空位、自身可被特殊召唤）；合法后提示玩家选择1张墓地光暗怪兽作为对象，并设置除外和特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.cfilter(chkc) end
	local c=e:GetHandler()
	-- 发动时（chk==0）检查是否存在至少1张符合条件的墓地光暗怪兽可以作为取对象目标。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
		-- 同时检查自己主要怪兽区有空位，且这张卡自身满足特殊召唤条件（可被特殊召唤）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向操作玩家显示选择提示，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从双方墓地选择1只光·暗属性怪兽作为效果对象，并自动登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：本次连锁包含除外所选择的1张卡（对象确定），用于连锁反应检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息：本次连锁包含将这张手牌怪兽特殊召唤（处理对象确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：取得选中的墓地怪兽，若该怪兽仍与此效果关联且被效果成功除外，且这张卡也仍关联，则将这张卡从手卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的墓地对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联且成功将其表侧除外，同时确认这张卡本身仍与效果关联，才继续处理特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到其持有者（tp）的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果发动时暂不检索，而是给tp注册一个持续到结束阶段的延迟效果，在结束阶段时执行真正的检索动作（进入thop）。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- ②：这张卡特殊召唤的场合才能发动。这个回合的结束阶段，从自己的卡组·墓地把「深渊之兽 玛格巨龙」以外的1只龙族怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将已创建的持续效果e1注册给tp，使它在当回合结束阶段时触发一次，执行将龙族加入手卡的处理。
	Duel.RegisterEffect(e1,tp)
end
-- 检索用的过滤器：要求怪兽为龙族、可以加入手卡，且卡名不是这张卡（「深渊之兽 玛格巨龙」）自身。
function s.filter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 结束阶段检索处理：显示本卡卡名，提示选择要加入手卡的卡，从卡组·墓地中选出1只符合条件的龙族怪兽加入手卡，并让对手确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示这张卡的卡图动画，提示该检索效果来自「深渊之兽 玛格巨龙」。
	Duel.Hint(HINT_CARD,0,id)
	-- 显示选择提示，要求玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地中，以过滤条件（并通过王家长眠之谷过滤）选择1只龙族怪兽；这里使用aux.NecroValleyFilter使墓地选择不受王家长眠之谷干扰。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的那张龙族怪兽加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的那张卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
