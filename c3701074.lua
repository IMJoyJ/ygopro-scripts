--ダーク・キュア
-- 效果：
-- 对方把怪兽召唤·反转召唤·特殊召唤时，对方回复那些怪兽的攻击力一半数值的基本分。
function c3701074.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方把怪兽召唤·反转召唤·特殊召唤时，对方回复那些怪兽的攻击力一半数值的基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3701074,0))  --"回复LP"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c3701074.rectg1)
	e2:SetOperation(c3701074.recop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 对方把怪兽召唤·反转召唤·特殊召唤时，对方回复那些怪兽的攻击力一半数值的基本分。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(3701074,0))  --"回复LP"
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(c3701074.rectg2)
	e4:SetOperation(c3701074.recop2)
	c:RegisterEffect(e4)
end
-- 判断效果是否能发动，确保是对方玩家触发的召唤成功事件
function c3701074.rectg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return rp==1-tp end
	-- 将触发效果的怪兽设为连锁处理对象
	Duel.SetTargetCard(eg)
	-- 设置效果处理信息为回复LP，目标玩家为对方
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,0)
end
-- 处理通常召唤成功时的效果，将对方怪兽攻击力的一半回复给对方
function c3701074.recop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local rec=math.ceil(tc:GetAttack()/2)
		-- 使对方玩家回复指定数值的基本分
		Duel.Recover(1-tp,rec,REASON_EFFECT)
	end
end
-- 过滤满足条件的怪兽，必须是对方玩家在主怪兽区召唤的正面表示怪兽
function c3701074.filter(c,e,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp)
		and (not e or c:IsRelateToEffect(e))
end
-- 判断效果是否能发动，确保存在对方玩家召唤的怪兽
function c3701074.rectg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c3701074.filter,1,nil,nil,tp) end
	-- 将触发效果的怪兽设为连锁处理对象
	Duel.SetTargetCard(eg)
	-- 设置效果处理信息为回复LP，目标玩家为对方
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,0)
end
-- 处理特殊召唤成功时的效果，若有多只怪兽则选择一只，将该怪兽攻击力的一半回复给对方
function c3701074.recop2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c3701074.filter,nil,e,tp)
	if g:GetCount()>0 then
		if g:GetCount()>1 then
			-- 向玩家提示选择效果的对象
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
			g=g:Select(tp,1,1,nil)
		end
		-- 使对方玩家回复指定数值的基本分
		Duel.Recover(1-tp,math.ceil(g:GetFirst():GetAttack()/2),REASON_EFFECT)
	end
end
