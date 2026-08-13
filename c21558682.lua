--ディフェンド・スライム
-- 效果：
-- 对方的怪兽对自己的怪兽攻击的时候，自己的场上的「再生史莱姆」表侧表示存在的场合，攻击对象移去「再生史莱姆」。
function c21558682.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方的怪兽对自己的怪兽攻击的时候，自己的场上的「再生史莱姆」表侧表示存在的场合，攻击对象移去「再生史莱姆」。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21558682,0))  --"攻击对象转移"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c21558682.atkcon)
	e2:SetTarget(c21558682.atktg)
	e2:SetOperation(c21558682.atkop)
	c:RegisterEffect(e2)
end
-- 效果发动条件判定：仅在对方回合且存在攻击对象（即对方的怪兽对自己怪兽进行攻击宣言）时满足。
function c21558682.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否为对方回合且当前存在攻击对象；两者同时成立时才能发动本效果。
	return tp~=Duel.GetTurnPlayer() and Duel.GetAttackTarget()~=nil
end
-- 筛选可作为转移对象的卡：须为表侧表示、卡名是「再生史莱姆」（卡号31709826）、并且位于攻击怪兽的可攻击目标范围内。
function c21558682.filter(c,atg)
	return c:IsFaceup() and c:IsCode(31709826) and atg:IsContains(c)
end
-- 取对象处理：从自己场上表侧表示的「再生史莱姆」中选择一张作为攻击转移对象，且不能选择当前已被攻击的怪兽。
function c21558682.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取攻击怪兽当前可以攻击的目标集合，用于判断哪些「再生史莱姆」可以被选为新的攻击对象。
	local atg=Duel.GetAttacker():GetAttackableTarget()
	-- 获取当前被攻击的己方怪兽，用于排除该怪兽不能作为转移对象。
	local at=Duel.GetAttackTarget()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc~=at and c21558682.filter(chkc,atg) end
	-- 检查自己场上是否存在满足条件的「再生史莱姆」可作为攻击对象；存在则效果可以发动。
	if chk==0 then return Duel.IsExistingTarget(c21558682.filter,tp,LOCATION_MZONE,0,1,at,atg) end
	-- 向己方玩家发送选择对象的提示，提示内容为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让己方玩家从符合条件的「再生史莱姆」中选择1张，并将其登记为本效果的对象。
	Duel.SelectTarget(tp,c21558682.filter,tp,LOCATION_MZONE,0,1,1,at,atg)
end
-- 效果处理：若选择的「再生史莱姆」仍合法且攻击怪兽不免疫此效果，则将攻击对象转移为这张「再生史莱姆」。
function c21558682.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果处理时选择的「再生史莱姆」。
	local tc=Duel.GetFirstTarget()
	-- 确认所选对象仍然表侧表示、与本效果仍有联系，且攻击怪兽不免疫此效果，满足条件才执行转移。
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		-- 把当前攻击对象改为这张「再生史莱姆」，实现攻击对象转移。
		Duel.ChangeAttackTarget(tc)
	end
end
