--S－Force ジャスティファイ
-- 效果：
-- 包含「治安战警队」怪兽的效果怪兽3只
-- 自己不能在这张卡所连接区让怪兽出现。这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。那之后，可以让那只对方怪兽向作为这张卡所连接区的对方的怪兽区域移动。
-- ②：这张卡攻击的伤害步骤开始时才能发动。这张卡所连接区的怪兽全部除外。
function c35334193.initial_effect(c)
	-- 为「治安战警队 正名者」添加连接召唤手续：需要包含「治安战警队」怪兽的效果怪兽3只作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3,3,c35334193.lcheck)
	c:EnableReviveLimit()
	-- 自己不能在这张卡所连接区让怪兽出现。（永续效果：此卡在场上时，自己不能把怪兽出到其连接区）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_USE_MZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c35334193.zonelimit)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。那之后，可以让那只对方怪兽向作为这张卡所连接区的对方的怪兽区域移动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35334193,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,35334193)
	e2:SetTarget(c35334193.distg)
	e2:SetOperation(c35334193.disop)
	c:RegisterEffect(e2)
	-- ②：这张卡攻击的伤害步骤开始时才能发动。这张卡所连接区的怪兽全部除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35334193,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(c35334193.rmcon)
	e3:SetTarget(c35334193.rmtg)
	e3:SetOperation(c35334193.rmop)
	c:RegisterEffect(e3)
end
-- 连接素材条件：素材中至少要有1只卡名包含「治安战警队」的怪兽（0x156为该系列的setcode）。
function c35334193.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x156)
end
-- 限制自己出怪兽的区域：返回除该卡连接区以外的可用主要怪兽区域（0x7f007f为全怪兽区，按位取反连接区后禁用这些格子）。
function c35334193.zonelimit(e)
	return 0x7f007f & ~e:GetHandler():GetLinkedZone()
end
-- ①效果的发动条件/对象选择：选择对方场上1只表侧表示效果怪兽为对象（且该效果怪兽未被无效、可被无效）。
function c35334193.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理时，若指定了对象chkc，则验证该对象必须是对方场上的效果怪兽且能被无效。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 发动时确认：对方场上是否存在至少1只满足条件的表侧表示效果怪兽可选。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示：请选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从对方场上选择1只表侧表示效果怪兽作为对象，并将其与当前效果关联。
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果涉及使效果无效（CATEGORY_DISABLE），对象为已选中的那1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果处理：将对象怪兽效果无效化；若此卡仍合法且对象怪兽未被免疫，可让该怪兽移动到这张卡所连接区的对方怪兽区域。
function c35334193.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①效果的对象怪兽（因为只选择了1张，直接用Duel.GetFirstTarget取回）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与该怪兽相关的已发动连锁一并无效化，并设置重置条件为变里侧时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 给对象怪兽赋予效果无效化（EFFECT_DISABLE），持续到回合结束时。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 给对象怪兽赋予效果发动无效化（EFFECT_DISABLE_EFFECT），直到变里侧或回合结束重置。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if not c:IsRelateToEffect(e) or c:IsFacedown() or tc:IsImmuneToEffect(e) then return end
		-- 立即更新场上卡片被无效化的状态，确保后续判定使用最新的无效状态。
		Duel.AdjustInstantly()
		local zone=bit.band(c:GetLinkedZone(1-tp),0x1f)
		-- 移动判定：对象怪兽确实被无效、控制者是对方、这张卡连接区所对应的对方怪兽区有空位，且玩家选择“是”时才执行移动。
		if tc:IsDisabled() and tc:IsControler(1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0 and Duel.SelectYesNo(tp,aux.Stringid(35334193,2)) then  --"是否移动那只怪兽？"
			local s=0
			local flag=bit.bxor(zone,0xff)*0x10000
			-- 弹出选择提示：请选择要移动到的位置。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 让玩家在指定可用格子中选1个（扣除禁用的连接区），返回该格子的位置标记并换算成序号。
			s=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,flag)/0x10000
			local nseq=0
			if s==1 then nseq=0
			elseif s==2 then nseq=1
			elseif s==4 then nseq=2
			elseif s==8 then nseq=3
			else nseq=4 end
			-- 将对象怪兽移动到所选的怪兽区域（该区域必须是本卡连接区内的对方区域）。
			Duel.MoveSequence(tc,nseq)
		end
	end
end
-- ②效果的发动条件：发动时这次的攻击者正是这张卡。
function c35334193.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定本次发动时机为这张卡进行攻击的伤害步骤开始时（攻击者等于这张卡）。
	return Duel.GetAttacker()==e:GetHandler()
end
-- ②效果发动时，取这张卡所连接区的全体怪兽，确认其中有可除外的卡，并设置操作信息为除外。
function c35334193.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=e:GetHandler():GetLinkedGroup():Filter(Card.IsAbleToRemove,nil)
	if chk==0 then return #rg>0 end
	-- 设置操作信息：本次效果将除外（CATEGORY_REMOVE）连接区的那些怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,#rg,0,0)
end
-- ②效果处理：这张卡仍表侧表示且与效果有关联时，将其所连接区的怪兽全部除外。
function c35334193.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local rg=c:GetLinkedGroup():Filter(Card.IsAbleToRemove,nil)
		if #rg>0 then
			-- 把连接区的怪兽以表侧表示除外（除外原因视为效果）。
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
