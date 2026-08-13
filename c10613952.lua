--神聖騎士王アルトリウス
-- 效果：
-- 5星「圣骑士」怪兽×2
-- ①：这张卡超量召唤成功时，以自己墓地的「圣剑」装备魔法卡最多3种类为对象才能发动。作为对象的卡给这张卡装备。
-- ②：1回合1次，把这张卡1个超量素材取除，以这张卡以外的场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ③：这张卡从场上送去墓地的场合，以自己墓地1只4星以上的「圣骑士」怪兽为对象才能发动。那只怪兽特殊召唤。
function c10613952.initial_effect(c)
	-- 为这张卡添加超量召唤手续：素材为2只等级5的「圣骑士」怪兽（字段0x107a）。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x107a),5,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功时，以自己墓地的「圣剑」装备魔法卡最多3种类为对象才能发动。作为对象的卡给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10613952,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c10613952.condition)
	e1:SetTarget(c10613952.target)
	e1:SetOperation(c10613952.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以这张卡以外的场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10613952,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c10613952.descost)
	e2:SetTarget(c10613952.destg)
	e2:SetOperation(c10613952.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合，以自己墓地1只4星以上的「圣骑士」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10613952,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c10613952.spcon)
	e3:SetTarget(c10613952.sptg)
	e3:SetOperation(c10613952.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：判定此卡是否以超量召唤方式特殊召唤成功。
function c10613952.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- ①效果的装备对象过滤器：筛选自己墓地的「圣剑」装备魔法卡，要求能成为效果对象、场上无同名卡且能装备给此卡。
function c10613952.filter(c,e,tp,ec)
	return c:IsSetCard(0x207a) and c:IsCanBeEffectTarget(e) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(ec)
end
-- ①效果的目标选择处理：发动时需确保魔陷区有空位且墓地存在符合条件的「圣剑」，然后从其中选择1-3张卡名不同的卡作为装备对象。
function c10613952.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c10613952.filter(chkc,e,tp,e:GetHandler()) end
	-- ①效果的发动检查：自己魔陷区必须存在至少1个空格，用于装备选中的魔法卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- ①效果的发动检查：墓地存在至少1张满足过滤条件的「圣剑」装备魔法卡。
		and Duel.IsExistingMatchingCard(c10613952.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler()) end
	-- 获取自己魔陷区的可用空格数，用于限制最多可选择的装备卡数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 获取自己墓地中所有满足条件的「圣剑」装备魔法卡作为候选组。
	local g=Duel.GetMatchingGroup(c10613952.filter,tp,LOCATION_GRAVE,0,nil,e,tp,e:GetHandler())
	-- 向玩家显示选择提示：请选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家从候选组中选择1至min(空格数,3)张卡，且所选卡的卡名互不相同（对应“最多3种类”）。
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,3))
	-- 将选中的卡组设为该连锁的取对象目标。
	Duel.SetTargetCard(g1)
	-- 设置操作信息：这些卡会离开墓地（被装备），用于效果发动时点判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,g1:GetCount(),0,0)
end
-- ①效果处理：将发动时选中的、仍与效果关联的「圣剑」装备魔法卡依次装备给此卡。
function c10613952.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取魔陷区空格数，以确认当前仍有足够空间进行装备。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 获取连锁处理时选中的目标卡，并过滤出仍然与效果关联的卡（如已离场则排除）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if ft<g:GetCount() then return end
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local tc=g:GetFirst()
	while tc do
		-- 将目标装备魔法卡装备给此卡，以表侧表示装备并分步处理。
		Duel.Equip(tp,tc,c,true,true)
		tc=g:GetNext()
	end
	-- 完成装备步骤，触发装备成功时的时点。
	Duel.EquipComplete()
end
-- ②效果的发动代价：检查并取除此卡的1个超量素材（作为COST）。
function c10613952.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的目标选择处理：选择此卡以外的场上1只怪兽作为破坏对象。
function c10613952.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- ②效果的发动检查：场上存在至少1只此卡以外的怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 向玩家显示选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1只场上怪兽，并设定为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	-- 设置操作信息：该对象将被破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：将对象怪兽破坏。
function c10613952.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象（唯一目标怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 用效果破坏该怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ③效果的发动条件：判定此卡是从场上区域送去墓地。
function c10613952.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ③效果的特召对象过滤器：筛选自己墓地中4星以上的「圣骑士」怪兽，且满足特殊召唤条件。
function c10613952.spfilter(c,e,tp)
	return c:IsSetCard(0x107a) and c:IsLevelAbove(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的目标选择处理：检查怪兽区空位和墓地对象，并选择1只满足条件的「圣骑士」怪兽作为特殊召唤对象。
function c10613952.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10613952.spfilter(chkc,e,tp) end
	-- ③效果的发动检查：自己怪兽区必须存在至少1个空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- ③效果的发动检查：墓地存在至少1只满足特殊召唤条件的「圣骑士」怪兽。
		and Duel.IsExistingTarget(c10613952.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从墓地选择1只符合条件的「圣骑士」怪兽，并设定为效果对象。
	local g=Duel.SelectTarget(tp,c10613952.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：该对象将被特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：将对象怪兽特殊召唤到自己场上。
function c10613952.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象（唯一目标怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
