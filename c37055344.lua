--ゴーストリック・ロールシフト
-- 效果：
-- 1回合1次，战斗阶段中可以从以下效果选择1个发动。
-- ●选择自己场上1只名字带有「鬼计」的怪兽变成里侧守备表示，选对方场上里侧守备表示存在的1只怪兽变成表侧攻击表示。
-- ●选择自己场上里侧守备表示存在的1只怪兽变成表侧攻击表示，那是名字带有「鬼计」的怪兽的场合，选对方场上表侧表示存在的1只怪兽变成里侧守备表示。
function c37055344.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：1回合1次，战斗阶段中可以从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37055344,0))  --"选择效果"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCondition(c37055344.condition)
	e2:SetTarget(c37055344.target)
	e2:SetOperation(c37055344.operation)
	c:RegisterEffect(e2)
end
-- 规则层面：判断当前是否为战斗阶段
function c37055344.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：当前阶段在战斗阶段开始到战斗阶段结束之间
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 规则层面：过滤自己场上表侧表示且名字带有「鬼计」且可以变更为里侧表示的怪兽
function c37055344.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x8d) and c:IsCanTurnSet()
end
-- 规则层面：过滤对方场上里侧守备表示的怪兽
function c37055344.filter2(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
end
-- 规则层面：过滤自己场上里侧守备表示的怪兽
function c37055344.filter3(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
end
-- 规则层面：过滤对方场上表侧表示且可以变更为里侧表示的怪兽
function c37055344.filter4(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 规则层面：处理目标选择逻辑，根据标签值判断选择哪组目标
function c37055344.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37055344.filter1(chkc)
		else return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c37055344.filter3(chkc) end
	end
	-- 规则层面：检查自己场上是否存在满足filter1条件的怪兽
	local b1=Duel.IsExistingTarget(c37055344.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 规则层面：检查对方场上是否存在满足filter2条件的怪兽
		and Duel.IsExistingMatchingCard(c37055344.filter2,tp,0,LOCATION_MZONE,1,nil)
	-- 规则层面：检查自己场上是否存在满足filter3条件的怪兽
	local b2=Duel.IsExistingTarget(c37055344.filter3,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 规则层面：让玩家选择发动效果1（自己「鬼计」怪兽变成里侧守备表示）或效果2（自己怪兽变成表侧攻击表示）
		op=Duel.SelectOption(tp,aux.Stringid(37055344,1),aux.Stringid(37055344,2))  --"自己「鬼计」怪兽变成里侧守备表示/自己怪兽变成表侧攻击表示"
	elseif b1 then
		-- 规则层面：让玩家选择发动效果1（自己「鬼计」怪兽变成里侧守备表示）
		op=Duel.SelectOption(tp,aux.Stringid(37055344,1))  --"自己「鬼计」怪兽变成里侧守备表示"
	else
		-- 规则层面：让玩家选择发动效果2（自己怪兽变成表侧攻击表示）
		op=Duel.SelectOption(tp,aux.Stringid(37055344,2))+1  --"自己怪兽变成表侧攻击表示"
	end
	e:SetLabel(op)
	if op==0 then
		-- 规则层面：提示玩家选择表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 规则层面：选择满足filter1条件的自己场上的怪兽作为目标
		local g=Duel.SelectTarget(tp,c37055344.filter1,tp,LOCATION_MZONE,0,1,1,nil)
		-- 规则层面：设置连锁操作信息为改变表示形式
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	else
		-- 规则层面：提示玩家选择里侧守备表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWNDEFENSE)  --"请选择里侧守备表示的怪兽"
		-- 规则层面：选择满足filter3条件的自己场上的怪兽作为目标
		local g=Duel.SelectTarget(tp,c37055344.filter3,tp,LOCATION_MZONE,0,1,1,nil)
		-- 规则层面：设置连锁操作信息为改变表示形式
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	end
end
-- 效果原文：●选择自己场上1只名字带有「鬼计」的怪兽变成里侧守备表示，选对方场上里侧守备表示存在的1只怪兽变成表侧攻击表示。●选择自己场上里侧守备表示存在的1只怪兽变成表侧攻击表示，那是名字带有「鬼计」的怪兽的场合，选对方场上表侧表示存在的1只怪兽变成里侧守备表示。
function c37055344.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetLabel()==0 then
		if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
		-- 规则层面：将目标怪兽变为里侧守备表示，若失败则返回
		if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)==0 then return end
		-- 规则层面：提示玩家选择里侧守备表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWNDEFENSE)  --"请选择里侧守备表示的怪兽"
		-- 规则层面：选择对方场上满足filter2条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c37055344.filter2,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 规则层面：将选中的怪兽变为表侧攻击表示
			Duel.ChangePosition(g,POS_FACEUP_ATTACK)
		end
	else
		if not tc:IsRelateToEffect(e) or tc:IsPosition(POS_FACEUP_ATTACK) then return end
		-- 规则层面：将目标怪兽变为表侧攻击表示，若失败或不是「鬼计」怪兽则返回
		if Duel.ChangePosition(tc,POS_FACEUP_ATTACK)==0 or not tc:IsSetCard(0x8d) then return end
		-- 规则层面：提示玩家选择表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 规则层面：选择对方场上满足filter4条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c37055344.filter4,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 规则层面：将选中的怪兽变为里侧守备表示
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end
