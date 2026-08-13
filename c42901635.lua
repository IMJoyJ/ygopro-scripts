--電磁石の戦士マグネット・ベルセリオン
-- 效果：
-- 这张卡不能通常召唤。从自己的手卡·场上·墓地把「电磁石战士α」「电磁石战士β」「电磁石战士γ」各1只除外的场合可以特殊召唤。
-- ①：从自己墓地把1只4星以下的「磁石战士」怪兽除外，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：这张卡被战斗或者对方的效果破坏的场合，以除外的自己的「电磁石战士α」「电磁石战士β」「电磁石战士γ」各1只为对象才能发动。那些怪兽特殊召唤。
function c42901635.initial_effect(c)
	c:EnableReviveLimit()
	-- 从自己的手卡·场上·墓地把「电磁石战士α」「电磁石战士β」「电磁石战士γ」各1只除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c42901635.spcon)
	e1:SetTarget(c42901635.sptg)
	e1:SetOperation(c42901635.spop)
	c:RegisterEffect(e1)
	-- ①：从自己墓地把1只4星以下的「磁石战士」怪兽除外，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c42901635.cost)
	e2:SetTarget(c42901635.target)
	e2:SetOperation(c42901635.activate)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗或者对方的效果破坏的场合，以除外的自己的「电磁石战士α」「电磁石战士β」「电磁石战士γ」各1只为对象才能发动。那些怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(c42901635.spcon2)
	e3:SetTarget(c42901635.sptg2)
	e3:SetOperation(c42901635.spop2)
	c:RegisterEffect(e3)
end
-- 为「电磁石战士α」「电磁石战士β」「电磁石战士γ」分别生成三个卡名判定闭包，用于后续检查素材是否各存在1只。
c42901635.spchecks=aux.CreateChecks(Card.IsCode,{42023223,79418928,15502037})
-- 定义特殊召唤素材的候选过滤：该卡位于手牌或墓地，或是表侧表示在场上，可以被除外，且卡名是三种「电磁石战士」之一。
function c42901635.spcostfilter(c)
	return (c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) or c:IsFaceup())
		and c:IsAbleToRemoveAsCost() and c:IsCode(42023223,79418928,15502037)
end
-- 特殊召唤规则的条件判定：确认存在一组α、β、γ可以分别从手牌·场上·墓地选出，且除外这些素材后自己场上仍有足够的怪兽区域空格。
function c42901635.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得符合特殊召唤素材条件的所有候选卡，范围为自己手牌、场上（表侧）和墓地。
	local g=Duel.GetMatchingGroup(c42901635.spcostfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 检查候选卡组中能否选出分别对应α、β、γ的各1只，同时满足aux.mzctcheck（除外素材后场上仍有怪兽区空格）。
	return g:CheckSubGroupEach(c42901635.spchecks,aux.mzctcheck,tp)
end
-- 特殊召唤规则的目标选择函数：让玩家从候选素材中选择α、β、γ各1只作为除外素材，将选出的组保存到效果标签中，成功则返回true。
function c42901635.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得符合特殊召唤素材条件的所有候选卡，范围为自己手牌、场上（表侧）和墓地。
	local g=Duel.GetMatchingGroup(c42901635.spcostfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 弹出提示，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从候选卡组中让玩家选择一组α、β、γ各1只，且该组被除外后场上仍可进行特殊召唤；选择结果用于后续除外。
	local sg=g:SelectSubGroupEach(tp,c42901635.spchecks,true,aux.mzctcheck,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则处理的执行函数：取出之前保存的素材组，将其除外以完成特殊召唤手续。
function c42901635.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选出的三张素材卡以表侧表示除外，除外原因记为特殊召唤（REASON_SPSUMMON）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 定义①效果代价的过滤条件：墓地中的4星以下的「磁石战士」怪兽，且可以作为代价除外。
function c42901635.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价函数：从自己墓地选择1只满足条件的「磁石战士」怪兽除外作为发动代价。
function c42901635.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在至少有1张满足①效果代价条件的怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c42901635.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出提示，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1张满足代价条件的「磁石战士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c42901635.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的代价卡以表侧表示除外，除外原因记为代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的目标选择函数：以对方场上1张卡为对象，并设置破坏效果的操作信息。
function c42901635.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 确认对方场上存在至少1张能够成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出提示，要求玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为本效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理信息：本次效果将破坏1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理函数：取得对象卡，若对象仍与效果关联则将其破坏。
function c42901635.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果取对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因（REASON_EFFECT）破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡被战斗破坏，或被对方的效果破坏，且被破坏前控制权属于这张卡原本的控制者。
function c42901635.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- ②效果特殊召唤对象的过滤条件：除外的自己怪兽，卡名是α、β、γ之一，表侧表示，可以特殊召唤，并且可以成为效果对象。
function c42901635.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(42023223,79418928,15502037)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsCanBeEffectTarget(e)
end
-- ②效果的目标选择函数：从除外的卡中选取α、β、γ各1只作为对象，并检查怪兽区空位及「青眼精灵龙」的限制。
function c42901635.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 取得除外区中满足②效果特殊召唤条件的α、β、γ候选卡组。
	local g=Duel.GetMatchingGroup(c42901635.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	-- 检查自己场上可用怪兽区数量是否大于2，以确保可以同时特殊召唤3只怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and g:CheckSubGroupEach(c42901635.spchecks) end
	-- 弹出提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroupEach(tp,c42901635.spchecks)
	-- 将选出的特殊召唤对象卡组设为当前连锁的对象，使其与效果建立关联。
	Duel.SetTargetCard(sg)
	-- 设置连锁处理信息：本次效果将特殊召唤3只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,3,0,0)
end
-- ②效果处理函数：尝试将对象怪兽全部特殊召唤；若空位不足或受「青眼精灵龙」影响无法同时召唤2只以上，则只特殊召唤能容纳的数量，其余送去墓地。
function c42901635.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上当前可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 从连锁信息中取回②效果选择的对象卡，并过滤出仍然与效果关联的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()<=ft then
		-- 将全部对象怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 弹出提示，要求玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		-- 将因空位不足或其他原因无法同时特殊召唤的剩余对象卡以规则原因送去墓地。
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
