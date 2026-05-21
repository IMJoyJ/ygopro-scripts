--剣闘調教
-- 效果：
-- 场上有名字带有「剑斗兽」的怪兽存在的场合，可以从以下效果选择1个发动。
-- ●选择对方场上表侧表示存在的1只怪兽，把表示形式变更。
-- ●选择对方场上1只名字带有「剑斗兽」的怪兽直到结束阶段时得到控制权。
function c9780364.initial_effect(c)
	-- 场上有名字带有「剑斗兽」的怪兽存在的场合，可以从以下效果选择1个发动。●选择对方场上表侧表示存在的1只怪兽，把表示形式变更。●选择对方场上1只名字带有「剑斗兽」的怪兽直到结束阶段时得到控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c9780364.condition)
	e1:SetTarget(c9780364.target)
	e1:SetOperation(c9780364.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「剑斗兽」怪兽
function c9780364.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 发动条件：场上有「剑斗兽」怪兽存在
function c9780364.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1只表侧表示的「剑斗兽」怪兽
	return Duel.IsExistingMatchingCard(c9780364.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤条件：对方场上表侧表示、可以成为效果对象且可以改变表示形式的怪兽
function c9780364.filter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:IsCanChangePosition()
end
-- 过滤条件：对方场上表侧表示、名字带有「剑斗兽」且可以转移控制权的怪兽
function c9780364.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x1019) and c:IsAbleToChangeControler()
end
-- 效果发动时的目标选择与处理分支判定
function c9780364.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 在发动时，检查对方场上是否存在至少1只表侧表示的怪兽作为基本发动条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足表示形式变更条件的怪兽组
	local g=Duel.GetMatchingGroup(c9780364.filter,tp,0,LOCATION_MZONE,nil,e)
	-- 获取对方场上所有满足控制权转移条件的「剑斗兽」怪兽组
	local cg=Duel.GetMatchingGroup(c9780364.filter2,tp,0,LOCATION_MZONE,nil)
	local sel=0
	-- 提示玩家选择要发动的效果分支
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	if cg:GetCount()==0 then
		-- 若对方场上没有可夺取控制权的「剑斗兽」，则强制选择第一个效果（表示形式变更）
		sel=Duel.SelectOption(tp,aux.Stringid(9780364,0))  --"表示形式变更"
	-- 让玩家在「表示形式变更」和「得到控制权」中选择一个效果发动
	else sel=Duel.SelectOption(tp,aux.Stringid(9780364,0),aux.Stringid(9780364,1)) end  --"表示形式变更/得到控制权"
	if sel==0 then
		-- 提示玩家选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽设为效果处理对象
		Duel.SetTargetCard(sg)
		-- 设置当前连锁的操作信息为：改变1只怪兽的表示形式
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	else
		-- 提示玩家选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		local sg=cg:Select(tp,1,1,nil)
		-- 将选中的怪兽设为效果处理对象
		Duel.SetTargetCard(sg)
		-- 设置当前连锁的操作信息为：转移1只怪兽的控制权
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	end
	e:SetLabel(sel)
end
-- 效果处理的执行函数
function c9780364.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的唯一对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if e:GetLabel()==0 then
			-- 将目标怪兽的表示形式变更（表侧攻击表示与表侧守备表示互相转换）
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
		else
			-- 直到结束阶段时得到目标怪兽的控制权
			Duel.GetControl(tc,tp,PHASE_END,1)
		end
	end
end
