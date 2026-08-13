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
	-- 1回合1次，战斗阶段中可以从以下效果选择1个发动。●选择自己场上1只名字带有「鬼计」的怪兽变成里侧守备表示，选对方场上里侧守备表示存在的1只怪兽变成表侧攻击表示。●选择自己场上里侧守备表示存在的1只怪兽变成表侧攻击表示，那是名字带有「鬼计」的怪兽的场合，选对方场上表侧表示存在的1只怪兽变成里侧守备表示。
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
-- 该效果只能在战斗阶段中发动，此条件函数用于判定当前阶段是否为战斗阶段（从战斗阶段开始到战斗阶段结束）。
function c37055344.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段处于战斗阶段开始（PHASE_BATTLE_START）到战斗阶段结束（PHASE_BATTLE）之间，满足时才可发动。
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 筛选自己场上表侧表示、字段为「鬼计」且可以变为里侧表示的怪兽，作为第一个选项的自己方对象候选。
function c37055344.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x8d) and c:IsCanTurnSet()
end
-- 筛选对方场上里侧守备表示存在的怪兽，作为第一个选项中要变成表侧攻击表示的对方对象候选。
function c37055344.filter2(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
end
-- 筛选自己场上里侧守备表示存在的怪兽，作为第二个选项的自己方对象候选。
function c37055344.filter3(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
end
-- 筛选对方场上表侧表示且可以变为里侧表示的怪兽，作为第二个选项中要变成里侧守备表示的对方对象候选。
function c37055344.filter4(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果发动时的目标选择处理：若为连锁处理中的对象合法性检查（chkc），根据当前选择的选项标签（e:GetLabel()）判断应检查哪个选项对应的对象：选项0检查己方表侧「鬼计」怪兽，选项1检查对方里侧守备怪兽。
function c37055344.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37055344.filter1(chkc)
		else return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c37055344.filter3(chkc) end
	end
	-- 检查自己场上是否存在满足 filter1 的表侧「鬼计」怪兽，用于判断第一个选项是否可选。
	local b1=Duel.IsExistingTarget(c37055344.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查对方场上是否存在里侧守备表示的怪兽，用于判断第一个选项是否可选。
		and Duel.IsExistingMatchingCard(c37055344.filter2,tp,0,LOCATION_MZONE,1,nil)
	-- 检查自己场上是否存在里侧守备表示怪兽，用于判断第二个选项是否可选。
	local b2=Duel.IsExistingTarget(c37055344.filter3,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个选项都可用时，弹出选择菜单，让玩家选择发动哪个选项（0：自己「鬼计」怪兽变里侧守备；1：自己怪兽变表侧攻击）。
		op=Duel.SelectOption(tp,aux.Stringid(37055344,1),aux.Stringid(37055344,2))  --"自己「鬼计」怪兽变成里侧守备表示/自己怪兽变成表侧攻击表示"
	elseif b1 then
		-- 当只有第一个选项可用时，让玩家选择该选项，此时 op 被设为0。
		op=Duel.SelectOption(tp,aux.Stringid(37055344,1))  --"自己「鬼计」怪兽变成里侧守备表示"
	else
		-- 当只有第二个选项可用时，让玩家选择该选项，因为 SelectOption 返回0，+1 使其标记为1（表示第二个选项）。
		op=Duel.SelectOption(tp,aux.Stringid(37055344,2))+1  --"自己怪兽变成表侧攻击表示"
	end
	e:SetLabel(op)
	if op==0 then
		-- 提示玩家选择表侧表示的卡，用于选择自己场上的表侧「鬼计」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家从自己场上选择1只满足 filter1 的表侧「鬼计」怪兽作为效果对象。
		local g=Duel.SelectTarget(tp,c37055344.filter1,tp,LOCATION_MZONE,0,1,1,nil)
		-- 将已选对象设置为改变表示形式的处理对象，供连锁处理时检测。
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	else
		-- 提示玩家选择里侧守备表示的怪兽，用于选择自己场上的里侧守备怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWNDEFENSE)  --"请选择里侧守备表示的怪兽"
		-- 让玩家从自己场上选择1只里侧守备表示怪兽作为第二个选项的对象。
		local g=Duel.SelectTarget(tp,c37055344.filter3,tp,LOCATION_MZONE,0,1,1,nil)
		-- 将已选对象设置为改变表示形式的处理对象。
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	end
end
-- 效果处理时的操作：根据发动时选择的选项（e:GetLabel()）执行对应的表示形式变更；选项0先将自己对象变里侧守备，再选对方里侧守备怪变表侧攻击；选项1先将自己对象变表侧攻击，若该怪兽为「鬼计」则再选对方表侧怪变里侧守备。
function c37055344.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetLabel()==0 then
		if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
		-- 将选中的己方「鬼计」怪兽变成里侧守备表示；若变更失败则中断处理。
		if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)==0 then return end
		-- 提示玩家选择里侧守备表示的怪兽，用于选择对方场上的里侧守备怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWNDEFENSE)  --"请选择里侧守备表示的怪兽"
		-- 从对方场上选择1只里侧守备表示怪兽。
		local g=Duel.SelectMatchingCard(tp,c37055344.filter2,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的对方怪兽变成表侧攻击表示。
			Duel.ChangePosition(g,POS_FACEUP_ATTACK)
		end
	else
		if not tc:IsRelateToEffect(e) or tc:IsPosition(POS_FACEUP_ATTACK) then return end
		-- 将选中的己方怪兽变成表侧攻击表示；若变更失败或该怪兽不是「鬼计」则不再进行后续处理。
		if Duel.ChangePosition(tc,POS_FACEUP_ATTACK)==0 or not tc:IsSetCard(0x8d) then return end
		-- 提示玩家选择表侧表示的卡，用于选择对方场上的表侧怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 从对方场上选择1只表侧表示且可以变为里侧的怪兽。
		local g=Duel.SelectMatchingCard(tp,c37055344.filter4,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的对方怪兽变成里侧守备表示。
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end
