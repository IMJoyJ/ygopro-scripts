--シンクロ・ギフト
-- 效果：
-- 选择自己场上表侧表示存在的1只同调怪兽和1只同调怪兽以外的怪兽发动。直到这个回合的结束阶段时，选择的同调怪兽的攻击力变成0，另1只怪兽的攻击力上升那个原本攻击力数值。
function c52128900.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只同调怪兽和1只同调怪兽以外的怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52128900.target)
	e1:SetOperation(c52128900.activate)
	c:RegisterEffect(e1)
end
-- 定义filter1：筛选满足aux.nzatk（表侧表示且攻击力不为0）且为同调怪兽的怪兽，作为第1个选择对象。
function c52128900.filter1(c)
	-- 该条件要求怪兽是表侧表示、当前攻击力不为0且具有同调怪兽类型（TYPE_SYNCHRO）。
	return aux.nzatk(c) and c:IsType(TYPE_SYNCHRO)
end
-- 定义filter2：筛选表侧表示且不是同调怪兽的怪兽，作为第2个选择对象。
function c52128900.filter2(c)
	return c:IsFaceup() and not c:IsType(TYPE_SYNCHRO)
end
-- 目标选择函数：若chkc不为nil则不接受该指定；在发动条件检查时，必须从自己场上主要怪兽区存在至少1只同调怪兽和至少1只非同调怪兽才能发动；满足后进入选择阶段。
function c52128900.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查（chk==0）：确认自己场上主要怪兽区存在至少1只满足filter1的同调怪兽可被选择。
	if chk==0 then return Duel.IsExistingTarget(c52128900.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 同时确认自己场上主要怪兽区存在至少1只满足filter2的非同调怪兽可被选择；两个条件同时满足才能发动。
		and Duel.IsExistingTarget(c52128900.filter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 给当前玩家显示选择提示信息，要求选择1只同调怪兽（使用卡片效果文本的第0条字符串）。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(52128900,0))  --"请选择一只同调怪兽"
	-- 让玩家从自己场上主要怪兽区选择1只满足filter1的怪兽，并将其设为这张卡发动时的对象。
	local g1=Duel.SelectTarget(tp,c52128900.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 给当前玩家显示选择提示信息，要求选择1只同调怪兽以外的怪兽（使用卡片效果文本的第1条字符串）。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(52128900,1))  --"请选择1只同调怪兽以外的怪兽"
	-- 让玩家从自己场上主要怪兽区选择1只满足filter2的怪兽，并将其也设为这张卡发动时的对象。
	local g2=Duel.SelectTarget(tp,c52128900.filter2,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
end
-- 效果处理函数：从LabelObject取得target阶段保存的同调怪兽tc1，再通过连锁信息取得对象组；若第一只对象就是tc1则取下一只作为tc2（另一只怪兽）；确认两只怪兽都仍与该效果关联且表侧表示后，对tc2赋予上升攻击力的持续效果，对tc1赋予攻击力变为0的持续效果，均持续到结束阶段。
function c52128900.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	-- 获取当前连锁处理中记录的对象卡组（即发动时选择的那两只怪兽），以便在效果处理时区分另一只怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc1==tc2 then tc2=g:GetNext() end
	if tc1:IsRelateToEffect(e) and tc1:IsFaceup() and tc2:IsRelateToEffect(e) and tc2:IsFaceup() then
		-- 另1只怪兽的攻击力上升那个原本攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc1:GetBaseAttack())
		tc2:RegisterEffect(e1)
		-- 直到这个回合的结束阶段时，选择的同调怪兽的攻击力变成0
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(0)
		tc1:RegisterEffect(e2)
	end
end
