--炎王神獣 ガルドニクス
-- 效果：
-- ①：这张卡被效果破坏送去墓地的场合，下次的准备阶段发动。这张卡从墓地特殊召唤。
-- ②：这张卡的①的效果特殊召唤的场合发动。场上的其他怪兽全部破坏。
-- ③：这张卡被战斗破坏送去墓地时才能发动。从卡组把「炎王神兽 大鹏不死鸟」以外的1只「炎王」怪兽特殊召唤。
function c23015896.initial_effect(c)
	-- ①：这张卡被效果破坏送去墓地的场合，下次的准备阶段发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c23015896.spreg)
	c:RegisterEffect(e1)
	-- ①：下次的准备阶段发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23015896,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c23015896.spcon)
	e2:SetTarget(c23015896.sptg)
	e2:SetOperation(c23015896.spop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：这张卡的①的效果特殊召唤的场合发动。场上的其他怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23015896,1))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c23015896.descon)
	e3:SetTarget(c23015896.destg)
	e3:SetOperation(c23015896.desop)
	c:RegisterEffect(e3)
	-- ③：这张卡被战斗破坏送去墓地时才能发动。从卡组把「炎王神兽 大鹏不死鸟」以外的1只「炎王」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(23015896,2))  --"卡组特召"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetCondition(c23015896.spcon2)
	e4:SetTarget(c23015896.sptg2)
	e4:SetOperation(c23015896.spop2)
	c:RegisterEffect(e4)
end
-- 该函数由e1在怪兽被送去墓地时触发，检查破坏原因是否为效果破坏；若是，则记录当前是否处于准备阶段：若在准备阶段则保存当前回合数并设置2次准备阶段重置的标记，否则保存0并设置1次准备阶段重置的标记，以确保①效果在下一次准备阶段发动。
function c23015896.spreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 then return end
	-- 判断当前阶段是否为准备阶段，用于决定被效果破坏时是否已经处于准备阶段，从而正确计算延迟到下一次准备阶段的时机。
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 将被效果破坏时的回合数记录到e1的Label中，供spcon条件判断是否为“下一次”准备阶段（排除当回合）。
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(23015896,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(23015896,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
	end
end
-- 该条件函数判断e2能否发动：要求e1记录的回合数不等于当前回合数（表示已不是被破坏的那个回合），且卡片带有23015896标记（表示确实曾因效果破坏送去墓地）。
function c23015896.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断e1的Label（被效果破坏时的回合数）与当前回合数不同，且自身带有23015896标记，两者同时成立才符合发动条件。
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(23015896)>0
end
-- 该目标函数在效果发动时无需选择对象，直接登记将自身特殊召唤的操作信息，并清除23015896标记（防止重复发动）。
function c23015896.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 将特殊召唤这张卡（c）登记为操作信息，数量1，用于后续处理和相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(23015896)
end
-- 该效果处理时，若这张卡仍与效果存在联系（未被除外等），则将其以自身效果特殊召唤上场。
function c23015896.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以自身效果（SUMMON_VALUE_SELF）将这张卡表侧表示特殊召唤到其持有者场上，不检查召唤条件和苏生限制。
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡是被①效果特殊召唤成功的（通过自身效果特殊召唤，召唤类型为SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF）。
function c23015896.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- ②效果的目标处理：不指定对象，但登记破坏场上除自身以外的所有怪兽为操作信息，以便处理时统一破坏。
function c23015896.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上（双方怪兽区）除这张卡自身以外的所有怪兽，作为预计要破坏的卡集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 将上述怪兽集合及其数量登记到操作信息中，表示该效果将破坏这些怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，重新获取场上除自身以外的所有怪兽，并将其全部破坏。
function c23015896.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取当前场上除自身外的所有怪兽（因为发动时与处理时场面可能不同，需以处理时为准）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 以效果破坏这些怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
-- ③效果的发动条件：这张卡被战斗破坏后位于墓地（即因此战斗破坏被送去墓地）。
function c23015896.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义卡组检索筛选条件：必须是「炎王」系列（0x81）怪兽，卡名不是「炎王神兽 大鹏不死鸟」，且可以被特殊召唤。
function c23015896.spfilter(c,e,tp)
	return c:IsSetCard(0x81) and not c:IsCode(23015896) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动时确认：满足自己主要怪兽区有空位且卡组存在符合条件的「炎王」怪兽时，才可发动；并通过SetOperationInfo登记从卡组特殊召唤1只怪兽。
function c23015896.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空闲的主要怪兽区域，作为能否发动特殊召唤的前提条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足spfilter条件的「炎王」怪兽。
		and Duel.IsExistingMatchingCard(c23015896.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记从卡组特殊召唤1只怪兽的操作信息，因具体怪兽在效果处理时才选择，目标设为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，若仍有空位，则提示玩家选择，从卡组选出1只符合条件的「炎王」怪兽并表侧表示特殊召唤。
function c23015896.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 如果处理时主要怪兽区没有空位，则直接终止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示信息，提示其选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中筛选并选择1只满足spfilter条件的「炎王」怪兽。
	local g=Duel.SelectMatchingCard(tp,c23015896.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的怪兽以表侧表示特殊召唤到玩家场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
