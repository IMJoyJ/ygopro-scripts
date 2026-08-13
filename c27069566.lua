--電脳堺凰－凰々
-- 效果：
-- 6星怪兽×2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，把这张卡2个超量素材取除，以对方场上1张表侧表示的卡和自己或者对方的墓地1张卡为对象才能发动。那些卡除外。
-- ②：超量召唤的这张卡被对方怪兽的攻击或者对方的效果破坏的场合才能发动。把2只种族·属性相同的「电脑堺」怪兽从卡组特殊召唤。
function c27069566.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加超量召唤手续：可用任意2只以上等级6的怪兽作为超量素材（最多99张）进行超量召唤。
	aux.AddXyzProcedure(c,nil,6,2,nil,nil,99)
	-- ①：1回合1次，把这张卡2个超量素材取除，以对方场上1张表侧表示的卡和自己或者对方的墓地1张卡为对象才能发动。那些卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27069566,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c27069566.rmcost)
	e1:SetTarget(c27069566.rmtg)
	e1:SetOperation(c27069566.rmop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：超量召唤的这张卡被对方怪兽的攻击或者对方的效果破坏的场合才能发动。把2只种族·属性相同的「电脑堺」怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27069566,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,27069566)
	e2:SetCondition(c27069566.spcon)
	e2:SetTarget(c27069566.sptg)
	e2:SetOperation(c27069566.spop)
	c:RegisterEffect(e2)
end
-- 代价函数：效果发动确认时检查自己能否移除2个超量素材作为代价；发动时实际移除自己2个超量素材。
function c27069566.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤函数：选择对方场上表侧表示且能够被除外的卡。
function c27069566.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 目标设定：效果发动时确认能否选择对方场上1张表侧表示可除外的卡以及双方墓地1张可除外的卡作为对象；并在合法时进入选择。
function c27069566.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少1张表侧表示且能够被除外的卡，作为取对象候选。
	if chk==0 then return Duel.IsExistingTarget(c27069566.rmfilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查双方墓地是否存在至少1张能够被除外的卡，作为另一个取对象候选。
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 向玩家发送选择提示，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张表侧表示且可除外的卡作为对象，并建立连锁对象联系。
	local g1=Duel.SelectTarget(tp,c27069566.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 再次发送选择提示，用于选择墓地中的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己或对方墓地1张可除外的卡作为对象，并建立连锁对象联系。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：声明本连锁将执行“除外”操作，对象为已选择的2张卡（对方场上1张+墓地1张），数量为2。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
end
-- 效果处理：取得连锁对象中与效果仍有关联的卡，将其以表侧表示除外。
function c27069566.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中获取所有对象卡，并筛选出仍然与效果e相关（未被无效联系或未离场）的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选出的对象卡以表侧表示除外，除外原因为效果。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- ②效果发动条件：这张卡原本是自己控制、以超量召唤方式出场且在怪兽区域，被对方怪兽攻击或对方效果破坏。
function c27069566.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsPreviousLocation(LOCATION_MZONE)
		-- 具体判断破坏来源：若为效果破坏，则破坏效果的控制者为对方；若为战斗破坏，则攻击怪兽为对方控制的怪兽。
		and (c:IsReason(REASON_EFFECT) and rp==1-tp or c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
end
-- 定义卡组检索的过滤条件：持有「电脑堺」字段且能够被效果特殊召唤的怪兽。
function c27069566.spfilter(c,e,tp)
	return c:IsSetCard(0x14e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义子组选择条件：从候选组中选出2张卡，要求它们的种族相同且属性相同。
function c27069566.fselect(g)
	-- 通过位掩码交集检查所选卡是否具有共同的种族和共同的属性。
	return aux.SameValueCheck(g,Card.GetRace) and aux.SameValueCheck(g,Card.GetAttribute)
end
-- ②效果的目标与发动条件检测：检查自己怪兽区域是否有至少2个空位、场上不存在青眼精灵龙的限制效果，且卡组中存在2只符合条件的「电脑堺」怪兽；合法后设置特殊召唤的操作信息。
function c27069566.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得卡组中所有满足特殊召唤条件的「电脑堺」怪兽，作为候选组。
		local g=Duel.GetMatchingGroup(c27069566.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 确认自己场上是否有至少2个可用怪兽区域，以满足同时特殊召唤2只怪兽。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and g:CheckSubGroup(c27069566.fselect,2,2) end
	-- 设置操作信息：声明本连锁将进行特殊召唤，数量为2，来源为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果处理：若自己场上可用区域不足2个或青眼精灵龙效果生效中则直接终止；否则从卡组选择2只相同种族·属性的「电脑堺」怪兽进行特殊召唤。
function c27069566.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上可用怪兽区域少于2个，则无法进行特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时重新获取卡组中符合条件的「电脑堺」怪兽候选组。
	local g=Duel.GetMatchingGroup(c27069566.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c27069566.fselect,false,2,2)
	if sg then
		-- 将选中的2只怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
