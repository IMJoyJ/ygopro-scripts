--ムカデの進軍
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转的场合，以场上1只其他怪兽为对象才能发动。那只怪兽变成表侧攻击表示或里侧守备表示。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ②：这张卡反转的场合，以场上1只其他怪兽为对象才能发动。那只怪兽变成表侧攻击表示或里侧守备表示。这个卡名的②的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"改变其他怪兽的表现形式"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变这张卡的表现形式"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 过滤场上可以改变表示形式的怪兽（可以转为里侧守备表示、当前为里侧表示或当前为表侧守备表示）
function s.filter(c)
	return c:IsCanTurnSet() or c:IsFacedown() or c:IsPosition(POS_FACEUP_DEFENSE)
end
-- 效果②的对象选择与判定函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查场上是否存在除自身以外、满足表示形式改变条件的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只其他怪兽作为对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 效果②的处理函数，将作为对象的怪兽变成表侧攻击表示或里侧守备表示
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		if tc:IsPosition(POS_FACEUP_DEFENSE) then
			-- 如果对象怪兽是表侧守备表示且可以变成里侧守备表示，则询问玩家是否将其变成里侧守备表示
			if tc:IsCanTurnSet() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把那只怪兽变成里侧守备表示？"
				-- 将对象怪兽变成里侧守备表示
				Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
			else
				-- 将对象怪兽变成表侧攻击表示
				Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
			end
		elseif tc:IsCanTurnSet() then
			-- 将对象怪兽变成里侧守备表示
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		elseif tc:IsFacedown() then
			-- 将对象怪兽变成表侧攻击表示
			Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		end
	end
end
-- 效果①的判定与发动准备函数
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息，表示该效果包含改变表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果①的处理函数，将自身变成里侧守备表示
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身变成里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
