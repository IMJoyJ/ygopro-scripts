--キラーチューン・レッドシール
-- 效果：
-- 「杀手级调整曲·唱片师」＋调整1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升双方墓地的调整数量×300。
-- ②：原本攻击力是1700以下的对方场上的怪兽的等级上升1星。
-- ③：自己·对方的主要阶段，从自己墓地把1只调整除外，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化卡片效果：声明素材卡名并设置混合同调召唤手续（「杀手级调整曲·唱片师」＋调整1只以上），同时注册①攻击力上升、②对方低攻怪兽等级上升、③除外调整无效对方场上表侧表示卡的效果，以及素材检查效果。
function s.initial_effect(c)
	-- 将卡号89392810（「杀手级调整曲·唱片师」）加入这张卡的素材卡名列表，用于同调召唤时识别该指定素材。
	aux.AddMaterialCodeList(c,89392810)
	-- 为这张卡设置同调召唤手续：需要1只「杀手级调整曲·唱片师」（卡号89392810）作为素材组合，其余为调整1只以上，素材总数1～99只。
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsCode,89392810),nil,nil,aux.Tuner(nil),1,99)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升双方墓地的调整数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：原本攻击力是1700以下的对方场上的怪兽的等级上升1星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.lvtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：自己·对方的主要阶段，从自己墓地把1只调整除外，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
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
	-- 素材检查：对应「杀手级调整曲·唱片师」＋调整1只以上的素材条件，若同调素材中包含2只以上调整，则为这张卡追加效果免疫。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck)
	c:RegisterEffect(e4)
end
-- 同调召唤成功时检查素材，若素材中存在至少2只调整怪兽，则给这张卡注册一个效果免疫效果（效果编号21142671），该效果不能被无效或复制，并在回合结束时重置。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- （素材追加效果）使这张卡获得不受对方效果影响（EFFECT_IMMUNE_EFFECT，21142671），不能被无效或复制，持续到回合结束。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 计算攻击力上升值：统计双方墓地中调整怪兽的数量，乘以300。
function s.atkval(e,c)
	-- 统计从控制器视角看双方墓地中满足调整类型的卡片数量，乘以300作为攻击力上升值。
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_TUNER)*300
end
-- 判断怪兽是否原本攻击力在1700以下，用于选择等级上升的对象。
function s.lvtg(e,c)
	return c:GetBaseAttack()<=1700
end
-- ③效果的发动条件：当前处于主要阶段（自己或对方的主要阶段均可发动）。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 筛选可作为发动③效果cost的卡：自己墓地的调整怪兽且可以除外作为cost。
function s.cfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- ③效果的cost：从自己墓地选择1只调整怪兽除外。若chk为0，先确认是否存在可除外的调整；实际支付时提示选择并除外1只调整。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 支付cost前检查：自己墓地是否存在至少1只满足条件的调整怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出提示，要求玩家选择要除外的卡（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只符合条件的调整怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的调整怪兽以表侧表示除外，作为效果的发动cost。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③效果的取对象目标处理：以对方场上1张表侧表示且能被无效的卡为对象，并设置无效效果的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查连锁确认的对象是否合法：对方场上、场上表侧且能被无效化（aux.NegateAnyFilter）。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 发动时检查：对方场上是否存在至少1张表侧表示且能被无效化的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出提示，要求玩家选择要无效的卡（HINTMSG_DISABLE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1张表侧表示且能被无效化的卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次处理的连锁具有CATEGORY_DISABLE，对象为刚刚选择的卡g，数量1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ③效果处理：将对象卡的效果无效直到回合结束时；若对象为陷阱怪兽则额外无效其怪兽化。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理阶段时连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
		-- 将对象卡相关的连锁也一并无效化，直到回合结束时（RESET_TURN_SET）。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- ③效果处理：给对象卡赋予EFFECT_DISABLE状态，使其卡面效果无效化，直到回合结束。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- ③效果处理：给对象卡赋予EFFECT_DISABLE_EFFECT，使其已适用的效果也无效化，直到回合结束。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- ③效果处理：若对象是陷阱怪兽，赋予EFFECT_DISABLE_TRAPMONSTER，将其作为怪兽的效果一并无效，直到回合结束。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
