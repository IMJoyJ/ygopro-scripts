--DDD呪血王サイフリート
-- 效果：
-- 调整＋调整以外的「DD」怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡的效果直到下次的准备阶段无效。
-- ②：这张卡被战斗·效果破坏送去墓地的场合发动。自己回复自己场上的「契约书」卡数量×1000基本分。
function c44852429.initial_effect(c)
	-- 为「DDD 咒血王 赛弗里德」添加同调召唤手续：调整＋调整以外的「DD」怪兽1只以上（调整任意，非调整要求为「DD」系列怪兽，数量至少1，上限默认为99）。
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
-- 定义①效果的无效对象筛选函数：只选择场上的魔法·陷阱卡，且该卡在表侧表示时能够被无效化（aux.NegateAnyFilter）。
function c44852429.negfilter(c)
	-- 返回真，当且仅当该卡是魔法·陷阱卡且可以被此效果无效；由于aux.NegateAnyFilter已判定表侧表示且未被无效，因此隐含了表侧表示条件。
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.NegateAnyFilter(c)
end
-- ①效果的发动时点目标选择函数：自己·对方回合可发动，选择场上1张表侧表示的魔法·陷阱卡作为对象，并将无效化信息写入连锁。
function c44852429.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c44852429.negfilter(chkc) end
	-- 在效果发动合法检查（chk==0）时，确认双方场上是否存在至少1张满足条件且可作为效果对象的表侧魔法·陷阱卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c44852429.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给发动玩家显示选择提示，提示内容为“请选择要无效的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家从双方场上选择1张满足条件的表侧魔法·陷阱卡作为此效果的对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c44852429.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本连锁的操作信息：无效化类别，对象为刚选择的卡，数量为1，用于后续其他效果对发动判定的查询。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果处理函数：若对象仍表侧表示、与效果存在联系且能被此效果无效，则将其效果无效化直到下次准备阶段，同时使与对象卡相关的连锁无效；若对象是陷阱怪兽，还将其陷阱怪兽化效果一并无效。
function c44852429.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择作为对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与对象卡相关的连锁也无效化；当对象因变里侧等重置时，该无效连锁也会被重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到下次的准备阶段无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		-- 判断当前是否为准备阶段，以决定无效效果的持续时间：若在准备阶段发动，需要让无效效果持续到下一次准备阶段，因此重置计数为2；否则为1。
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
-- ②效果发动条件：这张卡被战斗或效果破坏并送去墓地的场合发动。
function c44852429.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 定义回复量统计用的过滤函数：对象是自己场上表侧表示的「契约书」卡（系列编号0xae）。
function c44852429.recfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xae)
end
-- ②效果发动时的目标处理函数：发动时无条件通过，统计自己场上表侧「契约书」数量，将目标玩家设为自己，并设置回复操作信息（回复量为数量×1000）。
function c44852429.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 统计自己场上表侧表示的「契约书」卡的数量，用于计算回复值。
	local ct=Duel.GetMatchingGroupCount(c44852429.recfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 把当前连锁的对象玩家设置为自己，表示由自己回复基本分。
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：本连锁包含回复效果，回复量为ct×1000，目标玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*1000)
end
-- ②效果的实际处理函数：取得对象玩家，再次统计该玩家场上表侧「契约书」数量，若数量大于0则回复相应基本分。
function c44852429.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回发动时设置的对象玩家（即回复LP的玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 在效果处理时重新统计该玩家场上表侧「契约书」卡的数量，因为可能在这个连锁处理前数量已经发生变化。
	local ct=Duel.GetMatchingGroupCount(c44852429.recfilter,p,LOCATION_ONFIELD,0,nil)
	if ct>0 then
		-- 让玩家p回复ct×1000基本分，回复来源为效果（REASON_EFFECT）。
		Duel.Recover(p,ct*1000,REASON_EFFECT)
	end
end
