--剣闘獣ドミティアノス
-- 效果：
-- 「剑斗兽 维斯帕西亚努斯」＋「剑斗兽」怪兽×2
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：1回合1次，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ②：只要这张卡在怪兽区域存在，对方怪兽的攻击对象由自己选择。
-- ③：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把1只「剑斗兽」怪兽特殊召唤。
function c33652635.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册融合召唤素材组合：需要卡号88996322的『剑斗兽 维斯帕西亚努斯』1只和任意2只『剑斗兽』字段怪兽作为融合素材。
	aux.AddFusionProcCodeFun(c,88996322,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1019),2,true,true)
	-- 添加接触融合召唤手续：将自己场上满足c33652635.cfilter的素材怪兽送回卡组，无需『融合』魔法即可从额外卡组特殊召唤这张卡。
	aux.AddContactFusionProcedure(c,c33652635.cfilter,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 「剑斗兽 维斯帕西亚努斯」＋「剑斗兽」怪兽×2 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c33652635.splimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33652635,0))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c33652635.condition)
	e2:SetTarget(c33652635.target)
	e2:SetOperation(c33652635.operation)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，对方怪兽的攻击对象由自己选择。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
	-- ③：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把1只「剑斗兽」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(33652635,1))  --"回到卡组并特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c33652635.spcon)
	e4:SetCost(c33652635.spcost)
	e4:SetTarget(c33652635.sptg)
	e4:SetOperation(c33652635.spop)
	c:RegisterEffect(e4)
end
-- 特殊召唤条件限制：只有这张卡位于额外卡组时才允许被特殊召唤，从而保证它只能通过正规接触融合（或融合召唤）从额外卡组出场，不能从墓地或除外等区域被特殊召唤。
function c33652635.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 接触融合素材的单卡过滤条件：素材必须是卡号88996322的『剑斗兽 维斯帕西亚努斯』或属于『剑斗兽』字段的怪兽，并且能够作为代价送回卡组/额外卡组；素材组合数量由融合手续另外规定。
function c33652635.cfilter(c)
	return (c:IsFusionCode(88996322) or c:IsFusionSetCard(0x1019) and c:IsType(TYPE_MONSTER)) and c:IsAbleToDeckOrExtraAsCost()
end
-- ①效果的发动条件判定：对方玩家发动怪兽效果、这张卡未被战斗破坏、且该连锁可以无效，三者同时满足时才能发动。
function c33652635.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断条件：rp==1-tp（对方发动）、re为怪兽效果、此卡未因战斗破坏、Duel.IsChainNegatable(ev)（连锁可被无效）。
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- ①效果发动时的目标处理：不取对象；向系统登记本效果要无效对方发动的那个效果，并在条件满足时将对方发动效果的那只怪兽追加为破坏对象。
function c33652635.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方发动的连锁中的效果（eg）标记为将受到无效处理（CATEGORY_NEGATE）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：在对方发动效果的那只怪兽可破坏且仍与效果相关时，将其标记为将被破坏（CATEGORY_DESTROY）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ①效果的实际处理：先无效对方怪兽效果的发动；如果无效成功且该怪兽仍与此连锁相关，则将其破坏。
function c33652635.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：只有当无效发动成功，且对方那只发动效果的怪兽仍然与效果关联时，才继续执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因将eg中对方发动效果的那只怪兽破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ③效果的发动条件：这张卡在本次战斗阶段内实际进行过战斗（存在战斗过的对手怪兽）。
function c33652635.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- ③效果的发动代价：检查并支付将这张卡自身送回持有者额外卡组的代价（发动前支付，不进入连锁）。
function c33652635.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	-- 将这张卡自身送回持有者额外卡组顶端，作为效果发动COST。
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
-- 特殊召唤对象筛选：从卡组选择1只『剑斗兽』字段怪兽，且该怪兽能够被效果特殊召唤（已经通过召唤条件和苏生限制的检查）。
function c33652635.filter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的目标处理：不取对象；需要确认自己场上有可用怪兽区空位且卡组存在符合条件的『剑斗兽』怪兽，满足后登记特殊召唤操作。
function c33652635.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上除去此卡后是否还有可用的怪兽区空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否至少存在1只符合c33652635.filter条件的『剑斗兽』怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c33652635.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本效果将进行特殊召唤，目标数量1，从己方卡组特殊召唤（具体卡在处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果的实际处理：若自己怪兽区仍有空位，则从卡组挑选1只符合条件的『剑斗兽』怪兽以表侧表示特殊召唤，并给它登记一个标志效果（通常用于记录本次召唤或施加限制）。
function c33652635.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 特殊召唤前再次检查主怪兽区是否有空位；若无空位，直接停止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示：请选择要特殊召唤的卡（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中筛选并选择1只满足条件的『剑斗兽』怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c33652635.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上（检查召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
