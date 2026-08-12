--スキヤナー
-- 效果：
-- 选择从游戏中除外的1只对方怪兽发动。这张卡直到结束阶段时当作和选择怪兽同名卡使用，变成和选择怪兽相同属性·等级·攻击力·守备力。这个效果1回合只能使用1次。这个效果适用的这张卡从场上离开的场合，从游戏中除外。
function c75198893.initial_effect(c)
	-- 选择从游戏中除外的1只对方怪兽发动。这张卡直到结束阶段时当作和选择怪兽同名卡使用，变成和选择怪兽相同属性·等级·攻击力·守备力。这个效果1回合只能使用1次。这个效果适用的这张卡从场上离开的场合，从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75198893,0))  --"卡名变化"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c75198893.target)
	e1:SetOperation(c75198893.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：筛选表侧表示、有等级且未被禁止使用的怪兽卡
function c75198893.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(0) and not c:IsForbidden()
end
-- 效果的发动阶段处理：进行对象合法性检测并选择目标怪兽
function c75198893.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(1-tp) and c75198893.filter(chkc) end
	-- 在发动阶段，检查对方除外区是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c75198893.filter,tp,0,LOCATION_REMOVED,1,nil) end
	-- 在客户端显示提示信息，提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方除外区1只满足条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c75198893.filter,tp,0,LOCATION_REMOVED,1,1,nil)
end
-- 效果的处理阶段：使自身复制目标怪兽的卡名、攻防、属性、等级，并适用离场除外的效果
function c75198893.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动阶段选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		local ba=tc:GetBaseAttack()
		local bd=tc:GetBaseDefense()
		local at=tc:GetAttribute()
		local lv=tc:GetLevel()
		-- 这张卡直到结束阶段时当作和选择怪兽同名卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(ba)
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e3:SetValue(bd)
		c:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e4:SetValue(at)
		c:RegisterEffect(e4)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CHANGE_LEVEL)
		e5:SetValue(lv)
		c:RegisterEffect(e5)
		-- 这个效果适用的这张卡从场上离开的场合，从游戏中除外。
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e6:SetReset(RESET_EVENT+RESETS_REDIRECT+RESET_PHASE+PHASE_END)
		e6:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e6)
	end
end
