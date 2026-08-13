--クリバー
-- 效果：
-- 这个卡名在规则上也当作「栗子球」卡使用。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡或者自己的「栗子球」怪兽被战斗破坏时才能发动。从卡组把「栗子丸」以外的1只攻击力300/守备力200的怪兽特殊召唤。
-- ②：把场上的这张卡和自己的手卡·场上的「栗子团」「栗子圆」「栗子珠」「栗子球」各1只解放才能发动。从自己的手卡·卡组·墓地选1只「巴比伦栗子」特殊召唤。
function c44632120.initial_effect(c)
	-- 将「栗子团」「栗子圆」「栗子珠」「栗子球」的卡号注册为本卡关联卡名，使本卡在规则上也当作「栗子球」卡使用。
	aux.AddCodeList(c,71036835,7021574,34419588,40640057)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡或者自己的「栗子球」怪兽被战斗破坏时才能发动。从卡组把「栗子丸」以外的1只攻击力300/守备力200的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44632120,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,44632120)
	e1:SetTarget(c44632120.sptg)
	e1:SetOperation(c44632120.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c44632120.spcon)
	c:RegisterEffect(e2)
	-- ②：把场上的这张卡和自己的手卡·场上的「栗子团」「栗子圆」「栗子珠」「栗子球」各1只解放才能发动。从自己的手卡·卡组·墓地选1只「巴比伦栗子」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44632120,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c44632120.spcost2)
	e3:SetTarget(c44632120.sptg2)
	e3:SetOperation(c44632120.spop2)
	c:RegisterEffect(e3)
end
-- 为「栗子团」「栗子圆」「栗子珠」「栗子球」四个卡号各生成一个卡名判定闭包，用于后续检查解放素材是否每种各1只。
c44632120.spchecks=aux.CreateChecks(Card.IsCode,{71036835,7021574,34419588,40640057})
-- ①效果的特殊召唤候选过滤：攻击力300、守备力200、卡名不是「栗子丸」，且能被玩家tp特殊召唤的怪兽。
function c44632120.spfilter(c,e,tp)
	return c:IsDefense(200) and c:IsAttack(300) and not c:IsCode(44632120) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：只有自己场上存在可用的怪兽区空位，且卡组中存在符合条件的特殊召唤候选时，该效果才能发动。
function c44632120.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区，以确保特殊召唤时有格子可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足spfilter的怪兽（攻击力300/守备力200且非「栗子丸」）。
		and Duel.IsExistingMatchingCard(c44632120.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本连锁的操作信息登记为“从卡组特殊召唤1只怪兽”，供其他卡（如星尘龙）进行效果发动的检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：选择1只符合条件的怪兽从卡组表侧攻击表示特殊召唤到自己的场上。
function c44632120.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有空余的怪兽区；若没有空位，则特殊召唤不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组中选出1只满足条件的怪兽（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c44632120.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧攻击表示特殊召唤到自己场上，并正常检查召唤条件和苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定被战斗破坏的怪兽是否是自己场上原有的「栗子球」系怪兽（包括本卡在规则上也视为「栗子球」）。其中0xa4是「栗子球」相关的系列编号。
function c44632120.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0xa4)
end
-- ①效果的FIELD触发条件：当有自己场上的「栗子球」怪兽被战斗破坏时，这个效果也能发动（本卡在场上时监听全场符合条件的战破事件）。
function c44632120.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44632120.cfilter,1,nil,tp)
end
-- 过滤出「栗子团」「栗子圆」「栗子珠」「栗子球」中，可以作为解放素材的自己的手卡·场上的卡，作为②效果cost的候选。
function c44632120.rlfilter(c,tp)
	return c:IsCode(71036835,7021574,34419588,40640057) and (c:IsControler(tp) or c:IsFaceup())
end
-- 验证选出的4张素材卡加上本卡后，自己场上仍有可用的怪兽区空位，并且这些卡确实满足解放条件，以此保证发动②效果后能正常特殊召唤。
function c44632120.rlcheck(sg,c,tp)
	local g=sg:Clone()
	g:AddCard(c)
	-- 同时满足：这些卡解放后仍有怪兽区空位（用于特殊召唤「巴比伦栗子」），且这些卡能够作为cost被解放。
	return Duel.GetMZoneCount(tp,g)>0 and Duel.CheckReleaseGroupEx(tp,aux.IsInGroup,#g,REASON_COST,true,nil,g)
end
-- ②效果的cost处理：从自己的手卡·场上选择「栗子团」「栗子圆」「栗子珠」「栗子球」各1只，再加上场上的本卡，全部解放作为发动代价。
function c44632120.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 取得自己可解放的卡组（包含手卡），并过滤出4种指定卡名的怪兽作为可选的解放素材；参数true表示将手卡也计入可解放范围。
	local g=Duel.GetReleaseGroup(tp,true):Filter(c44632120.rlfilter,c,tp)
	if chk==0 then return c:IsReleasable() and g:CheckSubGroupEach(c44632120.spchecks,c44632120.rlcheck,c,tp) end
	-- 向玩家显示“请选择要解放的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:SelectSubGroupEach(tp,c44632120.spchecks,false,c44632120.rlcheck,c,tp)
	-- 若场上有类似“暗影敌托邦”等代替解放次数的效果，消耗其相应的追加解放次数。
	aux.UseExtraReleaseCount(rg,tp)
	rg:AddCard(c)
	-- 将选择的全部解放素材作为cost解放（送入墓地）。
	Duel.Release(rg,REASON_COST)
end
-- ②效果的特殊召唤候选过滤：选择卡名为「巴比伦栗子」并且能够被玩家tp特殊召唤的怪兽。
function c44632120.spfilter2(c,e,tp)
	return c:IsCode(70914287) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件判定：手卡·卡组·墓地中存在至少1只符合条件的「巴比伦栗子」怪兽。
function c44632120.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·卡组·墓地是否存在满足spfilter2的「巴比伦栗子」；若存在则允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c44632120.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本连锁的操作信息：从手卡·卡组·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
-- ②效果处理：选择1只「巴比伦栗子」从手卡·卡组·墓地特殊召唤到自己的场上。
function c44632120.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时确认自己有怪兽区空位，若没有则终止特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地中选择1只「巴比伦栗子」；使用NecroValleyFilter过滤掉受王家长眠之谷影响而不能从墓地特殊召唤的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c44632120.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「巴比伦栗子」表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
