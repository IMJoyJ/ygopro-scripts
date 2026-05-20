--恋する乙女
-- 效果：
-- ①：只要这张卡在怪兽区域存在，可以攻击的对方怪兽必须向这张卡作出攻击。
-- ②：这张卡不会被战斗破坏。
-- ③：这张卡和对方怪兽进行战斗的伤害步骤结束时，可以从以下效果选择1个发动。
-- ●给对方场上1只表侧表示怪兽放置1个少女指示物。
-- ●得到有少女指示物放置的1只对方怪兽的控制权。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含强制攻击、不会被战破、以及伤害步骤结束时选择发动的效果。
function s.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，可以攻击的对方怪兽必须向这张卡作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetValue(s.atklimit)
	c:RegisterEffect(e2)
	-- ②：这张卡不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡和对方怪兽进行战斗的伤害步骤结束时，可以从以下效果选择1个发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"发动"
	e4:SetCategory(CATEGORY_CONTROL+CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(s.cccon)
	e4:SetTarget(s.cctg)
	e4:SetOperation(s.ccop)
	c:RegisterEffect(e4)
end
s.counter_add_list={0x1072}
-- 限制对方怪兽攻击时的攻击目标必须是这张卡自身。
function s.atklimit(e,c)
	return c==e:GetHandler()
end
-- 检查效果③的发动条件：这张卡在战斗中，且是与对方怪兽进行战斗。
function s.cccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 过滤条件：可以改变控制权且放置有少女指示物的对方怪兽。
function s.cfilter(c)
	return c:IsControlerCanBeChanged() and c:GetCounter(0x1072)>0
end
-- 效果③的发动准备与分支选择：检查是否能放置指示物或夺取控制权，并让玩家选择其中一个效果。
function s.cctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以放置少女指示物的怪兽。
	local b1=Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1072,1)
	-- 检查对方场上是否存在可以夺取控制权且有少女指示物的怪兽。
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 提示玩家从“放置指示物”和“得到控制权”中选择一个可发动的效果。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3),1},  --"放置指示物"
			{b2,aux.Stringid(id,4),2})  --"得到控制权"
	end
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_COUNTER)
		-- 获取对方场上所有可以放置少女指示物的怪兽。
		local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x1072,1)
		-- 设置效果处理信息：放置1个指示物。
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_CONTROL)
		-- 获取对方场上所有满足夺取控制权条件的有少女指示物的怪兽。
		local g=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil)
		-- 设置效果处理信息：夺取1只怪兽的控制权。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	end
end
-- 效果③的效果处理：根据玩家的选择，执行放置少女指示物或夺取控制权的操作。
function s.ccop(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if e:GetLabel()==1 then
		-- 提示玩家选择要放置指示物的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 让玩家选择对方场上1只可以放置少女指示物的怪兽。
		local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1072,1)
		local tc=g:GetFirst()
		if tc then
			-- 选中怪兽时在场上显示绿框特效。
			Duel.HintSelection(g)
			tc:AddCounter(0x1072,1)
		end
	else
		-- 提示玩家选择要夺取控制权的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 让玩家选择对方场上1只带有少女指示物且可以夺取控制权的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 选中怪兽时在场上显示绿框特效。
			Duel.HintSelection(g)
			-- 夺取目标怪兽的控制权。
			Duel.GetControl(tc,tp)
		end
	end
end
