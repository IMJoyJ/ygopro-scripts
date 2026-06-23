--ガイストーチ・ゴーレム
-- 效果：
-- 自己对「亡灵拷问巨人」1回合只能有1次特殊召唤。
-- ①：把手卡1只「于贝尔」怪兽给对方观看才能发动。这张卡从手卡往对方场上特殊召唤。那之后，可以把给人观看的怪兽在自己场上特殊召唤。
-- ②：1回合1次，这张卡和「于贝尔」怪兽进行战斗的伤害计算时发动。对方回复3000基本分。
-- ③：这张卡在墓地存在的状态，自己把「于贝尔」特殊召唤的场合才能发动。这张卡在对方场上特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果并设置卡片的特殊召唤限制
function s.initial_effect(c)
	-- 为卡片添加编号78371393的代码列表，用于识别同名卡
	aux.AddCodeList(c,78371393)
	-- 为卡片添加系列编码0x1a5（于贝尔系列），用于系列判定
	aux.AddSetNameMonsterList(c,0x1a5)
	c:SetSPSummonOnce(id)
	-- 注册一个监听卡片进入墓地的单次效果，用于标记卡片是否已在墓地
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
-- 过滤函数，用于筛选手卡中未公开的于贝尔怪兽
function s.cfilter(c)
	return c:IsSetCard(0x1a5) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 特殊召唤效果的费用处理，选择并确认一张手卡中的于贝尔怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要确认给对方的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡中选择一张符合条件的于贝尔怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	local sc=g:GetFirst()
	-- 向对方确认所选的怪兽
	Duel.ConfirmCards(1-tp,sc)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
-- 特殊召唤效果的目标设定，检查是否可以将此卡特殊召唤到对方场上
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查对方场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的处理函数，将此卡特殊召唤到对方场上，并询问是否将确认的怪兽特殊召唤到己方场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将此卡特殊召唤到对方场上
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP) end
	local sc=e:GetLabelObject()
	-- 检查是否可以将确认的怪兽特殊召唤到己方场上
	if sc:IsRelateToEffect(e) and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否将确认的怪兽特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把给人观看的怪兽特殊召唤？"
		-- 中断当前效果，使后续效果处理视为不同时处理
		Duel.BreakEffect()
		-- 将确认的怪兽特殊召唤到己方场上
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 伤害计算前的条件判断，检查战斗中的对方怪兽是否为于贝尔系列
function s.reccon(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsFaceup() and bc:IsSetCard(0x1a5)
end
-- 回复基本分效果的目标设定，准备回复对方3000基本分
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将回复对方3000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,3000)
end
-- 回复基本分效果的处理函数，使对方回复3000基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方回复3000基本分
	Duel.Recover(1-tp,3000,REASON_EFFECT)
end
-- 过滤函数，用于筛选己方成功召唤的亡灵拷问巨人
function s.spfgfilter(c,tp,se)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsCode(78371393) and c:IsType(TYPE_MONSTER)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 墓地发动效果的条件判断，检查是否有己方召唤的亡灵拷问巨人
function s.spfgcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.spfgfilter,1,nil,tp,se)
end
-- 墓地发动效果的目标设定，检查是否可以将此卡特殊召唤到对方场上
function s.spfgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查对方场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 墓地发动效果的处理函数，将此卡特殊召唤到对方场上
function s.spfgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到对方场上
		Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
