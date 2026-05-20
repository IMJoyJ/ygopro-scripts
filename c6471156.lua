--パフォーム・パペット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把1只「机关傀儡」怪兽除外才能发动。自己场上的全部怪兽的等级直到回合结束时变成和除外的怪兽相同等级。
-- ②：自己场上的表侧表示的「机关傀儡」怪兽被战斗或者对方的效果破坏送去墓地的场合，以除外的1只自己的「机关傀儡」怪兽为对象才能发动。那只怪兽特殊召唤。
function c6471156.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从自己墓地把1只「机关傀儡」怪兽除外才能发动。自己场上的全部怪兽的等级直到回合结束时变成和除外的怪兽相同等级。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,6471156)
	e2:SetCost(c6471156.lvcost)
	e2:SetOperation(c6471156.lvop)
	c:RegisterEffect(e2)
	-- ②：自己场上的表侧表示的「机关傀儡」怪兽被战斗或者对方的效果破坏送去墓地的场合，以除外的1只自己的「机关傀儡」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,6471157)
	e3:SetCondition(c6471156.spcon)
	e3:SetTarget(c6471156.sptg)
	e3:SetOperation(c6471156.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选自己墓地中可以作为代价除外，且其等级与场上某只怪兽不同的「机关傀儡」怪兽
function c6471156.cfilter(c,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsSetCard(0x1083) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查自己场上是否存在等级与该墓地怪兽不同的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c6471156.lvfilter,tp,LOCATION_MZONE,0,1,nil,lv)
end
-- 过滤函数：筛选自己场上表侧表示且等级与指定等级不同的怪兽
function c6471156.lvfilter(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(0) and not c:IsLevel(lv)
end
-- 效果①的代价处理：从自己墓地把1只「机关傀儡」怪兽除外，并记录其等级
function c6471156.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己墓地是否存在满足除外代价且能使场上怪兽等级发生变化的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c6471156.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的「机关傀儡」怪兽
	local g=Duel.SelectMatchingCard(tp,c6471156.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- 效果①的效果处理：使自己场上全部怪兽的等级直到回合结束时变成与除外怪兽相同
function c6471156.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	-- 获取自己场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c6471156.lvfilter,tp,LOCATION_MZONE,0,nil,0)
	local lc=g:GetFirst()
	while lc do
		-- 等级直到回合结束时变成和除外的怪兽相同等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		lc:RegisterEffect(e1)
		lc=g:GetNext()
	end
end
-- 过滤函数：筛选自己场上因战斗或对方效果破坏并送去墓地的表侧表示「机关傀儡」怪兽
function c6471156.cfilter2(c,tp)
	return c:IsSetCard(0x1083) and c:IsReason(REASON_DESTROY)
		and (c:IsReason(REASON_BATTLE) or c:GetReasonPlayer()==1-tp and c:IsReason(REASON_DESTROY))
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果②的发动条件：自己场上的表侧表示「机关傀儡」怪兽被战斗或对方效果破坏送去墓地
function c6471156.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c6471156.cfilter2,1,nil,tp)
end
-- 过滤函数：筛选除外的可以特殊召唤的表侧表示「机关傀儡」怪兽
function c6471156.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1083) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向与检查：以除外的1只自己的「机关傀儡」怪兽为对象才能发动
function c6471156.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c6471156.spfilter(chkc,e,tp) end
	-- 在发动阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在可以特殊召唤的「机关傀儡」怪兽
		and Duel.IsExistingTarget(c6471156.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外的1只自己的「机关傀儡」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c6471156.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的怪兽特殊召唤
function c6471156.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
