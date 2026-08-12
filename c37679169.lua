--Kozmo－デルタシャトル
-- 效果：
-- ①：1回合1次，从卡组把1只「星际仙踪」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动。作为对象的怪兽的攻击力·守备力下降因为这个效果发动而送去墓地的怪兽的等级×100。
-- ②：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只4星以下的「星际仙踪」怪兽特殊召唤。
function c37679169.initial_effect(c)
	-- ①：1回合1次，从卡组把1只「星际仙踪」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动。作为对象的怪兽的攻击力·守备力下降因为这个效果发动而送去墓地的怪兽的等级×100。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(c37679169.adcost)
	e1:SetTarget(c37679169.adtg)
	e1:SetOperation(c37679169.adop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只4星以下的「星际仙踪」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(c37679169.spcon)
	e2:SetCost(c37679169.spcost)
	e2:SetTarget(c37679169.sptg)
	e2:SetOperation(c37679169.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检测卡组中是否存在满足条件的「星际仙踪」怪兽（怪兽卡且能作为cost送去墓地）
function c37679169.cfilter(c)
	return c:IsSetCard(0xd2) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果处理：从卡组选择1只「星际仙踪」怪兽送去墓地作为cost，并记录其等级
function c37679169.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足cost条件：卡组中是否存在至少1张符合条件的「星际仙踪」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c37679169.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张符合条件的「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(tp,c37679169.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的卡送去墓地作为cost
	Duel.SendtoGrave(tc,REASON_COST)
	e:SetLabel(tc:GetLevel())
end
-- 效果处理：选择场上1只表侧表示怪兽作为对象
function c37679169.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查是否满足选择对象条件：场上是否存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使对象怪兽的攻击力和守备力下降
function c37679169.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local lv=e:GetLabel()
		-- 创建一个使对象怪兽攻击力下降的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-100*lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 效果处理：判断此卡是否因战斗或效果破坏而送去墓地
function c37679169.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果处理：将此卡从墓地除外作为cost
function c37679169.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() and c:IsLocation(LOCATION_GRAVE) end
	-- 将此卡从墓地除外作为cost
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于检测卡组中是否存在满足条件的4星以下「星际仙踪」怪兽（可特殊召唤）
function c37679169.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：判断是否满足特殊召唤条件
function c37679169.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张符合条件的「星际仙踪」怪兽
		and Duel.IsExistingMatchingCard(c37679169.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1张「星际仙踪」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的「星际仙踪」怪兽并特殊召唤
function c37679169.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(tp,c37679169.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
