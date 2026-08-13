--ガイストーチ・ゴーレム
-- 效果：
-- 自己对「亡灵拷问巨人」1回合只能有1次特殊召唤。
-- ①：把手卡1只「于贝尔」怪兽给对方观看才能发动。这张卡从手卡往对方场上特殊召唤。那之后，可以把给人观看的怪兽在自己场上特殊召唤。
-- ②：1回合1次，这张卡和「于贝尔」怪兽进行战斗的伤害计算时发动。对方回复3000基本分。
-- ③：这张卡在墓地存在的状态，自己把「于贝尔」特殊召唤的场合才能发动。这张卡在对方场上特殊召唤。
local s,id,o=GetID()
-- 初始化函数：为「亡灵拷问巨人」注册“于贝尔”相关卡名/系列辅助信息、一回合一次特殊召唤限制、墓地存在标记检测，以及效果①②③对应的三个效果对象。
function s.initial_effect(c)
	-- 向该卡注册代码列表，标记其效果文本中提到了「于贝尔」（卡号78371393），用于相关规则判定。
	aux.AddCodeList(c,78371393)
	-- 向该卡注册系列字段0x1a5（「于贝尔」），使其效果文本中的「于贝尔」系列怪兽能被正确匹配。
	aux.AddSetNameMonsterList(c,0x1a5)
	c:SetSPSummonOnce(id)
	-- 创建并注册“这张卡已在墓地”的标记检测效果，用于在③中正确判定此卡是否已在墓地存在，返回的e0作为标记效果供e3引用。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：把手卡1只「于贝尔」怪兽给对方观看才能发动。这张卡从手卡往对方场上特殊召唤。那之后，可以把给人观看的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"往对方场上特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡和「于贝尔」怪兽进行战斗的伤害计算时发动。对方回复3000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回复基本分"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.reccon)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的状态，自己把「于贝尔」特殊召唤的场合才能发动。这张卡在对方场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"往对方场上特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetLabelObject(e0)
	e3:SetCondition(s.spfgcon)
	e3:SetTarget(s.spfgtg)
	e3:SetOperation(s.spfgop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判定手牌中存在尚未公开的「于贝尔」系列怪兽，用于①的cost选择。
function s.cfilter(c)
	return c:IsSetCard(0x1a5) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- ①的cost处理：从手牌选择1只「于贝尔」怪兽给对方观看，记录该怪兽与效果的关联，并确认手牌后洗切。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查：自己的手牌中是否存在至少1只满足cfilter条件的「于贝尔」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择一张手牌中的「于贝尔」怪兽用于给对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从自己手牌中选出1只满足cfilter条件的「于贝尔」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	local sc=g:GetFirst()
	-- 将选中的「于贝尔」怪兽展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,sc)
	-- 洗切手牌，以消除确认手牌造成的手牌顺序信息。
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
-- ①的目标判定：确认此卡在手牌且可以被特殊召唤，同时对方场上有空位可特殊召唤到对方场上。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查对方主要怪兽区是否有可用空格，用于将此卡特殊召唤到对方场上。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将进行特殊召唤，对象为此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①的效果处理：先将自己特殊召唤到对方场上；随后若展示的怪兽仍关联且可特殊召唤，则询问玩家是否将其在自己场上特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果关联，则将此卡以表侧表示特殊召唤到对方场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP) end
	local sc=e:GetLabelObject()
	-- 确认展示的「于贝尔」怪兽仍与本效果关联、可以特殊召唤，并且自己场上有空位。
	if sc:IsRelateToEffect(e) and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否要把展示的「于贝尔」怪兽特殊召唤到自己场上。
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把给人观看的怪兽特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤作为新的连锁处理，避免错过时点。
		Duel.BreakEffect()
		-- 将展示的「于贝尔」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②的发动条件：这张卡进行战斗，且战斗对象为表侧表示的「于贝尔」怪兽，在伤害计算时满足发动条件。
function s.reccon(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsFaceup() and bc:IsSetCard(0x1a5)
end
-- ②的目标判定：效果必发，设置对方回复3000基本分的操作信息。
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果将让对方回复3000基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,3000)
end
-- ②的效果处理：让对方回复3000基本分。
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行对方回复3000LP，原因为效果。
	Duel.Recover(1-tp,3000,REASON_EFFECT)
end
-- 过滤函数：检测本次特殊召唤成功的怪兽是否为对方场上表侧表示、由tp玩家特殊召唤的「于贝尔」（卡号78371393），且不是③效果自身引发的特殊召唤。
function s.spfgfilter(c,tp,se)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsCode(78371393) and c:IsType(TYPE_MONSTER)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ③的发动条件：e0标记表明此卡已在墓地存在，且本次特殊召唤成功的事件中存在满足spfgfilter的「于贝尔」怪兽。
function s.spfgcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.spfgfilter,1,nil,tp,se)
end
-- ③的目标判定：对方场上有空位且此卡可以被特殊召唤。
function s.spfgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查对方主要怪兽区是否有可用空格，用于将此卡从墓地特殊召唤到对方场上。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将把此卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③的效果处理：若此卡仍与效果关联，则将其特殊召唤到对方场上。
function s.spfgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到对方场上。
		Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
