--ダイガスタ・ファルコス
-- 效果：
-- 调整＋调整以外的名字带有「薰风」的怪兽1只以上
-- 这张卡同调召唤成功时，场上表侧表示存在的名字带有「薰风」的全部怪兽的攻击力上升600。
function c34109611.initial_effect(c)
	-- 设置这张卡的同调召唤手续：调整1只＋调整以外的名字带有「薰风」的怪兽1只以上，且调整以外的怪兽需满足「薰风」字段。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x10),1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，场上表侧表示存在的名字带有「薰风」的全部怪兽的攻击力上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34109611,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c34109611.condition)
	e1:SetOperation(c34109611.operation)
	c:RegisterEffect(e1)
end
-- 该诱发效果的发动条件：这张卡以同调召唤方式特殊召唤成功。
function c34109611.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤器，筛选表侧表示且名字带有「薰风」（0x10）的怪兽。
function c34109611.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x10)
end
-- 效果处理：检索场上全部表侧表示的名字带有「薰风」的怪兽，给每只怪兽赋予不可无效的600点攻击力上升效果，该效果在怪兽离场等标准重置时消失。
function c34109611.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得双方场上主要怪兽区域中所有满足 c34109611.filter 条件的怪兽集合。
	local g=Duel.GetMatchingGroup(c34109611.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 场上表侧表示存在的名字带有「薰风」的全部怪兽的攻击力上升600。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(600)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
