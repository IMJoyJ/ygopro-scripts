--陰の光
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不能进行战斗阶段。
-- ①：以自己场上1只暗属性怪兽为对象才能发动。原本的种族·等级和那只怪兽相同的1只光属性怪兽从卡组·额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。这个回合自己在通常召唤外加上只有1次，自己主要阶段可以把1只光·暗属性怪兽召唤。
function c61322713.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不能进行战斗阶段。①：以自己场上1只暗属性怪兽为对象才能发动。原本的种族·等级和那只怪兽相同的1只光属性怪兽从卡组·额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61322713,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,61322713)
	e1:SetCost(c61322713.cost1)
	e1:SetTarget(c61322713.target)
	e1:SetOperation(c61322713.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不能进行战斗阶段。②：把墓地的这张卡除外才能发动。这个回合自己在通常召唤外加上只有1次，自己主要阶段可以把1只光·暗属性怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61322713,1))  --"追加召唤"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,61322714)
	e2:SetCost(c61322713.cost2)
	e2:SetTarget(c61322713.sumtg)
	e2:SetOperation(c61322713.sumop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动代价：检查本回合是否未进入战斗阶段，并注册本回合不能进行战斗阶段的效果。
function c61322713.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前回合玩家是否未进入过战斗阶段。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 这些效果发动的回合，自己不能进行战斗阶段。①：以自己场上1只暗属性怪兽为对象才能发动。原本的种族·等级和那只怪兽相同的1只光属性怪兽从卡组·额外卡组特殊召唤。②：把墓地的这张卡除外才能发动。这个回合自己在通常召唤外加上只有1次，自己主要阶段可以把1只光·暗属性怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册“不能进行战斗阶段”的誓约效果。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤自己场上表侧表示、有原本等级的暗属性怪兽，且卡组或额外卡组存在可特殊召唤的对应光属性怪兽。
function c61322713.filter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
		and c:GetOriginalLevel()>0
		-- 检查卡组或额外卡组是否存在至少1只满足特殊召唤条件（与目标怪兽原本种族、等级相同）的光属性怪兽。
		and Duel.IsExistingMatchingCard(c61322713.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤卡组或额外卡组中，与目标怪兽原本种族和等级相同、且能特殊召唤的光属性怪兽。
function c61322713.spfilter(c,e,tp,tc)
	-- 检查若卡片在卡组，自己场上是否有空余的怪兽区域。
	local b1=c:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 检查若卡片在额外卡组，自己场上是否有空余的能让额外卡组怪兽出场的区域。
	local b2=c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	return c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalLevel()==tc:GetOriginalLevel()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (b1 or b2)
end
-- ①号效果的靶向与发动准备：选择自己场上1只暗属性怪兽作为对象，并声明特殊召唤的操作信息。
function c61322713.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c61322713.filter(chkc,e,tp) end
	-- 检查自己场上是否存在符合条件的暗属性怪兽作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c61322713.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要作为效果对象的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只符合条件的暗属性怪兽作为对象并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c61322713.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理时的操作信息为“从卡组或额外卡组特殊召唤1只怪兽”。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ①号效果的处理：特殊召唤1只与对象怪兽原本种族、等级相同的光属性怪兽。
function c61322713.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组或额外卡组选择1只与对象怪兽原本种族、等级相同的光属性怪兽。
		local g=Duel.SelectMatchingCard(tp,c61322713.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②号效果的发动代价：将墓地的这张卡除外，并适用不能进行战斗阶段的誓约。
function c61322713.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c61322713.cost1(e,tp,eg,ep,ev,re,r,rp,0) and c:IsAbleToRemove() end
	-- 将墓地的这张卡表侧表示除外。
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	c61322713.cost1(e,tp,eg,ep,ev,re,r,rp,1)
end
-- ②号效果的发动准备：检查玩家是否可以通常召唤、是否可以追加召唤，以及本回合是否尚未适用过此追加召唤效果。
function c61322713.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否能够进行通常召唤以及是否能够获得追加召唤的机会。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 检查玩家本回合是否尚未获得过「阴之光」的追加召唤效果。
		and Duel.GetFlagEffect(tp,61322713)==0 end
end
-- ②号效果的处理：为玩家注册本回合在通常召唤外仅限1次，可以在主要阶段召唤1只光·暗属性怪兽的效果。
function c61322713.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 若本回合已获得过此追加召唤效果，则不重复处理。
	if Duel.GetFlagEffect(tp,61322713)~=0 then return end
	-- 这个回合自己在通常召唤外加上只有1次，自己主要阶段可以把1只光·暗属性怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(61322713,2))  --"使用「阴之光」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置追加召唤的适用对象为光属性或暗属性的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT+ATTRIBUTE_DARK))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册追加召唤的效果。
	Duel.RegisterEffect(e1,tp)
	-- 给玩家注册一个持续到回合结束的标记，用于限制该追加召唤效果一回合只能获得一次。
	Duel.RegisterFlagEffect(tp,61322713,RESET_PHASE+PHASE_END,0,1)
end
