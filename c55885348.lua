--Kozmo－ダークシミター
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ②：这张卡不会成为对方的效果的对象。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只7星以下的「星际仙踪」怪兽特殊召唤。
function c55885348.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55885348,0))  --"破坏怪兽"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(c55885348.destg)
	e1:SetOperation(c55885348.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	-- 设置不能成为对方卡的效果的对象（过滤函数判定对方玩家发动的效果）
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只7星以下的「星际仙踪」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(55885348,1))  --"从卡组把「星际仙踪」怪兽特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c55885348.spcon)
	-- 设置发动成本为把墓地的这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c55885348.sptg)
	e4:SetOperation(c55885348.spop)
	c:RegisterEffect(e4)
end
-- 效果①的发动准备与目标选择（检查场上是否存在怪兽并将其设为效果对象）
function c55885348.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在至少1只可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的效果处理（破坏作为对象的怪兽）
function c55885348.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果③的发动条件判定（此卡因战斗或效果被破坏）
function c55885348.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤卡组中7星以下的「星际仙踪」怪兽且该怪兽可以特殊召唤
function c55885348.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备（检查怪兽区域空位及卡组中是否存在符合条件的怪兽）
function c55885348.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组中是否存在至少1只符合条件的「星际仙踪」怪兽
		and Duel.IsExistingMatchingCard(c55885348.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理（从卡组特殊召唤1只7星以下的「星际仙踪」怪兽）
function c55885348.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只符合条件的「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(tp,c55885348.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
