--EMラディッシュ・ホース
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，以对方场上1只表侧表示怪兽和自己场上1只「娱乐伙伴」怪兽为对象才能发动。那只对方怪兽的攻击力下降那只自己的「娱乐伙伴」怪兽的攻击力数值。
-- 【怪兽效果】
-- ①：特殊召唤的怪兽在对方场上存在，对方场上的怪兽数量是自己场上的怪兽数量以上的场合，这张卡可以从手卡特殊召唤。
-- ②：1回合1次，以对方场上1只表侧表示怪兽和自己场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只对方怪兽的攻击力下降这张卡的攻击力数值，那只自己怪兽的攻击力上升这张卡的攻击力数值。
function c71863024.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽和自己场上1只「娱乐伙伴」怪兽为对象才能发动。那只对方怪兽的攻击力下降那只自己的「娱乐伙伴」怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c71863024.atktg)
	e1:SetOperation(c71863024.atkop)
	c:RegisterEffect(e1)
	-- ①：特殊召唤的怪兽在对方场上存在，对方场上的怪兽数量是自己场上的怪兽数量以上的场合，这张卡可以从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71863024,0))  --"这张卡特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c71863024.hspcon)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以对方场上1只表侧表示怪兽和自己场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只对方怪兽的攻击力下降这张卡的攻击力数值，那只自己怪兽的攻击力上升这张卡的攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c71863024.atktg2)
	e3:SetOperation(c71863024.atkop2)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示、攻击力大于0的「娱乐伙伴」怪兽
function c71863024.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:GetAttack()>0
end
-- 灵摆效果①的靶向（Target）函数，用于检测和选择效果对象
function c71863024.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否存在表侧表示且攻击力大于0的「娱乐伙伴」怪兽
		and Duel.IsExistingTarget(c71863024.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择对方场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 提示玩家选择自己场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上1只表侧表示的「娱乐伙伴」怪兽作为效果对象
	Duel.SelectTarget(tp,c71863024.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 灵摆效果①的执行（Operation）函数，处理攻击力下降
function c71863024.atkop(e,tp,eg,ep,ev,re,r,rp)
	local hc=e:GetLabelObject()
	-- 获取当前连锁中被选择为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	if hc:IsFaceup() and hc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 那只对方怪兽的攻击力下降那只自己的「娱乐伙伴」怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		hc:RegisterEffect(e1)
	end
end
-- 过滤特殊召唤的怪兽
function c71863024.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 怪兽效果①的特殊召唤条件判定函数
function c71863024.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c71863024.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 检查对方场上的怪兽数量是否在自己场上的怪兽数量以上
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 怪兽效果②的靶向（Target）函数，用于检测和选择效果对象
function c71863024.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否存在表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择对方场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 提示玩家选择自己场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 怪兽效果②的执行（Operation）函数，处理攻击力升降
function c71863024.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hc=e:GetLabelObject()
	-- 获取当前连锁中被选择为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	if hc:IsFaceup() and hc:IsRelateToEffect(e) and not hc:IsImmuneToEffect(e) then
		local atk=c:GetAttack()
		-- 那只对方怪兽的攻击力下降这张卡的攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		hc:RegisterEffect(e1)
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			-- 那只自己怪兽的攻击力上升这张卡的攻击力数值
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
	end
end
