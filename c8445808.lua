--恋する乙女
-- 效果：
-- ①：只要这张卡在怪兽区域存在，可以攻击的对方怪兽必须向这张卡作出攻击。
-- ②：这张卡不会被战斗破坏。
-- ③：这张卡和对方怪兽进行战斗的伤害步骤结束时，可以从以下效果选择1个发动。
-- ●给对方场上1只表侧表示怪兽放置1个少女指示物。
-- ●得到有少女指示物放置的1只对方怪兽的控制权。
local s,id,o=GetID()
-- 初始化卡片效果：注册强制向此卡攻击、战破抗性、以及伤害步骤结束放置指示物/夺取控制权效果
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
●给对方场上1只表侧表示怪兽放置1个少女指示物。
●得到有少女指示物放置的1只对方怪兽的控制权。
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
s.mentioned_counter={
	[0x1072]=true,
}
-- 攻击目标限制：对方怪兽攻击时必须选择此卡作为攻击对象
function s.atklimit(e,c)
	return c==e:GetHandler()
end
-- ③效果发动条件：此卡与对方怪兽进行了战斗且在伤害步骤结束时仍留在场上
function s.cccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 控制权变更过滤条件：放置有少女指示物且控制权可变更的怪兽
function s.cfilter(c)
	return c:IsControlerCanBeChanged() and c:GetCounter(0x1072)>0
end
-- ③效果发动准备：由玩家从放置指示物或夺取控制权中选择1个效果分支并设置操作信息
function s.cctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可放置少女指示物的怪兽
	local b1=Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1072,1)
	-- 检查对方场上是否存在可夺取控制权的有少女指示物的怪兽
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 由玩家选择发动的效果分支（1：放置指示物，2：得到控制权）
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3),1},  --"放置指示物"
			{b2,aux.Stringid(id,4),2})  --"得到控制权"
	end
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_COUNTER)
		-- 获取对方场上所有可放置少女指示物的怪兽
		local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x1072,1)
		-- 设置连锁操作信息：放置1个少女指示物
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_CONTROL)
		-- 获取对方场上所有放置有少女指示物且可夺取控制权的怪兽
		local g=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil)
		-- 设置连锁操作信息：得到1只怪兽的控制权
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	end
end
-- ③效果处理：根据选择的分支，执行放置少女指示物或夺取怪兽控制权
function s.ccop(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if e:GetLabel()==1 then
		-- 提示玩家选择要放置少女指示物的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 从对方场上选择1只怪兽放置少女指示物
		local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1072,1)
		local tc=g:GetFirst()
		if tc then
			-- 高亮显示选择放置指示物的怪兽
			Duel.HintSelection(g)
			tc:AddCounter(0x1072,1)
		end
	else
		-- 提示玩家选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 从对方场上选择1只带少女指示物的怪兽
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 高亮显示选择夺取控制权的怪兽
			Duel.HintSelection(g)
			-- 得到选中怪兽的控制权
			Duel.GetControl(tc,tp)
		end
	end
end
