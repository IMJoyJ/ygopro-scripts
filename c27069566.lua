--電脳堺凰－凰々
-- 效果：
-- 6星怪兽×2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，把这张卡2个超量素材取除，以对方场上1张表侧表示的卡和自己或者对方的墓地1张卡为对象才能发动。那些卡除外。
-- ②：超量召唤的这张卡被对方怪兽的攻击或者对方的效果破坏的场合才能发动。把2只种族·属性相同的「电脑堺」怪兽从卡组特殊召唤。
function c27069566.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加等级为6、需要2只以上怪兽进行XYZ召唤的手续
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
	-- ②：超量召唤的这张卡被对方怪兽的攻击或者对方的效果破坏的场合才能发动。把2只种族·属性相同的「电脑堺」怪兽从卡组特殊召唤。
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
-- 支付1点超量素材作为cost，移除自身2个超量素材
function c27069566.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤满足条件的卡片：正面表示且能除外
function c27069566.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 设置效果的发动条件：确认对方场上存在正面表示且能除外的卡，以及自己或对方墓地存在能除外的卡
function c27069566.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 确认对方场上存在正面表示且能除外的卡
	if chk==0 then return Duel.IsExistingTarget(c27069566.rmfilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 确认自己或对方墓地存在能除外的卡
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张正面表示的卡作为除外对象
	local g1=Duel.SelectTarget(tp,c27069566.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己或对方墓地1张卡作为除外对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理时的操作信息，将要除外的卡组设定为g1
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
end
-- 处理效果的发动，获取连锁中设定的目标卡组并除外
function c27069566.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡组中的卡以正面表示形式除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 设置效果发动的条件：确认该卡是被对方破坏且为XYZ召唤，且破坏方式为效果或战斗
function c27069566.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsPreviousLocation(LOCATION_MZONE)
		-- 确认该卡是被对方效果破坏或被对方怪兽攻击破坏
		and (c:IsReason(REASON_EFFECT) and rp==1-tp or c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
end
-- 过滤满足条件的卡片：属于「电脑堺」卡组且能特殊召唤
function c27069566.spfilter(c,e,tp)
	return c:IsSetCard(0x14e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义用于筛选种族和属性相同的卡组的函数
function c27069566.fselect(g)
	-- 检查卡组中所有卡的种族和属性是否一致
	return aux.SameValueCheck(g,Card.GetRace) and aux.SameValueCheck(g,Card.GetAttribute)
end
-- 设置特殊召唤效果的发动条件：确认场上存在足够的召唤位置，且未被【青眼精灵龙】效果限制，且卡组中存在符合条件的2只卡
function c27069566.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有符合条件的「电脑堺」怪兽
		local g=Duel.GetMatchingGroup(c27069566.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 确认场上存在2个以上的召唤位置
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and g:CheckSubGroup(c27069566.fselect,2,2) end
	-- 设置效果处理时的操作信息，将要特殊召唤的卡组设定为nil，数量为2
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 处理特殊召唤效果的发动，检查是否满足召唤条件
function c27069566.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认场上是否存在足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取卡组中所有符合条件的「电脑堺」怪兽
	local g=Duel.GetMatchingGroup(c27069566.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c27069566.fselect,false,2,2)
	if sg then
		-- 将符合条件的2只卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
