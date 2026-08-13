--マドルチェ・マナー
-- 效果：
-- 选择自己墓地1只名字带有「魔偶甜点」的怪兽回到卡组，自己场上存在的全部名字带有「魔偶甜点」的怪兽的攻击力·守备力上升800。那之后，可以选自己墓地1只怪兽回到卡组。
function c12940613.initial_effect(c)
	-- 选择自己墓地1只名字带有「魔偶甜点」的怪兽回到卡组，自己场上存在的全部名字带有「魔偶甜点」的怪兽的攻击力·守备力上升800。那之后，可以选自己墓地1只怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设定效果发动条件：不能在伤害计算时发动（伤害步骤中仅限伤害计算前）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c12940613.target)
	e1:SetOperation(c12940613.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：筛选自己场上表侧表示且属于「魔偶甜点」（0x71）的怪兽，作为攻击力·守备力上升的对象。
function c12940613.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x71)
end
-- 定义过滤函数：筛选自己墓地中名字带有「魔偶甜点」的怪兽且可以返回卡组的卡片，作为第一个「回到卡组」效果的对象候选。
function c12940613.tdfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x71) and c:IsAbleToDeck()
end
-- 发动时的目标判定函数：若检查已选对象，则确认该对象是自己墓地中满足条件的「魔偶甜点」怪兽；若检查发动条件，则要求自己场上有表侧表示「魔偶甜点」怪兽且墓地存在可回卡组的「魔偶甜点」怪兽，否则不能发动。
function c12940613.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c12940613.tdfilter1(chkc) end
	-- 发动条件检查：确认自己场上有至少1只表侧表示的名字带有「魔偶甜点」的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c12940613.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 发动条件检查：确认自己墓地存在至少1只可以返回卡组且名字带有「魔偶甜点」的怪兽，并且该卡能成为效果对象。
		and Duel.IsExistingTarget(c12940613.tdfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1只满足条件的「魔偶甜点」怪兽，并设定为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c12940613.tdfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次处理涉及1张卡返回卡组（CATEGORY_TODECK），对象为已选卡组g，供连锁检测等使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 定义过滤函数：筛选自己墓地中任意1只可以返回卡组的怪兽（不要求带「魔偶甜点」），用于追加效果的选择。
function c12940613.tdfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果处理：将对象「魔偶甜点」怪兽返回卡组并洗牌；给自己场上全部表侧表示「魔偶甜点」怪兽攻击力·守备力各上升800；之后可选地让自己墓地1只怪兽返回卡组（询问并处理追加效果）。
function c12940613.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时取对象选择的那张墓地「魔偶甜点」怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将取对象的怪兽以效果原因返回持有者卡组并洗牌（洗牌前暂放卡组底端）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	-- 获取自己场上全部表侧表示的名字带有「魔偶甜点」的怪兽，用于赋予攻击力·守备力上升效果。
	local g=Duel.GetMatchingGroup(c12940613.filter,tp,LOCATION_MZONE,0,nil)
	tc=g:GetFirst()
	if not tc then return end
	while tc do
		-- 对应效果原文：‘自己场上存在的全部名字带有「魔偶甜点」的怪兽的攻击力·守备力上升800。’（当前代码为攻击力部分）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 获取自己墓地中所有可以返回卡组且不受王家长眠之谷影响的怪兽（不限定「魔偶甜点」），作为追加效果的候选集合。
	local dg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c12940613.tdfilter2),tp,LOCATION_GRAVE,0,nil)
	-- 若候选集合非空，则询问玩家是否选择自己墓地1只怪兽返回卡组；选择‘是’则继续进行追加处理。
	if dg:GetCount()~=0 and Duel.SelectYesNo(tp,aux.Stringid(12940613,0)) then  --"是否要选择墓地一只怪兽回到卡组？"
		-- 中断当前效果处理，使后续追加效果视为不同时处理（错开时点）。
		Duel.BreakEffect()
		-- 显示选择提示，提示玩家选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=dg:Select(tp,1,1,nil)
		-- 手动显示被选中的卡的对象动画，并记录这些卡被选为对象（广义），供连锁响应。
		Duel.HintSelection(sg)
		-- 将追加选择的墓地怪兽以效果原因返回持有者卡组并洗牌（洗牌前暂放卡组底端）。
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
