--ディフェクト・コンパイラー
-- 效果：
-- ①：1回合1次，对方的效果让自己受到伤害的场合，作为代替给这张卡放置1个缺陷指示物（最多1个）。
-- ②：1回合1次，把这张卡1个缺陷指示物取除，以自己场上1只电子界族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升800。这个效果在对方回合也能发动。
function c92327802.initial_effect(c)
	c:EnableCounterPermit(0x43)
	c:SetCounterLimit(0x43,1)
	-- ①：1回合1次，对方的效果让自己受到伤害的场合，作为代替给这张卡放置1个缺陷指示物（最多1个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REPLACE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c92327802.damval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个缺陷指示物取除，以自己场上1只电子界族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升800。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetDescription(aux.Stringid(92327802,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1)
	-- 设置效果的发动条件：在伤害步骤中，只能在伤害计算前发动
	e2:SetCondition(aux.dscon)
	e2:SetCost(c92327802.cost)
	e2:SetTarget(c92327802.tg)
	e2:SetOperation(c92327802.op)
	c:RegisterEffect(e2)
end
-- 伤害代替的价值函数：判定是否为对方效果造成的伤害，若是则作为代替给这张卡放置1个缺陷指示物，并使伤害变为0
function c92327802.damval(e,re,val,r,rp,rc)
	local c=e:GetHandler()
	if bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetOwnerPlayer()
		and c:IsCanAddCounter(0x43,1) and c:GetFlagEffect(92327802)==0 then
		c:AddCounter(0x43,1)
		c:RegisterFlagEffect(92327802,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		return 0
	end
	return val
end
-- 效果发动的代价：移除自己场上1个缺陷指示物
function c92327802.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查自己场上是否能以发动代价为原因移除1个缺陷指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x43,1,REASON_COST) end
	-- 移除自己场上1个缺陷指示物作为发动代价
	Duel.RemoveCounter(tp,1,0,0x43,1,REASON_COST)
end
-- 过滤条件：自己场上表侧表示的电子界族怪兽
function c92327802.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- 效果的目标选择：选择自己场上1只表侧表示的电子界族怪兽为对象
function c92327802.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c92327802.filter(chkc) end
	-- 在发动检查阶段，检查自己场上是否存在符合条件的电子界族怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c92327802.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的电子界族怪兽作为效果对象
	Duel.SelectTarget(tp,c92327802.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果的处理：使作为对象的怪兽攻击力直到回合结束时上升800
function c92327802.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(800)
		tc:RegisterEffect(e1)
	end
end
