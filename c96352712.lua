--誇大化
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：怪兽之间进行战斗的伤害步骤开始时，可以从以下效果选择1个发动。
-- ●那只攻击怪兽变成守备表示。
-- ●那只攻击对象怪兽回到手卡。
-- ●那2只进行战斗的怪兽破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：怪兽之间进行战斗的伤害步骤开始时，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定函数
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在攻击对象（即必须是怪兽之间的战斗）
	return Duel.GetAttackTarget()~=nil
end
-- 效果发动时的目标选择与操作信息设置函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取作为攻击对象的怪兽
	local d=Duel.GetAttackTarget()
	local b1=a:IsCanChangePosition() and a:IsAttackPos()
	local b2=d and d:IsAbleToHand()
	-- 让玩家从满足条件的选项中选择一个发动
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1)},  --"那只攻击怪兽变成守备表示"
		{b2,aux.Stringid(id,2)},  --"那只攻击对象怪兽回到手卡"
		{true,aux.Stringid(id,3)})  --"那2只进行战斗的怪兽破坏"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_POSITION)
		-- 设置改变表示形式的操作信息，目标为攻击怪兽
		Duel.SetOperationInfo(0,CATEGORY_POSITION,a,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND)
		-- 设置送回手卡的操作信息，目标为攻击对象怪兽
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,d,1,0,0)
	else
		e:SetCategory(CATEGORY_DESTROY)
		-- 设置破坏的操作信息，目标为进行战斗的两只怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,Group.FromCards(a,d),2,0,0)
	end
end
-- 效果处理函数，根据玩家的选择执行对应的分支效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		s.defense(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.rtohand(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then
		s.destroy(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 分支效果1：将攻击怪兽变为守备表示的处理函数
function s.defense(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽仍处于战斗状态，则将其变为表侧守备表示
	if tc:IsRelateToBattle() then Duel.ChangePosition(tc,POS_FACEUP_DEFENSE) end
end
-- 分支效果2：将攻击对象怪兽送回手卡的处理函数
function s.rtohand(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击对象怪兽
	local tc=Duel.GetAttackTarget()
	-- 若攻击对象怪兽仍处于战斗状态，则将其送回持有者手卡
	if tc:IsRelateToBattle() then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
-- 分支效果3：破坏进行战斗的两只怪兽的处理函数
function s.destroy(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行战斗的攻击怪兽和攻击对象怪兽
	local a,d=Duel.GetAttacker(),Duel.GetAttackTarget()
	local g=Group.FromCards(a,d):Filter(Card.IsRelateToBattle,nil)
	-- 若两只怪兽都仍处于战斗状态，则将它们全部破坏
	if #g==2 then Duel.Destroy(g,REASON_EFFECT) end
end
