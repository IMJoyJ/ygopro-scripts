--究極宝玉獣 レインボー・ドラゴン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：「宝玉兽」怪兽进行战斗的攻击宣言时才能发动。这张卡从手卡特殊召唤。
-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ③：把当作永续魔法卡使用的这张卡除外才能发动。从卡组把1只4星以下的「宝玉兽」怪兽效果无效特殊召唤，从卡组把1只「究极宝玉神」怪兽加入手卡。
function c36795102.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：「宝玉兽」怪兽进行战斗的攻击宣言时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36795102,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,36795102)
	e1:SetCondition(c36795102.spcon1)
	e1:SetTarget(c36795102.sptg1)
	e1:SetOperation(c36795102.spop1)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e2:SetCondition(c36795102.repcon)
	e2:SetOperation(c36795102.repop)
	c:RegisterEffect(e2)
	-- ③：把当作永续魔法卡使用的这张卡除外才能发动。从卡组把1只4星以下的「宝玉兽」怪兽效果无效特殊召唤，从卡组把1只「究极宝玉神」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36795102,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,36795103)
	e3:SetCondition(c36795102.spcon2)
	-- 设定③效果的发动COST：将这张卡（当作永续魔法卡使用）除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c36795102.sptg2)
	e3:SetOperation(c36795102.spop2)
	c:RegisterEffect(e3)
end
-- 定义过滤器：卡片存在、表侧表示且属于「宝玉兽」（0x1034），用于判断参与战斗的怪兽是否为表侧表示的「宝玉兽」怪兽。
function c36795102.cfilter(c)
	return c and c:IsFaceup() and c:IsSetCard(0x1034)
end
-- ①效果的发动条件：攻击宣言时，攻击者或攻击对象中存在表侧表示的「宝玉兽」怪兽。
function c36795102.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击宣言的怪兽或被攻击的怪兽中，至少一方是表侧表示的「宝玉兽」怪兽（即满足①的发动时机）。
	return c36795102.cfilter(Duel.GetAttacker()) or c36795102.cfilter(Duel.GetAttackTarget())
end
-- ①效果的发动时点确认：自己主要怪兽区有空位，且这张卡可以从手卡被特殊召唤（满足召唤条件）。若可发动，则标记特殊召唤这张卡。
function c36795102.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上是否有空余的主要怪兽区，用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次效果将把这张卡特殊召唤（类别为特殊召唤，对象确定，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与发动效果关联（未被无效或离场），将其特殊召唤。
function c36795102.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的适用条件：这张卡在怪兽区域表侧表示并且是被破坏。
function c36795102.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- ②效果处理：给这张卡附加改变种类效果，使其变为永续魔法卡（从而作为永续魔法卡留在场上而不是送去墓地）。
function c36795102.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	c:RegisterEffect(e1)
end
-- ③效果的发动条件：这张卡必须作为永续魔法卡存在于魔法与陷阱区域（即已经通过②效果变成永续魔法卡）。
function c36795102.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_CONTINUOUS+TYPE_SPELL
end
-- 选择特殊召唤对象的条件：等级4以下、属于「宝玉兽」字段、可以被特殊召唤，并且卡组中存在「究极宝玉神」怪兽可以作为检索目标，以保证两个动作同时完成。
function c36795102.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在1张「究极宝玉神」怪兽可加入手牌，确保特殊召唤的同时必定能完成检索。
		and Duel.IsExistingMatchingCard(c36795102.thfilter,tp,LOCATION_DECK,0,1,c)
end
-- 检索「究极宝玉神」怪兽的过滤条件：属于「究极宝玉神」字段（0x2034）、怪兽卡且能够加入手卡。
function c36795102.thfilter(c)
	return c:IsSetCard(0x2034) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ③效果的发动条件和目标检查：主怪兽区有空位，且卡组中存在满足 spfilter 的「宝玉兽」怪兽（其隐含满足可检索「究极宝玉神」的条件）。满足则可发动。
function c36795102.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己主要怪兽区是否有空位，确保能够特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以从卡组特殊召唤的4星以下「宝玉兽」怪兽（且能够同时检索「究极宝玉神」），若有才能发动③。
		and Duel.IsExistingMatchingCard(c36795102.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果包含特殊召唤，从卡组特殊召唤1只怪兽（具体对象处理时选择，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 登记操作信息：本次效果包含检索加入手卡，从卡组将1张卡加入手卡（具体对象处理时选择，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1只4星以下「宝玉兽」怪兽特殊召唤并将其效果无效化，成功后再从卡组选择1只「究极宝玉神」怪兽加入手牌并展示给对方。
function c36795102.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认自己主要怪兽区有空位，若已无空位则整个③效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示选择提示：请选择要特殊召唤的卡（写入缓存，配合后续选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张符合 spfilter 的「宝玉兽」怪兽作为特殊召唤对象。
	local g1=Duel.SelectMatchingCard(tp,c36795102.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g1:GetFirst()
	-- 若成功选定怪兽且其进入特殊召唤步骤，则继续处理：将其效果无效化，并完成后续检索。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		-- ③：从卡组把1只4星以下的「宝玉兽」怪兽效果无效特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- ③：从卡组把1只4星以下的「宝玉兽」怪兽效果无效特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤处理（与 SpecialSummonStep 配对，将暂定的特殊召唤正式确定并完成）。
		Duel.SpecialSummonComplete()
		-- 向操作玩家显示选择提示：请选择要加入手牌的卡（写入缓存，配合后续检索）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足 thfilter 的「究极宝玉神」怪兽，准备加入手牌。
		local g2=Duel.SelectMatchingCard(tp,c36795102.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g2:GetCount()>0 then
			-- 将选中的「究极宝玉神」怪兽加入自己手牌，原因记为效果处理。
			Duel.SendtoHand(g2,tp,REASON_EFFECT)
			-- 将加入手牌的「究极宝玉神」怪兽展示给对方玩家确认（卡组检索必须公开）。
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end
