--剣闘獣総監エーディトル
-- 效果：
-- 5星以上的「剑斗兽」怪兽×2
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。这张卡不能作为融合素材。
-- ①：1回合1次，可以发动。从额外卡组把「剑斗兽总监 主斗」以外的1只「剑斗兽」融合怪兽无视召唤条件特殊召唤。
-- ②：自己的「剑斗兽」怪兽进行战斗的战斗阶段结束时让那1只怪兽回到持有者的卡组·额外卡组才能发动。从卡组把1只「剑斗兽」怪兽特殊召唤。
function c30864377.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤手续：以2只等级5以上且持有「剑斗兽」字段的怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,c30864377.matfilter,2,true)
	-- 添加接触融合手续：无需「融合」魔法，将己方场上可作为代价送回卡组的怪兽素材送回卡组，从额外卡组特殊召唤此卡。
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_MZONE,0,aux.ContactFusionSendToDeck(c))
	-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c30864377.splimit)
	c:RegisterEffect(e1)
	-- 这张卡不能作为融合素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ①：1回合1次，可以发动。从额外卡组把「剑斗兽总监 主斗」以外的1只「剑斗兽」融合怪兽无视召唤条件特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30864377,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c30864377.esptg)
	e4:SetOperation(c30864377.espop)
	c:RegisterEffect(e4)
	-- ②：自己的「剑斗兽」怪兽进行战斗的战斗阶段结束时让那1只怪兽回到持有者的卡组·额外卡组才能发动。从卡组把1只「剑斗兽」怪兽特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(30864377,4))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCost(c30864377.spcost)
	e6:SetTarget(c30864377.sptg)
	e6:SetOperation(c30864377.spop)
	c:RegisterEffect(e6)
end
-- 融合素材过滤：判定卡片是否为等级5以上且拥有「剑斗兽」字段的怪兽。
function c30864377.matfilter(c)
	return c:IsLevelAbove(5) and c:IsFusionSetCard(0x1019)
end
-- 特殊召唤条件限制：限制此卡从非额外卡组区域才能被特殊召唤，防止未经正规手续直接从额外卡组被其他效果拉出。
function c30864377.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- ①效果的特招对象过滤：选择额外卡组中持有「剑斗兽」字段的融合怪兽，排除本卡自身，并满足可被本次效果无视召唤条件特殊召唤且额外怪兽区有空位。
function c30864377.espfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_FUSION) and not c:IsCode(30864377)
		-- 确认该融合怪兽能够被本次效果无视召唤条件特殊召唤，且从额外卡组出场时有可用的怪兽区域。
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ①效果的目标判定：发动时检查额外卡组是否存在至少1只符合条件的「剑斗兽」融合怪兽，并登记特殊召唤的操作信息。
function c30864377.esptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：搜索自己额外卡组中是否存在至少1只满足条件的「剑斗兽」融合怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c30864377.espfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 登记本次效果将进行1只怪兽的特殊召唤，来源区域为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的处理：从额外卡组选择1只符合条件的「剑斗兽」融合怪兽，并以表侧表示特殊召唤到场上。
function c30864377.espop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从己方额外卡组选择1张符合条件的「剑斗兽」融合怪兽。
	local g=Duel.SelectMatchingCard(tp,c30864377.espfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的融合怪兽以表侧表示特殊召唤到己方怪兽区域，无视其召唤条件。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- ②效果cost怪兽过滤：表侧表示、持有「剑斗兽」字段、本回合进行过战斗、可作为代价送回卡组/额外卡组，并保证发动后仍有怪兽区供特殊召唤。
function c30864377.spcfilter(c,ft)
	return c:IsFaceup() and c:IsSetCard(0x1019) and c:GetBattledGroupCount()>0
		and c:IsAbleToDeckOrExtraAsCost() and (ft>0 or c:GetSequence()<5)
end
-- ②效果的代价处理：先获取可用主怪兽区空格，再选择符合条件的己方「剑斗兽」怪兽，向对手展示后送回持有者卡组并洗牌，作为发动代价。
function c30864377.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方主要怪兽区域当前可用的空格数，用于代价选择及后续特殊召唤空间的判断。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 代价检查：当前存在可用怪兽区域，且己方场上有至少1只符合条件的「剑斗兽」怪兽可供选择送回卡组。
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c30864377.spcfilter,tp,LOCATION_MZONE,0,1,nil,ft) end
	-- 弹出“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家从自己场上选择1只符合条件的「剑斗兽」怪兽作为代价送回卡组。
	local g=Duel.SelectMatchingCard(tp,c30864377.spcfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 将选择的代价卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 将代价卡送回持有者卡组并洗牌（作为发动代价）。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- ②效果从卡组特招对象的过滤：持有「剑斗兽」字段，且能被本次效果特殊召唤。
function c30864377.spfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标判定：检查卡组中是否存在可特殊召唤的「剑斗兽」怪兽，并登记从卡组特殊召唤的操作信息。
function c30864377.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：搜索卡组中是否存在至少1只满足条件的「剑斗兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c30864377.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次效果将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：确认主怪兽区有空位后，从卡组选择1只「剑斗兽」怪兽，以分步特殊召唤流程表侧表示特殊召唤，并为其注册一个标记。
function c30864377.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 特殊召唤处理前再次确认主怪兽区域有空位，若没有空格则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组选择1只符合条件的「剑斗兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c30864377.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 以分步特殊召唤流程将选中的怪兽表侧表示特殊召唤到场上。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		-- 完成分步特殊召唤流程，使特殊召唤正式生效。
		Duel.SpecialSummonComplete()
	end
end
