--召喚獣ライディーン
-- 效果：
-- 「召唤师 阿莱斯特」＋风属性怪兽
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。这个效果在对方回合也能发动。
function c49513164.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为86120751的怪兽和1个风属性怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_WIND),1,true,true)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49513164,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c49513164.settg)
	e1:SetOperation(c49513164.setop)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的怪兽：表侧表示且可以变为盖放表示
function c49513164.setfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 设置效果的目标选择函数，用于选择场上1只满足条件的怪兽作为对象
function c49513164.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c49513164.setfilter(chkc) end
	-- 检查是否满足发动条件：场上存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c49513164.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的目标怪兽，数量为1只
	local g=Duel.SelectTarget(tp,c49513164.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定效果处理时将改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 设置效果的处理函数，用于执行将目标怪兽变为里侧守备表示的操作
function c49513164.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
