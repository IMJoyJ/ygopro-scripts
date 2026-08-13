--垂氷の魔妖－雪女
-- 效果：
-- 不死族怪兽2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「垂冰之魔妖-雪女」在自己场上只能有1只表侧表示存在。
-- ②：这张卡特殊召唤成功的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效。
-- ③：把墓地的这张卡除外才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选1只不死族同调怪兽特殊召唤。这个效果在对方回合也能发动。
function c36114945.initial_effect(c)
	c:SetUniqueOnField(1,0,36114945)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以2只以上的不死族连接怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_ZOMBIE),2)
	-- ②效果：这张卡特殊召唤成功的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效。这个卡名的②效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,36114945)
	e1:SetTarget(c36114945.distg)
	e1:SetOperation(c36114945.disop)
	c:RegisterEffect(e1)
	-- ③效果：把墓地的这张卡除外才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选1只不死族同调怪兽特殊召唤。这个效果在对方回合也能发动。这个卡名的③效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,36114946)
	-- 设置③效果的发动代价：将墓地中的这张卡除外作为发动COST。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c36114945.sptg)
	e2:SetOperation(c36114945.spop)
	c:RegisterEffect(e2)
end
-- ②效果的发动条件与选目标处理：特殊召唤成功时，检查对方场上是否存在可无效化的表侧效果怪兽，若有则选择其中1只作为对象，并登记无效该对象的操作信息。
function c36114945.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理时校验对象合法性：若存在指定对象chkc，则确认该对象是对方场上的表侧效果怪兽且可被无效化。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 发动时点合法性检查：确认对方场上有1只以上可作为对象的表侧效果怪兽，满足②效果的发动条件。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家展示“请选择要无效的卡”的提示信息，用于选择对象界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家从对方场上选择1只满足条件的表侧效果怪兽，并将其登记为当前连锁的效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：此次效果将执行“无效”分类，对象为选择的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ②效果处理：取得对象怪兽，若其仍在场上表侧表示且与效果关联且可被无效，则使其效果无效化：将对象相关连锁无效，并给它赋予怪兽效果无效与效果无效化状态。
function c36114945.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中登记的无效对象（被选择的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与对象怪兽相关的连锁效果无效化，并在重置前持续无效（对应“那只怪兽的效果无效”）。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对应②效果“那只怪兽的效果无效。”：给对象怪兽赋予EFFECT_DISABLE，使其怪兽效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对应②效果“那只怪兽的效果无效。”：给对象怪兽赋予EFFECT_DISABLE_EFFECT，使其效果文本无效化，已发动/未发动的效果均被压制。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- ③效果的选卡过滤条件：从自己墓地或除外区选择不死族同调怪兽，且该怪兽能够被当前效果特殊召唤（满足苏生限制与召唤条件）。
function c36114945.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_SYNCHRO) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动条件判定：自己场上有空余的主要怪兽区，且自己墓地或除外区存在满足条件的不死族同调怪兽；满足后设置特殊召唤操作信息。
function c36114945.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点合法性检查：确认自己场上存在可用的主要怪兽区空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 继续检查是否存在至少1只位于自己墓地或除外区、满足条件的不死族同调怪兽，确保有可特殊召唤的对象。
		and Duel.IsExistingMatchingCard(c36114945.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行特殊召唤，预计处理1张卡，来源为自己墓地或除外区。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ③效果处理：若自己场上仍有空位，则从自己墓地或除外区选择1只满足条件且不受王家长眠之谷影响的不死族同调怪兽，以表侧表示特殊召唤。
function c36114945.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上仍有可用的主要怪兽区空格；若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家展示“请选择要特殊召唤的卡”的提示信息，用于选择特殊召唤对象界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地或除外区选择1只满足条件且不受王家长眠之谷影响的不死族同调怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c36114945.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上，不额外检查召唤条件（已在过滤时检查）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
