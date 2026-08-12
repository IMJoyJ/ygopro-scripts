--トン＝トン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力·等级之内比原本数值高的数值变成原本数值。那之后，支付100的倍数的基本分（最多1000）。
-- ②：这张卡在墓地存在，自己基本分和对方相同的场合，自己主要阶段才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册两个效果，分别为①效果和②效果
function s.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力·等级之内比原本数值高的数值变成原本数值。那之后，支付100的倍数的基本分（最多1000）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害步骤前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己基本分和对方相同的场合，自己主要阶段才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 筛选满足条件的表侧表示怪兽（攻击力、守备力或等级有提升）
function s.filter(c)
	return c:IsFaceup() and (c:IsLevelAbove(c:GetOriginalLevel()+1) or c:IsAttackAbove(c:GetBaseAttack()+1) or c:IsDefenseAbove(c:GetBaseDefense()+1))
end
-- 设置效果目标为符合条件的怪兽，并检查是否能支付100基本分
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查玩家是否能支付至少100基本分
		and Duel.CheckLPCost(tp,100,true) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理①效果的主要逻辑，包括改变攻击力、守备力和等级，并要求支付基本分
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		local ct=0
		local ba,bd,bl=tc:GetBaseAttack(),tc:GetBaseDefense(),tc:GetOriginalLevel()
		if tc:IsAttackAbove(ba) then
			-- 将怪兽的攻击力修改为原本数值
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(ba)
			tc:RegisterEffect(e1)
			ct=ct+1
		end
		if tc:IsDefenseAbove(bd) then
			-- 将怪兽的守备力修改为原本数值
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(bd)
			tc:RegisterEffect(e2)
			ct=ct+1
		end
		if tc:IsLevelAbove(bl) then
			-- 将怪兽的等级修改为原本数值
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CHANGE_LEVEL)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			e3:SetValue(bl)
			tc:RegisterEffect(e3)
			ct=ct+1
		end
		if ct==0 then return end
		-- 获取玩家当前基本分
		local lp=Duel.GetLP(tp)
		local m=math.min(lp,1000)//100
		local t={}
		for i=1,m do
			t[i]=i*100
		end
		-- 让玩家宣言一个100的倍数（最多1000）
		local ac=Duel.AnnounceNumber(tp,table.unpack(t))
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 支付宣言的基本分
		Duel.PayLPCost(tp,ac,true)
	end
end
-- 设置②效果发动条件：双方基本分相同
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断双方基本分是否相等
	return Duel.GetLP(0)==Duel.GetLP(1)
end
-- 设置②效果的发动条件和操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息，表示将要盖放此卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 处理②效果的发动逻辑，将此卡盖放到场上
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡能正常盖放
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
