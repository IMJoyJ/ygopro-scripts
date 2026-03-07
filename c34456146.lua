--慈愛の賢者－シエラ
-- 效果：
-- 这个卡名在规则上也当作「闪刀」卡使用。这个卡名的①②③的效果1回合各能使用1次。
-- ①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
-- ②：从自己墓地把1张魔法卡除外才能发动。这张卡的控制权移给对方，从自己墓地选1只「闪刀姬」怪兽特殊召唤。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，以除外的1张自己的「闪刀」魔法卡为对象才能发动。那张卡加入手卡。
function c34456146.initial_effect(c)
	-- ①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
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
	-- ②：从自己墓地把1张魔法卡除外才能发动。这张卡的控制权移给对方，从自己墓地选1只「闪刀姬」怪兽特殊召唤。
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
	-- ③：这张卡被战斗·效果破坏送去墓地的场合，以除外的1张自己的「闪刀」魔法卡为对象才能发动。那张卡加入手卡。
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
-- 过滤函数，用于判断手卡中是否存在可丢弃的魔法卡
function c34456146.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 检查手卡中是否存在满足条件的魔法卡，若存在则丢弃1张
function c34456146.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c34456146.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡丢弃1张满足条件的魔法卡
	Duel.DiscardHand(tp,c34456146.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置特殊召唤的条件，检查是否有足够的怪兽区域和是否可以特殊召唤
function c34456146.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将卡片特殊召唤到场上
function c34456146.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于判断墓地中是否存在可除外的魔法卡
function c34456146.rmfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 检查墓地中是否存在满足条件的魔法卡，若存在则选择并除外1张
function c34456146.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c34456146.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张墓地魔法卡
	local g=Duel.SelectMatchingCard(tp,c34456146.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于判断墓地中是否存在可特殊召唤的「闪刀姬」怪兽
function c34456146.spfilter(c,e,tp)
	return c:IsSetCard(0x1115) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置控制权转移和特殊召唤的条件，检查是否可以改变控制权、是否有足够的怪兽区域和是否存在可特殊召唤的怪兽
function c34456146.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsControlerCanBeChanged()
		-- 检查是否有足够的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查墓地中是否存在可特殊召唤的「闪刀姬」怪兽
		and Duel.IsExistingMatchingCard(c34456146.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置改变控制权的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,c,1,0,0)
	-- 设置特殊召唤怪兽的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行控制权转移和特殊召唤操作，将卡片控制权转移给对方并特殊召唤怪兽
function c34456146.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡片是否有效、是否成功改变控制权、是否有足够的怪兽区域
	if not c:IsRelateToEffect(e) or Duel.GetControl(c,1-tp)==0 or Duel.GetMZoneCount(tp,c)==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只「闪刀姬」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c34456146.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断卡片被战斗或效果破坏送入墓地的条件
function c34456146.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤函数，用于判断除外区中是否存在满足条件的「闪刀」魔法卡
function c34456146.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置效果处理的目标，检查是否存在满足条件的除外魔法卡并选择
function c34456146.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c34456146.thfilter(chkc) end
	-- 检查是否存在满足条件的除外魔法卡
	if chk==0 then return Duel.IsExistingTarget(c34456146.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张除外魔法卡
	local g=Duel.SelectTarget(tp,c34456146.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置将卡加入手牌的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行将卡加入手牌的操作
function c34456146.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
