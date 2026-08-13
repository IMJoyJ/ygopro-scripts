--鉄獣戦線 銀弾のルガル
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方主要阶段才能发动。从自己的手卡·墓地把1只4星以下的兽族·兽战士族·鸟兽族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段回到持有者手卡。
-- ②：这张卡被送去墓地的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降自己场上的怪兽的种族种类×300。
function c52331012.initial_effect(c)
	-- 为这张卡添加连接召唤手续，要求用2~3只兽族·兽战士族·鸟兽族怪兽作为连接素材（对应召唤条件）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),2,3)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方主要阶段才能发动。从自己的手卡·墓地把1只4星以下的兽族·兽战士族·鸟兽族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52331012,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,52331012)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c52331012.spcon)
	e1:SetTarget(c52331012.sptg)
	e1:SetOperation(c52331012.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降自己场上的怪兽的种族种类×300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52331012,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,52331013)
	e2:SetTarget(c52331012.atktg)
	e2:SetOperation(c52331012.atkop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：当前不是自己的回合，且处于主要阶段1或主要阶段2，即对方主要阶段。
function c52331012.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是效果发动者，确保只能在对方回合发动。
	return Duel.GetTurnPlayer()~=tp
		-- 并且当前阶段为主要阶段1或主要阶段2，满足“对方主要阶段”的时点要求。
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 定义可特殊召唤的怪兽过滤条件：兽族/兽战士族/鸟兽族、等级4以下，且能够被特殊召唤。
function c52331012.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①发动时的目标检查：自己主要怪兽区有空位，且手卡·墓地存在满足条件的怪兽。
function c52331012.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己主要怪兽区有空闲格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且手卡·墓地存在至少1只满足特殊召唤条件的兽族/兽战士族/鸟兽族·4星以下怪兽。
		and Duel.IsExistingMatchingCard(c52331012.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 将本次发动登记为特殊召唤操作，并预定从自己手卡·墓地处理1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①处理时从手卡·墓地选择符合条件的怪兽特殊召唤，并对其附加效果无效化和结束阶段回手的效果。
function c52331012.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区是否有空位，无空位则特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·墓地选择1只满足条件且不受王家长眠之谷影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c52331012.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将被选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤流程，确认特殊召唤成功。
		Duel.SpecialSummonComplete()
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(52331012,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 结束阶段回到持有者手卡。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c52331012.thcon)
		e3:SetOperation(c52331012.thop)
		-- 将“结束阶段回手”的持续效果注册到场上，使该怪兽在结束阶段返回持有者手卡。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 回手效果的触发条件：检查被特殊召唤的怪兽是否仍带有对应标记，若标记丢失则重置回手效果。
function c52331012.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(52331012)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 回手效果的处理：在结束阶段将被①效果特殊召唤的怪兽送回持有者手卡。
function c52331012.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将记录的被特殊召唤怪兽以效果原因返回持有者手卡。
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
-- ②效果统计种族种类时的过滤条件：表侧表示且拥有种族。
function c52331012.atkfilter(c)
	return c:IsFaceup() and c:GetRace()~=0
end
-- ②效果发动时点检查：自己场上有表侧表示且持有种族的怪兽，且对方场上有表侧表示怪兽。
function c52331012.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己场上存在至少1只表侧表示且拥有种族的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c52331012.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且确认对方场上存在至少1只表侧表示怪兽，满足②效果发动条件。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- ②效果处理：统计自己场上怪兽的种族种类数，让对方场上全部表侧表示怪兽攻击力下降该数值×300，直到回合结束。
function c52331012.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上满足条件的表侧表示怪兽组，用于统计种族种类。
	local tg=Duel.GetMatchingGroup(c52331012.atkfilter,tp,LOCATION_MZONE,0,nil)
	local ct=tg:GetClassCount(Card.GetRace)
	-- 取得对方场上的全部表侧表示怪兽组，作为攻击力下降的对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部怪兽的攻击力直到回合结束时下降自己场上的怪兽的种族种类×300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-ct*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
