--ダーク・キュア
-- 效果：
-- 对方把怪兽召唤·反转召唤·特殊召唤时，对方回复那些怪兽的攻击力一半数值的基本分。
function c3701074.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方把怪兽召唤·反转召唤时，对方回复那些怪兽的攻击力一半数值的基本分。
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
	-- 对方把怪兽特殊召唤时，对方回复那些怪兽的攻击力一半数值的基本分。
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
-- 该效果的发动条件与对象设定：仅当对方（1-tp）召唤/反转召唤怪兽成功时允许发动；发动时将本次召唤成功的怪兽组eg登记为效果关联对象，并登记回复LP的操作信息。
function c3701074.rectg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return rp==1-tp end
	-- 将本次召唤/反转召唤成功的怪兽组eg设为该效果的对象，建立效果关联，供处理时确认关联关系。
	Duel.SetTargetCard(eg)
	-- 登记本次效果将执行的“回复基本分”操作：预期让对手玩家（1-tp）回复LP，回复量在处理时确定；该信息用于连锁中各类效果检测。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,0)
end
-- 效果处理：取出本次召唤成功且与效果关联的怪兽，若其仍表侧表示在场，则令对手（1-tp）回复该怪兽当前攻击力一半（向上取整）的基本分。
function c3701074.recop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local rec=math.ceil(tc:GetAttack()/2)
		-- 以效果原因令对手玩家（1-tp）回复rec点基本分，即（怪兽攻击力÷2）向上取整的数值。
		Duel.Recover(1-tp,rec,REASON_EFFECT)
	end
end
-- 筛选符合条件的怪兽：表侧表示、位于怪兽区、由对手玩家（1-tp）召唤，且（若传入效果e）仍与该效果有关联。
function c3701074.filter(c,e,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp)
		and (not e or c:IsRelateToEffect(e))
end
-- 特殊召唤成功时的发动条件：确认本次特殊召唤的怪兽组eg中存在至少1只由对方特殊召唤、表侧表示且在怪兽区的怪兽；发动时将eg登记为效果对象，并登记回复LP的操作信息。
function c3701074.rectg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c3701074.filter,1,nil,nil,tp) end
	-- 将本次特殊召唤成功的怪兽组eg设为该效果的对象，建立效果关联，供处理时确认关联关系。
	Duel.SetTargetCard(eg)
	-- 登记本次效果将执行的“回复基本分”操作：预期让对手玩家（1-tp）回复LP，回复量在处理时确定；该信息用于连锁中各类效果检测。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,0)
end
-- 特殊召唤成功后的处理：从本次特殊召唤且符合条件的怪兽中筛出与效果关联者；若数量多于1，则由效果控制者选择其中1只，然后令对方回复该怪兽当前攻击力一半（向上取整）的基本分。
function c3701074.recop2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c3701074.filter,nil,e,tp)
	if g:GetCount()>0 then
		if g:GetCount()>1 then
			-- 向效果控制者tp弹出“请选择效果的对象”提示，要求其从符合条件的怪兽中选择1只。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
			g=g:Select(tp,1,1,nil)
		end
		-- 令对手玩家（1-tp）回复所选怪兽当前攻击力一半（向上取整）的基本分，回复原因视为效果。
		Duel.Recover(1-tp,math.ceil(g:GetFirst():GetAttack()/2),REASON_EFFECT)
	end
end
