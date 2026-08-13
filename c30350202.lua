--凶征竜－エクレプシス
-- 效果：
-- 龙族7星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合，以自己的墓地·除外状态的1只4星以下的「征龙」怪兽为对象才能发动。把1只在那只怪兽有卡名记述的7星或7阶的「征龙」怪兽从自己的卡组·除外状态特殊召唤。那之后，作为对象的怪兽回到卡组。
-- ②：对方把魔法·陷阱卡的效果发动时，把这张卡2个超量素材取除才能发动。那个发动无效并除外。
local s,id,o=GetID()
-- 定义初始效果注册函数：为凶征龙-食龙添加超量召唤手续（龙族7星怪兽×2）与召唤限制，并注册①效果和②效果；两个效果的发动次数以SetCountLimit分别设定，实现‘这个卡名的①②的效果1回合各能使用1次’。
function s.initial_effect(c)
	-- 添加超量召唤手续：这张卡以2只龙族7星怪兽作为超量素材叠放进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),7,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合，以自己的墓地·除外状态的1只4星以下的「征龙」怪兽为对象才能发动。把1只在那只怪兽有卡名记述的7星或7阶的「征龙」怪兽从自己的卡组·除外状态特殊召唤。那之后，作为对象的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱卡的效果发动时，把这张卡2个超量素材取除才能发动。那个发动无效并除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	-- 设置②效果的Target为通用无效并除外用目标函数aux.nbtg，用于检查并登记对对方发动的魔法·陷阱卡效果进行无效并除外的操作信息。
	e2:SetTarget(aux.nbtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- ①的发动条件：这张卡成功以超量召唤方式特殊召唤（超量召唤成功的场合）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- ①的对象候选过滤：从自己墓地·除外状态选择1只4星以下的「征龙」怪兽，该怪兽需能回卡组，且自己的卡组·除外状态中存在1只以上可特殊召唤的对应征龙怪兽。
function s.tfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1c4) and c:IsLevelBelow(4) and c:IsAbleToDeck()
		-- 确认自己的卡组·除外状态存在满足s.spfilter的「征龙」怪兽，即存在被对象怪兽记载的7星或7阶征龙怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp,c)
end
-- 特召候选过滤：从自己卡组·除外状态选择1只「征龙」怪兽，要求其卡名被对象征龙怪兽的文本记载，等级或阶级为7，且能以表侧表示特殊召唤。
function s.spfilter(c,e,tp,ec)
	return c:IsFaceupEx() and c:IsSetCard(0x1c4)
		-- 限定候选征龙怪兽的卡名必须记载于作为对象的征龙怪兽的卡片文本中，并且该候选怪兽的等级或阶级为7。
		and aux.IsCodeListed(ec,c:GetCode()) and (c:IsLevel(7) or c:IsRank(7))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ①的发动时点处理：检查自己主怪兽区是否有空位、是否存在合法对象；若为连锁处理中的合法性校验，则验证chkc是否满足对象条件，随后进行对象选择。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tfilter(chkc,e,tp) end
	-- 发动条件验证之一：自己的主要怪兽区存在空位，以确保后续可以特殊召唤征龙怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件验证之一：自己墓地·除外状态存在1只以上满足s.tfilter的4星以下「征龙」怪兽可作为对象。
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 给玩家显示选择对象的提示信息（‘请选择效果的对象’）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地·除外状态选择1只满足s.tfilter的「征龙」怪兽，并登记为当前连锁的效果对象（取对象）。
	local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 登记操作信息：本连锁包含将选定的对象怪兽送回卡组的处理，操作目标为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 登记操作信息：本连锁包含从自己的卡组·除外状态特殊召唤1只怪兽的处理，因具体目标在处理时选择，故targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- ①的效果处理：取得对象并确认关联和空位，让玩家从卡组·除外状态选择1只对应征龙怪兽进行特殊召唤；特召成功后中断效果处理，再将作为对象的怪兽送回持有者卡组。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的对象卡，即作为对象的墓地/除外征龙怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 处理时再次确认自己的主怪兽区有空位，若没有空位则无法特殊召唤，整个①的效果处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择要特殊召唤的卡的提示信息（‘请选择要特殊召唤的卡’）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的卡组·除外状态选择1只满足s.spfilter且与对象对应的「征龙」怪兽，作为要特殊召唤的卡。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp,tc)
	-- 若存在选择的卡且特殊召唤成功（返回值不为0），则继续执行后续把对象送回卡组的处理。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，使特殊召唤成功与后续回卡组操作不在同一时点继续，正确对应原文的‘那之后’。
		Duel.BreakEffect()
		-- 用王家长眠之谷过滤条件判定对象怪兽，确认其不受王家长眠之谷等效果影响，可以将其作为对象送回卡组。
		if aux.NecroValleyFilter()(tc) then
			-- 把作为对象的征龙怪兽送回持有者卡组，并使用SEQ_DECKSHUFFLE表示回卡组后洗牌。
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- ②的发动条件：对方发动魔法·陷阱卡的效果，该发动可被无效，且这张卡自身没有被战斗破坏。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判定：自身未处于被战斗破坏状态，并且当前连锁尚未被无效（可以被无效）。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
		and ep==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- ②的发动代价：取除这张卡自身的2个超量素材作为cost。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- ②的效果处理：无效对方发动的魔法·陷阱卡的发动；若无效成功且该卡仍与效果关联，则将其以表侧表示除外。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定无效发动成功，且对方发动的那张魔法·陷阱卡仍与连锁效果有关联（没有被其他效果转移或离场），才能继续除外。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动的魔法·陷阱卡本体以表侧表示除外。
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
