--VS 螺旋流辻風
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「征服斗魂」怪兽为对象才能发动。那只怪兽的表示形式变更。那之后，可以选最多有自己场上的「征服斗魂」怪兽种类数量的对方场上的表侧表示怪兽变成里侧守备表示。
function c91951471.initial_effect(c)
	-- ①：以自己场上1只「征服斗魂」怪兽为对象才能发动。那只怪兽的表示形式变更。那之后，可以选最多有自己场上的「征服斗魂」怪兽种类数量的对方场上的表侧表示怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,91951471+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e1:SetTarget(c91951471.target)
	e1:SetOperation(c91951471.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、属于「征服斗魂」且可以改变表示形式的怪兽
function c91951471.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x195) and c:IsCanChangePosition()
end
-- 效果①的发动准备（检查是否满足发动条件、选择对象并设置操作信息）
function c91951471.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c91951471.filter1(chkc) end
	-- 检查自己场上是否存在至少1只满足条件的「征服斗魂」怪兽
	if chk==0 then return Duel.IsExistingTarget(c91951471.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只表侧表示的「征服斗魂」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c91951471.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表示该效果包含改变表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 过滤自己场上表侧表示的「征服斗魂」怪兽
function c91951471.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x195)
end
-- 过滤对方场上表侧表示且可以变成里侧表示的怪兽
function c91951471.filter3(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果①的处理（改变对象怪兽的表示形式，并可选将对方场上的怪兽变成里侧守备表示）
function c91951471.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsLocation(LOCATION_MZONE)
		-- 改变对象怪兽的表示形式，并确认是否成功改变
		and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0 then
		-- 获取自己场上所有表侧表示的「征服斗魂」怪兽
		local g=Duel.GetMatchingGroup(c91951471.filter2,tp,LOCATION_MZONE,0,nil)
		local num=g:GetClassCount(Card.GetCode)
		-- 获取对方场上所有可以变成里侧守备表示的表侧表示怪兽
		local g2=Duel.GetMatchingGroup(c91951471.filter3,tp,0,LOCATION_MZONE,nil)
		-- 检查双方场上是否存在符合条件的怪兽，并询问玩家是否发动后续将对方怪兽变成里侧守备表示的效果
		if #g>0 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(91951471,1)) then  --"是否选对方怪兽变成里侧守备表示？"
			-- 中断当前效果处理，使后续的改变表示形式处理不与前面的处理同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要改变表示形式的对方怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			local sg=g2:Select(tp,1,num,nil)
			-- 显式展示被选择的对方怪兽
			Duel.HintSelection(sg)
			-- 将选中的对方怪兽变成里侧守备表示
			Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
		end
	end
end
