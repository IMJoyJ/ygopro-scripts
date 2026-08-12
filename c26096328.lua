--超弩級砲塔列車ジャガーノート・リーベ
-- 效果：
-- 11星怪兽×3
-- 「超重型炮塔列车 破天巨爱」1回合1次也能在自己场上的机械族·10阶的超量怪兽上面重叠来超量召唤。
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力·守备力上升2000。这个效果的发动后，直到回合结束时自己不用这张卡不能攻击宣言。
-- ②：这张卡在同1次的战斗阶段中可以向怪兽作出最多有这张卡的超量素材数量＋1次的攻击。
function c26096328.initial_effect(c)
	aux.AddXyzProcedure(c,nil,11,3,c26096328.ovfilter,aux.Stringid(26096328,0),3,c26096328.xyzop)  --"是否在机械族超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力·守备力上升2000。这个效果的发动后，直到回合结束时自己不用这张卡不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26096328,0))  --"是否在机械族超量怪兽上面重叠来超量召唤？"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c26096328.atkcost)
	e1:SetOperation(c26096328.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡在同1次的战斗阶段中可以向怪兽作出最多有这张卡的超量素材数量＋1次的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetValue(c26096328.raval)
	c:RegisterEffect(e2)
end
-- 判断场上是否满足在机械族10阶超量怪兽上面重叠召唤的条件
function c26096328.ovfilter(c)
	return c:IsFaceup() and c:GetRank()==10 and c:IsRace(RACE_MACHINE)
end
-- 检查是否已使用过此效果，若未使用则注册标识效果
function c26096328.xyzop(e,tp,chk)
	-- 检查是否已使用过此效果
	if chk==0 then return Duel.GetFlagEffect(tp,26096328)==0 end
	-- 注册一个在结束阶段重置的标识效果，防止此效果在同回合再次发动
	Duel.RegisterFlagEffect(tp,26096328,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 支付效果代价：去除1个超量素材
function c26096328.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 使自身攻击力和守备力上升2000，并在本回合内禁止自身攻击
function c26096328.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使自身攻击力上升2000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(2000)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
	-- 创建一个直到回合结束时禁止自身攻击的效果
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_ATTACK)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(c26096328.ftarget)
	e0:SetLabel(c:GetFieldID())
	e0:SetReset(RESET_PHASE+PHASE_END)
	-- 将禁止攻击效果注册到游戏中
	Duel.RegisterEffect(e0,tp)
end
-- 设置禁止攻击效果的目标为除自身外的所有场上怪兽
function c26096328.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 返回自身当前的超量素材数量
function c26096328.raval(e,c)
	return e:GetHandler():GetOverlayCount()
end
