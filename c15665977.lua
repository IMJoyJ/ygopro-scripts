--キラーチューン・レッドシール
-- 效果：
-- 「杀手级调整曲·唱片师」＋调整1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升双方墓地的调整数量×300。
-- ②：原本攻击力是1700以下的对方场上的怪兽的等级上升1星。
-- ③：自己·对方的主要阶段，从自己墓地把1只调整除外，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化效果函数，设置融合/同调召唤手续、攻击力提升、等级提升、效果无效化等效果
function s.initial_effect(c)
	-- 为该卡添加允许作为融合素材的卡牌代码为89392810（杀手级调整曲·唱片师）
	aux.AddMaterialCodeList(c,89392810)
	-- 设置该卡的同调召唤手续，要求必须包含一张89392810的卡和至少1只调整
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsCode,89392810),nil,nil,aux.Tuner(nil),1,99)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升双方墓地的调整数量×300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：原本攻击力是1700以下的对方场上的怪兽的等级上升1星
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.lvtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方的主要阶段，从自己墓地把1只调整除外，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- ③：自己·对方的主要阶段，从自己墓地把1只调整除外，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck)
	c:RegisterEffect(e4)
end
-- 检查该卡是否使用了至少2只调整作为素材，若是则赋予其特殊效果21142671
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 赋予该卡特殊效果21142671，使其在特定条件下获得额外效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 计算双方墓地调整数量并乘以300作为攻击力提升值
function s.atkval(e,c)
	-- 检索双方墓地的调整数量
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_TUNER)*300
end
-- 判断目标怪兽的原本攻击力是否小于等于1700
function s.lvtg(e,c)
	return c:GetBaseAttack()<=1700
end
-- 判断是否处于主要阶段
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段
	return Duel.IsMainPhase()
end
-- 过滤满足类型为调整且可作为除外费用的卡
function s.cfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- 设置效果发动的费用，从墓地选择1只调整除外
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动费用条件，即墓地是否存在至少1只调整
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的调整
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的调整从墓地除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果发动的目标选择，选择对方场上1张表侧表示卡
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断目标是否为对方场上的卡且可被无效化
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择1张满足条件的对方场上卡
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，确定要处理的卡数量和分类为CATEGORY_DISABLE
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 执行效果无效化操作，使目标卡的效果在回合结束前无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使目标卡相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标卡的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果在回合结束前无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 若目标卡为陷阱怪兽，则使其陷阱怪兽效果无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
