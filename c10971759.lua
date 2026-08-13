--光虫異変
-- 效果：
-- 「光虫异变」在1回合只能发动1张。
-- ①：以自己墓地2只昆虫族·3星怪兽为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：从自己墓地把这张卡和1只超量怪兽除外才能发动。自己场上的全部昆虫族·3星怪兽的等级直到回合结束时变成和除外的超量怪兽的阶级相同数值的等级。这个效果的发动后，直到回合结束时自己不是昆虫族怪兽不能特殊召唤。
function c10971759.initial_effect(c)
	-- 「光虫异变」在1回合只能发动1张。①：以自己墓地2只昆虫族·3星怪兽为对象才能发动。那些怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10971759,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,10971759+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c10971759.sptg)
	e1:SetOperation(c10971759.spop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和1只超量怪兽除外才能发动。自己场上的全部昆虫族·3星怪兽的等级直到回合结束时变成和除外的超量怪兽的阶级相同数值的等级。这个效果的发动后，直到回合结束时自己不是昆虫族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10971759,1))  --"等级变更"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c10971759.cost)
	e2:SetTarget(c10971759.target)
	e2:SetOperation(c10971759.operation)
	c:RegisterEffect(e2)
end
-- 定义墓地候选对象的过滤条件：必须是等级3的昆虫族怪兽，且能够被当前效果特殊召唤。
function c10971759.spfilter(c,e,tp)
	return c:IsLevel(3) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件检测：确认连锁中的对象合法；发动时检查场上没有【青眼精灵龙】的封锁、自己主要怪兽区有2个以上空格、墓地存在2只可特殊召唤的昆虫族3星怪兽。
function c10971759.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10971759.spfilter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己的主要怪兽区空格数大于1，确保能同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查墓地中存在至少2只满足特殊召唤条件的昆虫族·3星怪兽，且它们都能成为效果对象。
		and Duel.IsExistingTarget(c10971759.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 向玩家显示选择提示，内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择2只满足条件的昆虫族·3星怪兽，并将其登记为这张卡发动时的效果对象。
	local g=Duel.SelectTarget(tp,c10971759.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置操作信息：本次效果将特殊召唤2只对象怪兽，供连锁判定和后续效果使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理：从连锁信息中取得仍与效果关联的对象，检查场地空格与【青眼精灵龙】限制后，将对象怪兽逐一以表侧表示特殊召唤，并给这些怪兽附加效果无效化状态，最后完成特殊召唤。
function c10971759.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象组，并过滤出仍然与当前效果有关联的卡，防止对象被无效或离场后仍被处理。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	local tc=g:GetFirst()
	while tc do
		-- 将一只对象怪兽以表侧表示加入特殊召唤处理，作为连续特殊召唤的中间一步。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。②：从自己墓地把这张卡和1只超量怪兽除外才能发动。自己场上的全部昆虫族·3星怪兽的等级直到回合结束时变成和除外的超量怪兽的阶级相同数值的等级。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc=g:GetNext()
	end
	-- 结束特殊召唤的连续处理，正式完成所有特殊召唤并触发召唤成功的时点。
	Duel.SpecialSummonComplete()
end
-- 定义②效果发动代价的过滤条件：除外墓地的1只超量怪兽，且阶级不等于3（避免等级不发生变化）。
function c10971759.cfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:GetRank()~=3 and c:IsAbleToRemoveAsCost()
end
-- 判定能否支付②效果的代价：这张卡自身可以从墓地除外，且墓地存在1只满足条件的超量怪兽。
function c10971759.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查墓地中是否存在至少1只满足条件的超量怪兽，作为除外代价。
		and Duel.IsExistingMatchingCard(c10971759.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只满足条件的超量怪兽，作为发动②效果要除外的对象。
	local g=Duel.SelectMatchingCard(tp,c10971759.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetRank())
	g:AddCard(e:GetHandler())
	-- 将选择的超量怪兽与这张卡一起以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义②效果影响的对象条件：自己场上的表侧表示、等级3、昆虫族怪兽。
function c10971759.filter(c)
	return c:IsFaceup() and c:IsLevel(3) and c:IsRace(RACE_INSECT)
end
-- ②效果的目标判定：自己场上是否存在表侧表示的昆虫族3星怪兽，存在才可发动。
function c10971759.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时的合法检查：若自己场上不存在满足条件的表侧昆虫族3星怪兽，则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c10971759.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：将场上所有表侧昆虫族3星怪兽的等级变为记录的超量怪兽阶级，并给当前玩家附加“不能特殊召唤昆虫族以外怪兽”的自肃效果直到回合结束。
function c10971759.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有满足条件的表侧表示、等级3、昆虫族怪兽的集合。
	local g=Duel.GetMatchingGroup(c10971759.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部昆虫族·3星怪兽的等级直到回合结束时变成和除外的超量怪兽的阶级相同数值的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 这个效果的发动后，直到回合结束时自己不是昆虫族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c10971759.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，作为影响当前玩家的效果，持续到结束阶段。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃效果的限制条件：不是昆虫族的怪兽不能被特殊召唤。
function c10971759.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT)
end
