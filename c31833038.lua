--ヴァレルロード・ドラゴン
-- 效果：
-- 效果怪兽3只以上
-- ①：双方不能把场上的这张卡作为怪兽的效果的对象。
-- ②：自己·对方回合1次，以场上1只表侧表示怪兽为对象才能发动（对方不能对应这个效果的发动把卡的效果发动）。那只怪兽的攻击力·守备力下降500。
-- ③：这张卡向对方怪兽攻击的伤害步骤开始时才能发动。那只对方怪兽在这张卡所连接区放置得到控制权。这个效果得到的怪兽在下个回合的结束阶段送去墓地。
function c31833038.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少3张效果怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3)
	c:EnableReviveLimit()
	-- 双方不能把场上的这张卡作为怪兽的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c31833038.efilter1)
	c:RegisterEffect(e2)
	-- 自己·对方回合1次，以场上1只表侧表示怪兽为对象才能发动（对方不能对应这个效果的发动把卡的效果发动）。那只怪兽的攻击力·守备力下降500
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31833038,0))  --"攻守下降"
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetHintTiming(TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e3:SetCountLimit(1)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e3:SetCondition(aux.dscon)
	e3:SetTarget(c31833038.atktg)
	e3:SetOperation(c31833038.atkop)
	c:RegisterEffect(e3)
	-- 这张卡向对方怪兽攻击的伤害步骤开始时才能发动。那只对方怪兽在这张卡所连接区放置得到控制权。这个效果得到的怪兽在下个回合的结束阶段送去墓地
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31833038,1))  --"获得控制权"
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetTarget(c31833038.cttg)
	e4:SetOperation(c31833038.ctop)
	c:RegisterEffect(e4)
end
-- 效果对象必须是怪兽类型
function c31833038.efilter1(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 选择一个表侧表示的怪兽作为效果对象
function c31833038.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足选择目标的条件，即场上存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁限制，只能由发动玩家连锁
	Duel.SetChainLimit(c31833038.chlimit)
end
-- 连锁限制函数，只允许发动玩家连锁
function c31833038.chlimit(e,ep,tp)
	return tp==ep
end
-- 对目标怪兽的攻击力和守备力各下降500
function c31833038.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为对象怪兽添加攻击力下降500的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-500)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 判断是否满足控制权转移的条件，即攻击怪兽是此卡且目标怪兽可以改变控制权
function c31833038.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取攻击时的目标怪兽
	local tc=Duel.GetAttackTarget()
	if chk==0 then
		local zone=bit.band(c:GetLinkedZone(),0x1f)
		-- 判断攻击怪兽是否为此卡且目标怪兽可以改变控制权
		return Duel.GetAttacker()==c and tc and tc:IsControlerCanBeChanged(false,zone)
	end
	-- 设置当前连锁的效果对象为选定的怪兽
	Duel.SetTargetCard(tc)
	-- 设置操作信息，表示将要改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
-- 执行控制权转移并注册结束阶段的处理效果
function c31833038.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local zone=bit.band(c:GetLinkedZone(),0x1f)
		-- 尝试获得目标怪兽的控制权
		if Duel.GetControl(tc,tp,0,0,zone)~=0 then
			tc:RegisterFlagEffect(31833038,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
			-- 注册一个在结束阶段触发的效果，用于将目标怪兽送入墓地
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCondition(c31833038.descon)
			e1:SetOperation(c31833038.desop)
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			e1:SetCountLimit(1)
			-- 记录当前回合数用于后续判断
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetLabelObject(tc)
			-- 将效果注册到玩家全局环境中
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 判断是否满足结束阶段处理的条件，即不是当前回合且目标怪兽有标记
function c31833038.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断是否不是当前回合且目标怪兽有标记
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(31833038)~=0
end
-- 将目标怪兽送入墓地
function c31833038.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽以效果原因送入墓地
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
