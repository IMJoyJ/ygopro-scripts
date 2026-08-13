--Evil★Twin リィラ
-- 效果：
-- 包含「璃拉」怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，若自己场上有「姬丝基勒」怪兽存在，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：自己·对方的主要阶段，自己场上没有「姬丝基勒」怪兽存在的场合才能发动。从自己墓地把1只「姬丝基勒」怪兽特殊召唤。这个回合，自己不是恶魔族怪兽不能从额外卡组特殊召唤。
function c36609518.initial_effect(c)
	-- 为「邪恶★双子 璃拉」添加连接召唤手续：使用2只怪兽作为连接素材，且素材中至少包含1只「璃拉」怪兽（卡名含有「璃拉」）。
	aux.AddLinkProcedure(c,nil,2,2,c36609518.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，若自己场上有「姬丝基勒」怪兽存在，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36609518,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_ACTIVATE_CONDITION)
	e1:SetCountLimit(1,36609518)
	e1:SetCondition(c36609518.descon)
	e1:SetTarget(c36609518.destg)
	e1:SetOperation(c36609518.desop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，自己场上没有「姬丝基勒」怪兽存在的场合才能发动。从自己墓地把1只「姬丝基勒」怪兽特殊召唤。这个回合，自己不是恶魔族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36609518,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,36609519)
	e2:SetCondition(c36609518.spcon)
	e2:SetTarget(c36609518.sptg)
	e2:SetOperation(c36609518.spop)
	c:RegisterEffect(e2)
end
-- 检查连接素材组中是否存在至少1只「璃拉」系列怪兽，以满足“包含「璃拉」怪兽的怪兽2只”的连接召唤条件。
function c36609518.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x153)
end
-- 判断怪兽是否为表侧表示且属于「姬丝基勒」系列（0x152），用于检查场上是否存在「姬丝基勒」怪兽。
function c36609518.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x152)
end
-- ①效果的发动条件：自己场上有1只以上表侧表示的「姬丝基勒」怪兽存在。
function c36609518.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方怪兽区是否存在1张以上表侧表示且属于「姬丝基勒」系列的怪兽。
	return Duel.IsExistingMatchingCard(c36609518.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动时处理：选择场上1张卡作为对象，并设定破坏该卡的操作信息。
function c36609518.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动合法性的检查：场上是否存在至少1张可以作为效果对象的卡（任意卡）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示“请选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设定本次连锁的操作信息：将破坏所选择的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：取得对象卡，若该卡仍与效果关联则将其破坏。
function c36609518.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的第1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果的发动条件：当前处于主要阶段，且自己场上没有表侧表示的「姬丝基勒」怪兽。
function c36609518.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段为主要阶段1或主要阶段2。
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		-- 且自己场上不存在表侧表示的「姬丝基勒」怪兽。
		and not Duel.IsExistingMatchingCard(c36609518.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 墓地中存在属于「姬丝基勒」系列且可以被当前效果特殊召唤的怪兽。
function c36609518.spfilter(c,e,tp)
	return c:IsSetCard(0x152) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动检查：我方怪兽区有空位，且墓地存在至少1只可特殊召唤的「姬丝基勒」怪兽。
function c36609518.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查我方主要怪兽区域是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且墓地存在至少1只满足 spfilter 的「姬丝基勒」怪兽。
		and Duel.IsExistingMatchingCard(c36609518.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设定本次效果处理涉及从墓地特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：从墓地选1只「姬丝基勒」怪兽特殊召唤；之后这个回合，我方不是恶魔族怪兽不能从额外卡组特殊召唤。
function c36609518.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认我方主要怪兽区域仍有空格。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从我方墓地选择1只不受「王家长眠之谷」影响且可特殊召唤的「姬丝基勒」怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c36609518.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到我方场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是恶魔族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c36609518.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃限制效果注册到当前决斗中，使其影响我方。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能特殊召唤不是恶魔族且位于额外卡组的怪兽。
function c36609518.splimit(e,c)
	return not c:IsRace(RACE_FIEND) and c:IsLocation(LOCATION_EXTRA)
end
