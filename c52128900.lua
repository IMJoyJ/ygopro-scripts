--シンクロ・ギフト
-- 效果：
-- 选择自己场上表侧表示存在的1只同调怪兽和1只同调怪兽以外的怪兽发动。直到这个回合的结束阶段时，选择的同调怪兽的攻击力变成0，另1只怪兽的攻击力上升那个原本攻击力数值。
function c52128900.initial_effect(c)
	-- 创建一张永续魔法卡效果，用于处理同调礼物的发动与处理
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52128900.target)
	e1:SetOperation(c52128900.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择场上表侧表示且攻击力不为0的同调怪兽
function c52128900.filter1(c)
	-- 满足条件：表侧表示且攻击力大于0，并且是同调怪兽类型
	return aux.nzatk(c) and c:IsType(TYPE_SYNCHRO)
end
-- 过滤函数：选择场上表侧表示的非同调怪兽
function c52128900.filter2(c)
	return c:IsFaceup() and not c:IsType(TYPE_SYNCHRO)
end
-- 判断是否能发动此效果，需要在己方场上存在符合条件的同调怪兽和非同调怪兽
function c52128900.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否存在满足filter1条件的怪兽（即表侧表示且攻击力不为0的同调怪兽）
	if chk==0 then return Duel.IsExistingTarget(c52128900.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查是否存在满足filter2条件的怪兽（即表侧表示的非同调怪兽）
		and Duel.IsExistingTarget(c52128900.filter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择一只同调怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(52128900,0))  --"请选择一只同调怪兽"
	-- 从己方场上选择一只满足filter1条件的怪兽作为目标
	local g1=Duel.SelectTarget(tp,c52128900.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择一只非同调怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(52128900,1))  --"请选择1只同调怪兽以外的怪兽"
	-- 从己方场上选择一只满足filter2条件的怪兽作为目标
	local g2=Duel.SelectTarget(tp,c52128900.filter2,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
end
-- 处理效果发动后的具体操作，包括设置两个效果来改变攻击力
function c52128900.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	-- 获取当前连锁中被选择的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc1==tc2 then tc2=g:GetNext() end
	if tc1:IsRelateToEffect(e) and tc1:IsFaceup() and tc2:IsRelateToEffect(e) and tc2:IsFaceup() then
		-- 为第二只选中的怪兽增加攻击力，数值等于第一只怪兽的原本攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc1:GetBaseAttack())
		tc2:RegisterEffect(e1)
		-- 将第一只选中的怪兽的攻击力设为0
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(0)
		tc1:RegisterEffect(e2)
	end
end
