--BF－漆黒のエルフェン
-- 效果：
-- 自己场上有名字带有「黑羽」的怪兽表侧表示存在的场合，这张卡可以不用解放作召唤。这张卡召唤成功时，可以把对方场上存在的1只怪兽的表示形式改变。
function c11613567.initial_effect(c)
	-- 自己场上有名字带有「黑羽」的怪兽表侧表示存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11613567,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c11613567.ntcon)
	c:RegisterEffect(e1)
	-- 这张卡召唤成功时，可以把对方场上存在的1只怪兽的表示形式改变。
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
-- 判定卡片是否为表侧表示且拥有「黑羽」字段。
function c11613567.ntfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- 召唤规则效果的发动条件：若c为nil（规则询问是否允许通常召唤）返回true；否则需满足不解放召唤、此卡等级5以上、我方主要怪兽区有空位、且我方场上有符合条件的黑羽怪兽。
function c11613567.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查是否允许无解放召唤：要求解放数minc为0，此卡等级不低于5，且我方主要怪兽区有空闲区域。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查我方场上是否存在1张表侧表示且带有「黑羽」字段的怪兽。
		and Duel.IsExistingMatchingCard(c11613567.ntfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 判定该怪兽是否能够被改变表示形式。
function c11613567.filter(c)
	return c:IsCanChangePosition()
end
-- 诱发效果的目标处理：先检查是否指定对象；再判断对方场上是否存在可选目标；有则提示玩家选择，并将选中的对方怪兽设为效果对象，同时登记操作信息为改变表示形式。
function c11613567.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c11613567.filter(chkc) end
	-- 发动时合法性检查：确认对方场上存在至少1只可以改变表示形式并能成为此效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c11613567.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要改变表示形式的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 从对方场上选择1只满足filter条件的怪兽作为效果对象，并自动将其记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c11613567.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将本次操作登记为改变表示形式（CATEGORY_POSITION），对象为已选怪兽g，数量为1，用于连锁判定等后续处理。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理时，取出效果对象；若对象仍与该效果关联，则按规则改变其表示形式。
function c11613567.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中此效果选择的对象（怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 改变对象怪兽的表示形式：若其为表侧攻击表示则变为表侧守备表示，其余表示形式均变为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
