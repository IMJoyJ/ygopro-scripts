--巨神封じの矢
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以从额外卡组特殊召唤的对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，那个效果无效。
-- ②：这张卡在墓地存在的状态，对方从额外卡组把怪兽特殊召唤的场合才能发动。这张卡在自己场上盖放。这个效果在这张卡送去墓地的回合不能发动。
function c67037924.initial_effect(c)
	-- ①：以从额外卡组特殊召唤的对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67037924,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,67037924)
	-- 设置发动条件为伤害步骤中伤害计算前（或非伤害步骤）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c67037924.target)
	e1:SetOperation(c67037924.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，对方从额外卡组把怪兽特殊召唤的场合才能发动。这张卡在自己场上盖放。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67037924,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,67037925)
	e2:SetCondition(c67037924.setcon)
	e2:SetTarget(c67037924.settg)
	e2:SetOperation(c67037924.setop)
	c:RegisterEffect(e2)
end
-- 过滤出对方场上从额外卡组特殊召唤的、表侧表示且攻击力大于0的怪兽
function c67037924.filter(c)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA) and c:GetAttack()>0
end
-- 效果①的发动准备：检查并选择对方场上1只符合条件的表侧表示怪兽作为对象
function c67037924.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c67037924.filter(chkc) end
	-- 检查对方场上是否存在至少1只符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c67037924.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只符合条件的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c67037924.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①的处理：使目标怪兽的效果无效，且攻击力变成0
function c67037924.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		-- 使与目标怪兽相关的连锁效果无效化，在变里侧表示时重置
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那个效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		-- 立即刷新目标怪兽的无效状态
		Duel.AdjustInstantly(tc)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(0)
		tc:RegisterEffect(e3)
	end
end
-- 过滤出对方从额外卡组特殊召唤的怪兽
function c67037924.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end
-- 效果②的发动条件判定：对方从额外卡组特殊召唤怪兽，且这张卡不是在送去墓地的回合
function c67037924.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查特殊召唤的怪兽中是否存在对方从额外卡组召唤的怪兽，并确认当前回合不是该卡送去墓地的回合
	return eg:IsExists(c67037924.cfilter,1,nil,tp) and aux.exccon(e)
end
-- 效果②的发动准备：确认这张卡是否可以盖放，并设置操作信息
function c67037924.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置效果处理信息为将墓地的这张卡移出墓地（盖放）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的处理：将墓地的这张卡在自己场上盖放
function c67037924.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上盖放
		Duel.SSet(tp,c)
	end
end
