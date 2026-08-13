--マシンナーズ・アンクラスペア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「机甲未分类备用兵」以外的1只「机甲」怪兽送去墓地。
function c45674286.initial_effect(c)
	-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45674286,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,45674286)
	e1:SetCondition(c45674286.spcon)
	e1:SetTarget(c45674286.sptg)
	e1:SetOperation(c45674286.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「机甲未分类备用兵」以外的1只「机甲」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45674286,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,45674287)
	e2:SetTarget(c45674286.tgtg)
	e2:SetOperation(c45674286.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 检查这张卡加入手卡的原因不是抽卡，即满足用抽卡以外的方法加入手卡的发动条件。
function c45674286.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- 特殊召唤效果的目标合法性检查：自己场上有可用的怪兽区域空格，且这张卡可以特殊召唤时才允许发动。
function c45674286.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否存在空余的主要怪兽区域，以判断是否能够特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次操作信息为特殊召唤这张卡，数量为1，供连锁判定和相关卡片检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，则将其特殊召唤；随后给当前玩家附加直到结束阶段不能特殊召唤机械族以外怪兽的自肃效果。
function c45674286.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的主要怪兽区域（不检查召唤条件和苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「机甲未分类备用兵」以外的1只「机甲」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c45674286.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤机械族以外怪兽的自肃效果注册到当前玩家，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定函数：如果不是机械族怪兽则不允许特殊召唤，即非机械族怪兽不能特殊召唤。
function c45674286.splimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- ②效果的过滤条件：卡名属于「机甲」系列、是怪兽卡、不是这张卡自身、且可以送去墓地的卡。
function c45674286.tgfilter(c)
	return c:IsSetCard(0x36) and c:IsType(TYPE_MONSTER) and not c:IsCode(45674286) and c:IsAbleToGrave()
end
-- ②效果的发动条件与操作信息登记：确认卡组中存在至少1张符合条件的「机甲」怪兽，并登记从卡组将1张卡送去墓地的操作信息。
function c45674286.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 当chk==0时，检查卡组中是否存在至少1张满足条件的「机甲」怪兽，作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c45674286.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次操作信息为把卡组中的1张卡送去墓地（目标在处理时选择，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：提示玩家选择，从卡组中选择1张符合条件的「机甲」怪兽（不是本卡）并送去墓地。
function c45674286.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要送去墓地的卡”的提示，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选择1张满足条件的「机甲」怪兽。
	local g=Duel.SelectMatchingCard(tp,c45674286.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
