--DDD呪血王サイフリート
-- 效果：
-- 调整＋调整以外的「DD」怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡的效果直到下次的准备阶段无效。
-- ②：这张卡被战斗·效果破坏送去墓地的场合发动。自己回复自己场上的「契约书」卡数量×1000基本分。
function c44852429.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的「DD」怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0xaf),1)
	c:EnableReviveLimit()
	-- ①：自己·对方回合，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡的效果直到下次的准备阶段无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44852429,0))  --"魔陷无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,44852429)
	e1:SetTarget(c44852429.negtg)
	e1:SetOperation(c44852429.negop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合发动。自己回复自己场上的「契约书」卡数量×1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44852429,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c44852429.reccon)
	e2:SetTarget(c44852429.rectg)
	e2:SetOperation(c44852429.recop)
	c:RegisterEffect(e2)
end
-- 定义用于筛选魔法或陷阱卡的过滤函数
function c44852429.negfilter(c)
	-- 筛选满足条件的魔法或陷阱卡，包括表侧表示且未被无效的卡
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.NegateAnyFilter(c)
end
-- 设置效果目标，选择场上1张满足条件的魔法或陷阱卡
function c44852429.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c44852429.negfilter(chkc) end
	-- 检查是否有满足条件的魔法或陷阱卡可作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c44852429.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的魔法或陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1张满足条件的魔法或陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c44852429.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，标记将要使目标卡效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 处理效果的发动，使目标卡效果无效并设置其在下次准备阶段重置
function c44852429.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与目标卡相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 创建一个永续效果，使目标卡效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		-- 根据当前阶段设置效果的重置条件
		if Duel.GetCurrentPhase()==PHASE_STANDBY then
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
		else
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY)
		end
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e3)
		end
	end
end
-- 判断此卡是否因战斗或效果破坏而送去墓地
function c44852429.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 定义用于筛选「契约书」卡的过滤函数
function c44852429.recfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xae)
end
-- 设置回复效果的目标和数量
function c44852429.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算场上满足条件的「契约书」卡数量
	local ct=Duel.GetMatchingGroupCount(c44852429.recfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 设置效果操作的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果操作信息，标记将要回复LP
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*1000)
end
-- 处理回复效果，根据场上「契约书」卡数量回复LP
function c44852429.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算目标玩家场上满足条件的「契约书」卡数量
	local ct=Duel.GetMatchingGroupCount(c44852429.recfilter,p,LOCATION_ONFIELD,0,nil)
	if ct>0 then
		-- 使目标玩家回复相应数量的基本分
		Duel.Recover(p,ct*1000,REASON_EFFECT)
	end
end
