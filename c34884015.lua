--魂のペンデュラム
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己的灵摆区域2张卡为对象才能发动。作为对象的卡的灵摆刻度各自上升或下降1（最少到1）。
-- ②：每次自己的灵摆怪兽灵摆召唤给这张卡放置1个指示物。
-- ③：场上的灵摆怪兽的攻击力上升这张卡的指示物数量×300。
-- ④：把这张卡3个指示物取除才能发动。这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把怪兽灵摆召唤。
function c34884015.initial_effect(c)
	c:EnableCounterPermit(0x4e)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：以自己的灵摆区域2张卡为对象才能发动。作为对象的卡的灵摆刻度各自上升或下降1（最少到1）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34884015,0))  --"改变刻度"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,34884015)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c34884015.target)
	e2:SetOperation(c34884015.operation)
	c:RegisterEffect(e2)
	-- ②：每次自己的灵摆怪兽灵摆召唤给这张卡放置1个指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c34884015.counterop)
	c:RegisterEffect(e3)
	-- ③：场上的灵摆怪兽的攻击力上升这张卡的指示物数量×300。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置攻击力上升效果只对场上的灵摆怪兽生效。
	e4:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_PENDULUM))
	e4:SetValue(c34884015.atkval)
	c:RegisterEffect(e4)
	-- ④：把这张卡3个指示物取除才能发动。这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把怪兽灵摆召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(34884015,3))  --"额外灵摆召唤"
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCost(c34884015.expcost)
	e5:SetTarget(c34884015.exptg)
	e5:SetOperation(c34884015.expop)
	c:RegisterEffect(e5)
end
-- ①效果的目标处理：在自己灵摆区域存在至少2张卡时，将这些卡全部选为对象并记录。
function c34884015.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检测：自己灵摆区域存在至少2张可作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,2,nil) end
	-- 获取自己灵摆区域的全部卡片。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 将获取的卡片组设为当前连锁的对象。
	Duel.SetTargetCard(g)
end
-- ①效果处理：依次对每张对象灵摆卡，让玩家选择使其刻度上升1或下降1（左刻度≤1时只能上升），并对左右灵摆刻度分别赋予相应的增减效果。
function c34884015.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁信息中取出发动时选择的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	local tc=tg:GetFirst()
	while tc do
		-- 播放该卡被选为对象/正在处理的提示动画。
		Duel.HintSelection(Group.FromCards(tc))
		local sel=0
		if tc:GetLeftScale()<=1 then
			-- 当该卡左刻度≤1时，只提供“刻度上升”选项（因为最低只能到1）。
			sel=Duel.SelectOption(tp,aux.Stringid(34884015,1))  --"刻度上升"
		else
			-- 否则提供“刻度上升”和“刻度下降”两个选项供玩家选择。
			sel=Duel.SelectOption(tp,aux.Stringid(34884015,1),aux.Stringid(34884015,2))  --"刻度上升/刻度下降"
		end
		local ct=1
		if sel==1 then
			ct=-1
		end
		-- 作为对象的卡的灵摆刻度各自上升或下降1（最少到1）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LSCALE)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RSCALE)
		tc:RegisterEffect(e2)
		tc=tg:GetNext()
	end
end
-- 判定怪兽是否满足：表侧表示、灵摆怪兽、属于自己控制、且是以灵摆召唤方式特殊召唤成功。
function c34884015.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 每当有怪兽特殊召唤成功时，若满足条件的自己的灵摆怪兽灵摆召唤成功，则给这张卡放置1个指示物。
function c34884015.counterop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c34884015.cfilter,1,nil,tp) then
		e:GetHandler():AddCounter(0x4e,1)
	end
end
-- 攻击力上升数值=这张卡的指示物数量×300。
function c34884015.atkval(e,c)
	return e:GetHandler():GetCounter(0x4e)*300
end
-- ④效果的发动代价：从这张卡取除3个指示物作为COST。
function c34884015.expcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x4e,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x4e,3,REASON_COST)
end
-- ④效果发动条件检测：本回合尚未发动过该④效果。
function c34884015.exptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否已存在使用了④效果的标记（flag数量为0才可发动）。
	if chk==0 then return Duel.GetFlagEffect(tp,34884015)==0 end
end
-- ④效果处理：赋予本回合1次追加灵摆召唤的权利，并记录已使用标记；该权利与标记在回合结束重置。
function c34884015.expop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把怪兽灵摆召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34884015,4))  --"使用「魂之灵摆」的效果灵摆召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,29432356)
	-- 设置该追加灵摆召唤效果的条件值为true，即允许玩家进行额外灵摆召唤。
	e1:SetValue(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将额外灵摆召唤效果注册给玩家tp，使该效果在本回合内对玩家生效。
	Duel.RegisterEffect(e1,tp)
	-- 注册本回合已使用④效果的标记，并在回合结束时自动清除。
	Duel.RegisterFlagEffect(tp,34884015,RESET_PHASE+PHASE_END,0,1)
end
