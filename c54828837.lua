--失楽の霹靂
-- 效果：
-- ①：「降雷皇 哈蒙」用自身的方法特殊召唤的场合，也能把自己场上的里侧表示的魔法卡送去墓地。
-- ②：1回合1次，自己场上有「降雷皇 哈蒙」攻击表示存在的场合，可以把对方发动的魔法·陷阱卡的效果无效。那之后，选自己场上1只「降雷皇 哈蒙」变成守备表示。
-- ③：自己场上的表侧表示的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中任意种从场上离开的场合发动。这个回合，自己受到的全部伤害变成0。
function c54828837.initial_effect(c)
	-- 注册卡片记有「神炎皇 乌利亚」、「降雷皇 哈蒙」、「幻魔皇 拉比艾尔」的卡名
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：「降雷皇 哈蒙」用自身的方法特殊召唤的场合，也能把自己场上的里侧表示的魔法卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(54828837)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己场上有「降雷皇 哈蒙」攻击表示存在的场合，可以把对方发动的魔法·陷阱卡的效果无效。那之后，选自己场上1只「降雷皇 哈蒙」变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c54828837.negcon)
	e3:SetOperation(c54828837.negop)
	c:RegisterEffect(e3)
	-- ③：自己场上的表侧表示的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中任意种从场上离开的场合发动。这个回合，自己受到的全部伤害变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(54828837,1))  --"全部伤害变成0"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c54828837.protcon)
	e4:SetOperation(c54828837.protop)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示、攻击表示的「降雷皇 哈蒙」
function c54828837.cfilter(c)
	return c:IsFaceup() and c:IsCode(32491822) and c:IsAttackPos()
end
-- 效果②的判定条件：自己场上有攻击表示的「降雷皇 哈蒙」存在，对方发动魔陷的效果，该效果可以被无效，且本回合尚未发动过此效果
function c54828837.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示且攻击表示的「降雷皇 哈蒙」
	return Duel.IsExistingMatchingCard(c54828837.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		-- 检查该连锁的效果是否可以被无效，且当前未被无效
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
		and e:GetHandler():GetFlagEffect(54828837)<=0
end
-- 效果②的效果处理：询问玩家是否无效效果，若无效成功且场上仍有符合条件的「降雷皇 哈蒙」，则将其中的1只变成守备表示
function c54828837.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 询问玩家是否发动该无效效果
	if Duel.SelectEffectYesNo(tp,c) then
		-- 提示发动了卡片「失乐之霹雳」的效果
		Duel.Hint(HINT_CARD,0,54828837)
		-- 若成功无效该效果，且自己场上仍存在表侧表示且攻击表示的「降雷皇 哈蒙」
		if Duel.NegateEffect(ev) and Duel.IsExistingMatchingCard(c54828837.cfilter,tp,LOCATION_MZONE,0,1,nil) then
			-- 中断当前效果，使后续的改变表示形式处理不与无效效果同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要改变表示形式的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			-- 玩家选择自己场上1只表侧表示且攻击表示的「降雷皇 哈蒙」
			local g=Duel.SelectMatchingCard(tp,c54828837.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
			-- 选中所选的怪兽并向双方玩家展示
			Duel.HintSelection(g)
			-- 将选中的「降雷皇 哈蒙」变成表侧守备表示
			Duel.ChangePosition(g:GetFirst(),POS_FACEUP_DEFENSE)
		end
		c:RegisterFlagEffect(54828837,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤条件：从自己场上离开的表侧表示的「神炎皇 乌利亚」、「降雷皇 哈蒙」或「幻魔皇 拉比艾尔」
function c54828837.protfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and (c:GetPreviousCodeOnField()==32491822 or c:GetPreviousCodeOnField()==6007213 or c:GetPreviousCodeOnField()==69890967)
end
-- 效果③的发动条件：自己场上表侧表示的三幻魔怪兽离场
function c54828837.protcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c54828837.protfilter,1,nil,tp)
end
-- 效果③的效果处理：注册本回合自己受到的全部伤害（包括战斗伤害和效果伤害）变成0的效果
function c54828837.protop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，自己受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使自己受到的战斗和效果伤害变成0的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使自己受到的效果伤害变成0的效果
	Duel.RegisterEffect(e2,tp)
end
