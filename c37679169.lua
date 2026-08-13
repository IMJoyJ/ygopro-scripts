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
-- 定义过滤函数：筛选出属于「星际仙踪」系列、是怪兽卡且可以作为代价送去墓地的卡。
function c37679169.cfilter(c)
	return c:IsSetCard(0xd2) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果①的代价处理：从卡组选择1只符合条件的「星际仙踪」怪兽送去墓地作为代价，并将其等级记录到效果标签中供后续下降数值使用。
function c37679169.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认卡组中存在至少1只满足条件的「星际仙踪」怪兽可以作为代价送去墓地，否则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c37679169.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 弹出“请选择要送去墓地的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的「星际仙踪」怪兽作为代价候选。
	local g=Duel.SelectMatchingCard(tp,c37679169.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的怪兽作为代价送去墓地。
	Duel.SendtoGrave(tc,REASON_COST)
	e:SetLabel(tc:GetLevel())
end
-- 效果①的取对象处理：选择场上1只表侧表示怪兽作为对象，同时进行是否存在合法对象的检测。
function c37679169.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) end
	-- 目标检测：确认场上存在至少1只表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出“请选择效果的对象”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只场上的表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果①处理：根据记录的被送去墓地的怪兽等级，使对象怪兽的攻击力·守备力下降相应数值（等级×100）。
function c37679169.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local lv=e:GetLabel()
		-- 作为对象的怪兽的攻击力·守备力下降因为这个效果发动而送去墓地的怪兽的等级×100。
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
-- 效果②的发动条件：这张卡被战斗或效果破坏并送去墓地时满足条件。
function c37679169.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果②的代价处理：将墓地中的这张卡除外作为发动代价。
function c37679169.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() and c:IsLocation(LOCATION_GRAVE) end
	-- 将墓地中的这张卡以表侧表示除外，作为发动代价。
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
-- 定义特殊召唤的过滤函数：筛选属于「星际仙踪」系列、4星以下且可以被特殊召唤的怪兽。
function c37679169.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的目标检测与设定：确认自己场上有空位且卡组中存在符合条件的「星际仙踪」怪兽，并设置特殊召唤的操作信息。
function c37679169.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己主要怪兽区是否有空位，确保可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测卡组中是否存在至少1只满足条件的「星际仙踪」怪兽可以特殊召唤。
		and Duel.IsExistingMatchingCard(c37679169.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次效果将进行特殊召唤的操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②处理：从卡组选择1只符合条件的「星际仙踪」怪兽特殊召唤到自己场上。
function c37679169.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区有空位，若没有空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出“请选择要特殊召唤的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「星际仙踪」怪兽用于特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c37679169.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
