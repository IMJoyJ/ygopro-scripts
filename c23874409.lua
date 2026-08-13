--カラクリ将軍 無零
-- 效果：
-- 调整＋调整以外的机械族怪兽1只以上
-- 这张卡同调召唤成功时，可以从自己卡组把1只名字带有「机巧」的怪兽特殊召唤。1回合1次，可以选择场上存在的1只怪兽，把表示形式变更。
function c23874409.initial_effect(c)
	-- 为这张卡添加同调召唤手续，素材要求为调整＋调整以外的机械族怪兽1只以上（调整不限，调整以外的怪兽均为机械族）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_MACHINE),1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，可以从自己卡组把1只名字带有「机巧」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23874409,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c23874409.spcon)
	e1:SetTarget(c23874409.sptg)
	e1:SetOperation(c23874409.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以选择场上存在的1只怪兽，把表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23874409,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c23874409.postg)
	e2:SetOperation(c23874409.posop)
	c:RegisterEffect(e2)
end
-- 效果的发动条件：当这张卡以同调召唤方式特殊召唤成功时，触发本效果。
function c23874409.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 定义候选怪兽的过滤条件：必须是「机巧」字段的怪兽，且满足可被效果特殊召唤的合法性检查（遵守召唤条件和苏生限制）。
function c23874409.spfilter(c,e,tp)
	return c:IsSetCard(0x11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的合法性检查：需要己方主要怪兽区有空位，且卡组中存在1只以上满足spfilter条件的「机巧」怪兽。
function c23874409.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有可用空位（若无空位则不能发动）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足spfilter条件的「机巧」怪兽（作为特殊召唤候选）。
		and Duel.IsExistingMatchingCard(c23874409.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明本次效果处理将从卡组特殊召唤1只怪兽，类别为特殊召唤，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若己方主要怪兽区仍有空位，则提示玩家从卡组选择1只满足条件的「机巧」怪兽，以表侧攻击表示特殊召唤到己方场上。
function c23874409.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认：若己方主要怪兽区没有空位，则特殊召唤处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示：请选择要特殊召唤的卡，供后续从卡组选择卡片时使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1张满足spfilter条件的「机巧」怪兽作为要特殊召唤的卡。
	local g=Duel.SelectMatchingCard(tp,c23874409.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到己方场上（采用效果特殊召唤手续，遵守常规召唤条件检查）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义表示形式变更对象的过滤条件：怪兽必须是可以被效果改变表示形式的怪兽。
function c23874409.filter(c)
	return c:IsCanChangePosition()
end
-- 效果发动与目标选择：检查场上存在可取对象的怪兽后，选择场上1只满足filter条件的怪兽作为对象，并设置操作信息。
function c23874409.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c23874409.filter(chkc) end
	-- 检查场上是否存在至少1只可以满足变更表示形式条件且能被取为对象的怪兽，作为效果发动的合法性条件。
	if chk==0 then return Duel.IsExistingTarget(c23874409.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示：请选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择场上1只满足filter条件的怪兽作为效果对象，并登记为当前连锁的目标。
	local g=Duel.SelectTarget(tp,c23874409.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明本次效果将变更1只对象怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：取得对象怪兽，若对象仍与效果有联系，则将其表示形式变更。
function c23874409.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中已登记的目标怪兽（第一个，也是唯一一个）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 变更对象怪兽的表示形式：表侧攻击表示变为表侧守备表示，表侧守备表示变为表侧攻击表示，里侧表示翻开为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
