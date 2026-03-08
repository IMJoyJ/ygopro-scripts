--武神器－イクタ
-- 效果：
-- 自己的主要阶段时，自己场上有名字带有「武神」的怪兽存在的场合，把墓地的这张卡从游戏中除外，选择对方场上表侧攻击表示存在的1只怪兽才能发动。选择的怪兽变成表侧守备表示，那个守备力直到结束阶段时变成0。
function c42551040.initial_effect(c)
	-- 创建一个起动效果，效果描述为“改变表示形式”，分类为改变表示形式，具有取对象属性，效果类型为起动效果，生效位置为墓地，条件为己方场上存在名字带有「武神」的怪兽，费用为将此卡从游戏中除外，对象为对方场上表侧攻击表示存在的1只怪兽，效果处理为改变对象表示形式为表侧守备表示并使其守备力变为0
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42551040,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c42551040.poscon)
	-- 设置效果的发动费用为将此卡从游戏中除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c42551040.postg)
	e1:SetOperation(c42551040.posop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在名字带有「武神」的表侧表示怪兽
function c42551040.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x88)
end
-- 效果发动的条件函数，判断己方场上是否存在名字带有「武神」的表侧表示怪兽
function c42551040.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少1只名字带有「武神」的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c42551040.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断是否为表侧攻击表示且可以改变表示形式的怪兽
function c42551040.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 设置效果的对象选择函数，检查对方场上是否存在满足条件的怪兽并选择其为对象
function c42551040.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c42551040.filter(chkc) end
	-- 检查对方场上是否存在至少1只满足条件的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c42551040.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择要改变表示形式的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上满足条件的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c42551040.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理时的操作信息，确定将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理函数，将选择的怪兽改变表示形式为表侧守备表示，并在结束阶段时将其守备力变为0
function c42551040.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍然存在于场上且成功改变表示形式为表侧守备表示
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
		-- 为对象怪兽设置一个永续效果，使其守备力在结束阶段时变为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
