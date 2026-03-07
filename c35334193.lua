--S－Force ジャスティファイ
-- 效果：
-- 包含「治安战警队」怪兽的效果怪兽3只
-- 自己不能在这张卡所连接区让怪兽出现。这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方回合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。那之后，可以让那只对方怪兽向作为这张卡所连接区的对方的怪兽区域移动。
-- ②：这张卡攻击的伤害步骤开始时才能发动。这张卡所连接区的怪兽全部除外。
function c35334193.initial_effect(c)
	-- 连接召唤手续：使用满足效果怪兽类型的怪兽作为连接素材，最少3个，最多3个
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3,3,c35334193.lcheck)
	c:EnableReviveLimit()
	-- 自己不能在这张卡所连接区让怪兽出现
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_USE_MZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c35334193.zonelimit)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。那之后，可以让那只对方怪兽向作为这张卡所连接区的对方的怪兽区域移动
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
	-- ②：这张卡攻击的伤害步骤开始时才能发动。这张卡所连接区的怪兽全部除外
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
-- 连接召唤条件：连接素材必须包含治安战警队系列的怪兽
function c35334193.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x156)
end
-- 区域限制函数：返回当前卡片连接区域以外的可用区域
function c35334193.zonelimit(e)
	return 0x7f007f & ~e:GetHandler():GetLinkedZone()
end
-- 效果处理：选择对方场上一只效果怪兽作为对象，使其效果无效
function c35334193.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 目标选择：当chkc不为空时，返回对方怪兽区中满足效果怪兽过滤条件的卡片
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 条件判断：判断是否存在满足条件的对方怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示信息：提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择目标：选择一只对方怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：设置将要无效的怪兽为操作对象
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理：使目标怪兽效果无效并可选择是否移动
function c35334193.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取目标：获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 无效连锁：使目标怪兽相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果无效：使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果无效：使目标怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if not c:IsRelateToEffect(e) or c:IsFacedown() or tc:IsImmuneToEffect(e) then return end
		-- 刷新场上状态：手动刷新场上卡片的无效状态
		Duel.AdjustInstantly()
		local zone=bit.band(c:GetLinkedZone(1-tp),0x1f)
		-- 条件判断：判断目标怪兽是否被无效且满足移动条件
		if tc:IsDisabled() and tc:IsControler(1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0 and Duel.SelectYesNo(tp,aux.Stringid(35334193,2)) then  --"是否移动那只怪兽？"
			local s=0
			local flag=bit.bxor(zone,0xff)*0x10000
			-- 提示信息：提示玩家选择要移动到的位置
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 选择区域：选择一个可用的怪兽区域
			s=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,flag)/0x10000
			local nseq=0
			if s==1 then nseq=0
			elseif s==2 then nseq=1
			elseif s==4 then nseq=2
			elseif s==8 then nseq=3
			else nseq=4 end
			-- 移动怪兽：将目标怪兽移动到指定区域
			Duel.MoveSequence(tc,nseq)
		end
	end
end
-- 触发条件：攻击开始时触发
function c35334193.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 触发条件：攻击怪兽为自身
	return Duel.GetAttacker()==e:GetHandler()
end
-- 效果处理：设置要除外的连接区怪兽
function c35334193.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=e:GetHandler():GetLinkedGroup():Filter(Card.IsAbleToRemove,nil)
	if chk==0 then return #rg>0 end
	-- 设置操作信息：设置将要除外的怪兽为操作对象
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,#rg,0,0)
end
-- 效果处理：将连接区的怪兽除外
function c35334193.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local rg=c:GetLinkedGroup():Filter(Card.IsAbleToRemove,nil)
		if #rg>0 then
			-- 除外怪兽：将指定怪兽除外
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
