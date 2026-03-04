--BF－漆黒のエルフェン
-- 效果：
-- 自己场上有名字带有「黑羽」的怪兽表侧表示存在的场合，这张卡可以不用解放作召唤。这张卡召唤成功时，可以把对方场上存在的1只怪兽的表示形式改变。
function c11613567.initial_effect(c)
	-- 效果原文：自己场上有名字带有「黑羽」的怪兽表侧表示存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11613567,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c11613567.ntcon)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡召唤成功时，可以把对方场上存在的1只怪兽的表示形式改变。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11613567,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c11613567.target)
	e2:SetOperation(c11613567.operation)
	c:RegisterEffect(e2)
end
-- 检索满足条件的卡片组，用于判断己方场上是否存在名字带有「黑羽」且表侧表示的怪兽。
function c11613567.ntfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- 判断该卡是否满足不需解放的召唤条件，包括等级、场上空位及己方是否存在符合条件的怪兽。
function c11613567.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断该卡等级是否大于等于5且己方场上存在空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断己方场上是否存在至少1只名字带有「黑羽」且表侧表示的怪兽。
		and Duel.IsExistingMatchingCard(c11613567.ntfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 检索满足条件的卡片组，用于判断对方场上是否存在可以改变表示形式的怪兽。
function c11613567.filter(c)
	return c:IsCanChangePosition()
end
-- 设置效果的目标选择函数，用于选择对方场上的怪兽作为目标。
function c11613567.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c11613567.filter(chkc) end
	-- 检查是否满足发动条件，即对方场上是否存在至少1只可以改变表示形式的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c11613567.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	-- 选择对方场上1只可以改变表示形式的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c11613567.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，指定本次效果将改变目标怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 设置效果的处理函数，用于执行改变目标怪兽表示形式的操作。
function c11613567.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽改变为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
