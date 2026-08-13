--慈愛の賢者－シエラ
-- 效果：
-- 这个卡名在规则上也当作「闪刀」卡使用。这个卡名的①②③的效果1回合各能使用1次。
-- ①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
-- ②：从自己墓地把1张魔法卡除外才能发动。这张卡的控制权移给对方，从自己墓地选1只「闪刀姬」怪兽特殊召唤。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，以除外的1张自己的「闪刀」魔法卡为对象才能发动。那张卡加入手卡。
function c34456146.initial_effect(c)
	-- 这个卡名的①的效果1回合各能使用1次。①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34456146,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,34456146)
	e1:SetCost(c34456146.spcost)
	e1:SetTarget(c34456146.sptg)
	e1:SetOperation(c34456146.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合各能使用1次。②：从自己墓地把1张魔法卡除外才能发动。这张卡的控制权移给对方，从自己墓地选1只「闪刀姬」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34456146,1))
	e2:SetCategory(CATEGORY_CONTROL+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,34456147)
	e2:SetCost(c34456146.ctcost)
	e2:SetTarget(c34456146.cttg)
	e2:SetOperation(c34456146.ctop)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合各能使用1次。③：这张卡被战斗·效果破坏送去墓地的场合，以除外的1张自己的「闪刀」魔法卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34456146,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,34456148)
	e3:SetCondition(c34456146.thcon)
	e3:SetTarget(c34456146.thtg)
	e3:SetOperation(c34456146.thop)
	c:RegisterEffect(e3)
end
-- 代价过滤：这张卡是魔法卡且可以作为代价丢弃。
function c34456146.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 代价：展示并让玩家从手卡丢弃1张满足costfilter的魔法卡；chk阶段只检查是否存在。
function c34456146.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在1张魔法卡可以作为代价丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(c34456146.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃：玩家从手卡选1张魔法卡，以代价+丢弃的理由送去墓地。
	Duel.DiscardHand(tp,c34456146.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 发动条件：自己主要怪兽区有空位，且这张卡本身能够被特殊召唤。
function c34456146.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设定操作信息：本次特殊召唤的对象确定为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤处理：若这张卡仍与效果关联，则将其表侧攻击表示特殊召唤到自己场上。
function c34456146.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到持有者（发动者）场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 除外代价过滤：该卡是魔法卡且可以作为代价除外。
function c34456146.rmfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- ②的代价：从自己墓地选1张魔法卡除外；chk阶段只检查是否存在满足条件的卡。
function c34456146.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在1张可以作为代价除外的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c34456146.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1张满足rmfilter的魔法卡。
	local g=Duel.SelectMatchingCard(tp,c34456146.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的魔法卡以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤对象过滤：必须是「闪刀姬」怪兽，且能够被当前效果特殊召唤。
function c34456146.spfilter(c,e,tp)
	return c:IsSetCard(0x1115) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动条件：这张卡可以变更控制权，自己场上有空位（考虑到这张卡转给对方后），且自己墓地存在可特殊召唤的「闪刀姬」怪兽。
function c34456146.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsControlerCanBeChanged()
		-- 确认这张卡的控制权转移后，自己场上仍有足够的怪兽区空格来特殊召唤墓地怪兽。
		and Duel.GetMZoneCount(tp,c)>0
		-- 确认自己墓地存在1只满足特殊召唤条件的「闪刀姬」怪兽。
		and Duel.IsExistingMatchingCard(c34456146.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设定操作信息：本次效果包含改变控制权，对象为这张卡。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,c,1,0,0)
	-- 设定操作信息：本次效果包含特殊召唤，对象从自己墓地选择，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②的效果处理：若卡片仍关联且成功转移控制权、自己场上也有空位，则选1只墓地「闪刀姬」怪兽特殊召唤到自己场上；同时受到王家长眠之谷影响的怪兽不能选。
function c34456146.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡已经与效果失去联系，或者控制权转移失败，或者自己场上没有空位，则效果不处理。
	if not c:IsRelateToEffect(e) or Duel.GetControl(c,1-tp)==0 or Duel.GetMZoneCount(tp,c)==0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只「闪刀姬」怪兽，过滤时排除因王家长眠之谷而不能特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c34456146.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的「闪刀姬」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 触发条件：这张卡被战斗或效果破坏并送去墓地。
function c34456146.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 对象过滤：除外的自己的表侧表示的「闪刀」魔法卡，且可以加入手卡。
function c34456146.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ③的发动条件与选对象：以除外的1张自己的「闪刀」魔法卡为对象；chk阶段确认存在满足条件的对象。
function c34456146.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c34456146.thfilter(chkc) end
	-- 检查除外区是否存在1张自己的表侧「闪刀」魔法卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c34456146.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择除外的1张自己的「闪刀」魔法卡作为效果对象。
	local g=Duel.SelectTarget(tp,c34456146.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设定操作信息：本次效果处理将对象卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果处理：将选中的「闪刀」魔法卡加入持有者的手卡。
function c34456146.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送去持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
