--武神器－イクタ
-- 效果：
-- 自己的主要阶段时，自己场上有名字带有「武神」的怪兽存在的场合，把墓地的这张卡从游戏中除外，选择对方场上表侧攻击表示存在的1只怪兽才能发动。选择的怪兽变成表侧守备表示，那个守备力直到结束阶段时变成0。
function c42551040.initial_effect(c)
	-- 自己的主要阶段时，自己场上有名字带有「武神」的怪兽存在的场合，把墓地的这张卡从游戏中除外，选择对方场上表侧攻击表示存在的1只怪兽才能发动。选择的怪兽变成表侧守备表示，那个守备力直到结束阶段时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42551040,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c42551040.poscon)
	-- 将发动代价设置为把墓地中的这张卡从游戏中除外（作为COST）。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c42551040.postg)
	e1:SetOperation(c42551040.posop)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断怪兽是否为表侧表示且拥有「武神」字段（0x88），用于检查自己场上的武神怪兽。
function c42551040.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x88)
end
-- 发动条件函数：自己场上有表侧表示且名字带有「武神」的怪兽存在。
function c42551040.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（主要怪兽区）是否存在至少1只满足过滤条件（表侧表示且为「武神」字段）的怪兽，作为发动条件。
	return Duel.IsExistingMatchingCard(c42551040.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 选择对象的过滤函数：对方场上表侧攻击表示、且能够被效果改变表示形式的怪兽。
function c42551040.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 目标处理函数：效果发动时确认有合法对象后，从对方场上选择1只表侧攻击表示且可变更表示形式的怪兽，并设置操作信息为改变表示形式。
function c42551040.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c42551040.filter(chkc) end
	-- 效果发动的合法性检查（chk==0）：确认对方场上存在至少1只符合条件的表侧攻击表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c42551040.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要改变表示形式的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 由玩家从对方场上选择1只符合条件的表侧攻击表示怪兽，并将其记录为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c42551040.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为改变表示形式（CATEGORY_POSITION），对象为已选怪兽g，数量1，用于连锁反应等相关判定。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：获取对象怪兽并将其变更为表侧守备表示；若变更成功，则赋予该怪兽守备力为0的持续效果，直到结束阶段为止。
function c42551040.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中该效果所选择的对方怪兽（对象卡）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍然与该效果关联，然后将其变更为表侧守备表示；若变更成功，则继续执行后续赋予守备力0的效果。
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
		-- 那个守备力直到结束阶段时变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
