--水晶機巧－フェニキシオン
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽1只以上
-- ①：这张卡同调召唤成功的场合才能发动。对方的场上·墓地的魔法·陷阱卡全部除外。
-- ②：同调召唤的这张卡被战斗·效果破坏的场合，以这张卡以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c2743001.initial_effect(c)
	-- 为这张卡添加同调召唤手续：同调怪兽调整1只＋调整以外的同调怪兽1只以上（其中作为调整的素材也必须是同调怪兽）。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。对方的场上·墓地的魔法·陷阱卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2743001,0))  --"场上·墓地魔陷除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c2743001.rmcon)
	e1:SetTarget(c2743001.rmtg)
	e1:SetOperation(c2743001.rmop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被战斗·效果破坏的场合，以这张卡以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2743001,1))  --"墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c2743001.spcon)
	e2:SetTarget(c2743001.sptg)
	e2:SetOperation(c2743001.spop)
	c:RegisterEffect(e2)
end
c2743001.material_type=TYPE_SYNCHRO
-- 效果发动条件：这张卡是同调召唤成功（召唤类型为同调召唤）时才能发动。
function c2743001.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：对方场上或墓地的魔法·陷阱卡，且该卡可以被除外。
function c2743001.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 发动时的目标设定：确认对方场上·墓地是否存在可除外的魔法·陷阱卡；若存在，获取全部满足条件的卡并预设置除外操作信息。
function c2743001.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：对方场上·墓地是否存在至少1张满足除外条件的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c2743001.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上·墓地的所有可除外的魔法·陷阱卡（用于预设置操作信息，不在此时除外）。
	local g=Duel.GetMatchingGroup(c2743001.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,nil)
	-- 将上述全部卡作为本次连锁的要除外对象，设置除外操作信息，数量为获取到的卡数，用于其他卡效果的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理：重新获取对方场上·墓地的所有可除外的魔法·陷阱卡，若存在则全部表侧表示除外，除外原因记为效果。
function c2743001.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上·墓地的所有可除外的魔法·陷阱卡（防止发动后情况变化）。
	local g=Duel.GetMatchingGroup(c2743001.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将所有符合条件的对方魔法·陷阱卡表侧表示除外，除外原因记为效果。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果发动条件：这张卡是以同调召唤方式出场，且在怪兽区被战斗或效果破坏（之前位置为怪兽区，破坏原因为战斗/效果）才能发动。
function c2743001.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 墓地怪兽能否被当前效果特殊召唤（以效果e、召唤方式0、由tp玩家特殊召唤，且不忽略召唤条件与苏生限制）。
function c2743001.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②发动时的目标设定：确认自己场上主要怪兽区有空位，且墓地存在这张卡以外的可特殊召唤的怪兽；发动时选择其中1只作为对象。
function c2743001.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2743001.spfilter(chkc,e,tp) and chkc~=e:GetHandler() end
	-- 发动合法性检查：自己场上主要怪兽区存在可用的空位（用于后续特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在这张卡以外的、可以被特殊召唤的怪兽作为可选对象。
		and Duel.IsExistingTarget(c2743001.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 给玩家显示“请选择要特殊召唤的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地中选择1只除这张卡以外且满足条件的怪兽作为对象，并登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c2743001.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 将选中的目标怪兽设置为本次连锁的特殊召唤操作信息，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得选择的对象怪兽，若仍与该效果关联，则将其以表侧表示特殊召唤到自己场上。
function c2743001.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中已登记的对象卡（即选定的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上（特殊召唤方为tp）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
