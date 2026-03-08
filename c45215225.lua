--ファーニマル・エンジェル
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以自己墓地1只「毛绒动物」怪兽或者「锋利小鬼」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：把这张卡解放，以自己墓地1只「魔玩具」融合怪兽为对象才能发动。选1张手卡丢弃，作为对象的怪兽特殊召唤。
function c45215225.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：以自己墓地1只「毛绒动物」怪兽或者「锋利小鬼」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,45215225)
	e1:SetTarget(c45215225.sptg)
	e1:SetOperation(c45215225.spop)
	c:RegisterEffect(e1)
	-- ①：把这张卡解放，以自己墓地1只「魔玩具」融合怪兽为对象才能发动。选1张手卡丢弃，作为对象的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,45215226)
	e2:SetCost(c45215225.spcost)
	e2:SetTarget(c45215225.sptg2)
	e2:SetOperation(c45215225.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，判断墓地中的怪兽是否为「毛绒动物」或「锋利小鬼」且可以特殊召唤
function c45215225.filter(c,e,tp)
	return c:IsSetCard(0xa9,0xc3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置灵摆效果的目标选择函数，判断是否能选择满足条件的墓地怪兽作为对象
function c45215225.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45215225.filter(chkc,e,tp) end
	-- 判断是否满足发动条件：墓地存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c45215225.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判断是否满足发动条件：场上存在空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为对象
	local g=Duel.SelectTarget(tp,c45215225.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理灵摆效果的发动，将目标怪兽特殊召唤，并设置不能特殊召唤非融合怪兽的效果
function c45215225.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建并注册一个永续效果，禁止玩家在回合结束前从额外卡组特殊召唤非融合怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c45215225.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家的全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否为非融合怪兽且在额外卡组，用于限制特殊召唤
function c45215225.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 设置怪兽效果的费用函数，判断是否可以解放自身作为费用
function c45215225.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为效果的费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，判断墓地中的怪兽是否为「魔玩具」融合怪兽且可以特殊召唤
function c45215225.filter2(c,e,tp)
	return c:IsSetCard(0xad) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置怪兽效果的目标选择函数，判断是否能选择满足条件的墓地融合怪兽作为对象
function c45215225.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45215225.filter2(chkc,e,tp) end
	-- 判断是否满足发动条件：手牌数量大于0且场上存在空位
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 判断是否满足发动条件：墓地存在符合条件的融合怪兽
		and Duel.IsExistingTarget(c45215225.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地融合怪兽作为对象
	local g=Duel.SelectTarget(tp,c45215225.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定丢弃手卡的数量
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置连锁操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理怪兽效果的发动，丢弃1张手卡并特殊召唤目标融合怪兽
function c45215225.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 丢弃1张手卡作为效果的代价
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)==0 then return end
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标融合怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
