--ヴァレルロード・ドラゴン
-- 效果：
-- 效果怪兽3只以上
-- ①：双方不能把场上的这张卡作为怪兽的效果的对象。
-- ②：自己·对方回合1次，以场上1只表侧表示怪兽为对象才能发动（对方不能对应这个效果的发动把卡的效果发动）。那只怪兽的攻击力·守备力下降500。
-- ③：这张卡向对方怪兽攻击的伤害步骤开始时才能发动。那只对方怪兽在这张卡所连接区放置得到控制权。这个效果得到的怪兽在下个回合的结束阶段送去墓地。
function c31833038.initial_effect(c)
	-- 为这张卡添加连接召唤手续，素材为3只以上的效果怪兽。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3)
	c:EnableReviveLimit()
	-- ①：双方不能把场上的这张卡作为怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c31833038.efilter1)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合1次，以场上1只表侧表示怪兽为对象才能发动（对方不能对应这个效果的发动把卡的效果发动）。那只怪兽的攻击力·守备力下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31833038,0))  --"攻守下降"
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetHintTiming(TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e3:SetCountLimit(1)
	-- 设置效果的发动条件为aux.dscon，即仅在伤害步骤且尚未进行伤害计算时才能发动，避免在伤害计算后发动。
	e3:SetCondition(aux.dscon)
	e3:SetTarget(c31833038.atktg)
	e3:SetOperation(c31833038.atkop)
	c:RegisterEffect(e3)
	-- ③：这张卡向对方怪兽攻击的伤害步骤开始时才能发动。那只对方怪兽在这张卡所连接区放置得到控制权。这个效果得到的怪兽在下个回合的结束阶段送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31833038,1))  --"获得控制权"
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetTarget(c31833038.cttg)
	e4:SetOperation(c31833038.ctop)
	c:RegisterEffect(e4)
end
-- 作为效果①的判定函数：效果来源为怪兽效果时返回true，即只有怪兽效果不能将这张卡作为对象。
function c31833038.efilter1(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的发动目标处理：检查是否存在表侧表示怪兽可供选择，提示玩家选择，选择后设为效果对象，并设置连锁限制。
function c31833038.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 效果发动合法性检查：场上是否存在至少1只表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方场上选择1只表侧表示怪兽作为效果对象，并记录为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁限制，使对方不能连锁这个效果的发动。
	Duel.SetChainLimit(c31833038.chlimit)
end
-- 连锁限制函数：只有效果发动者本人可以连锁，对方不能连锁，对应“对方不能对应这个效果的发动把卡的效果发动”。
function c31833038.chlimit(e,ep,tp)
	return tp==ep
end
-- 效果②处理时，对对象怪兽赋予攻击力、守备力下降500的持续效果。
function c31833038.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力·守备力下降500。
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
-- ③效果发动条件和目标设定：确认攻击者为这张卡、攻击目标可被夺取控制权并放置在连接区，然后将该攻击目标设为效果对象。
function c31833038.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 取得这张卡攻击的对方怪兽。
	local tc=Duel.GetAttackTarget()
	if chk==0 then
		local zone=bit.band(c:GetLinkedZone(),0x1f)
		-- 判断③效果的发动条件：攻击者是这张卡、存在攻击对象，且攻击对象可以被变更控制权到这张卡的连接区。
		return Duel.GetAttacker()==c and tc and tc:IsControlerCanBeChanged(false,zone)
	end
	-- 将攻击目标设置为效果对象。
	Duel.SetTargetCard(tc)
	-- 设置操作信息，宣布此效果将获得对象怪兽的控制权（CATEGORY_CONTROL），用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
-- ③效果处理：成功获得对象怪兽控制权到这张卡的连接区，并埋入下个结束阶段将其送去墓地的效果。
function c31833038.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取得效果对象怪兽（被攻击的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local zone=bit.band(c:GetLinkedZone(),0x1f)
		-- 尝试将对象怪兽的控制权转移给这张卡的控制者，并放置在指定连接区；成功则继续后续处理。
		if Duel.GetControl(tc,tp,0,0,zone)~=0 then
			tc:RegisterFlagEffect(31833038,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
			-- 这个效果得到的怪兽在下个回合的结束阶段送去墓地。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCondition(c31833038.descon)
			e1:SetOperation(c31833038.desop)
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			e1:SetCountLimit(1)
			-- 记录当前回合数，用于判断“下个回合”。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetLabelObject(tc)
			-- 将“结束阶段送去墓地”的效果注册到场上，使其在之后持续生效。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 结束阶段送墓效果的发动条件：已到下个回合，且对象怪兽仍带有已获取控制权的标记。
function c31833038.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判定是否满足“下个回合的结束阶段”：当前回合数不同于记录值，且对象怪兽仍带有标记。
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(31833038)~=0
end
-- 满足条件时执行：将对象怪兽送去墓地。
function c31833038.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将对象怪兽以效果原因送去墓地。
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
