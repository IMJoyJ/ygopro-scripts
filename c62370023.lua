--スノーマン・エフェクト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升那只怪兽以外的自己场上的怪兽的原本攻击力的合计数值。这张卡发动的回合，作为对象的怪兽不能直接攻击。
function c62370023.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升那只怪兽以外的自己场上的怪兽的原本攻击力的合计数值。这张卡发动的回合，作为对象的怪兽不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,62370023+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件（在伤害步骤中，伤害计算前可以发动）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c62370023.target)
	e1:SetOperation(c62370023.activate)
	c:RegisterEffect(e1)
	if not c62370023.global_check then
		c62370023.global_check=true
		-- 这张卡发动的回合，作为对象的怪兽不能直接攻击。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c62370023.checkop)
		-- 注册全局效果，用于记录本回合进行过直接攻击的怪兽
		Duel.RegisterEffect(ge1,0)
	end
end
-- 攻击宣言时的操作：若怪兽进行直接攻击，则给该怪兽添加标记
function c62370023.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 判定进行攻击的怪兽未被添加标记且攻击对象为空（即进行直接攻击）
	if tc:GetFlagEffect(62370023)==0 and Duel.GetAttackTarget()==nil then
		tc:RegisterFlagEffect(62370023,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤自己场上表侧表示、本回合未进行过直接攻击、且场上存在其他可以提供原本攻击力的怪兽
function c62370023.filter(c,tp)
	return c:IsFaceup() and c:GetFlagEffect(62370023)==0
		-- 检查自己场上是否存在除自身以外、原本攻击力大于0的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c62370023.atkfilter,tp,LOCATION_MZONE,0,1,c)
end
-- 过滤自己场上表侧表示且原本攻击力大于0的怪兽
function c62370023.atkfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
-- 效果发动的目标选择与限制处理
function c62370023.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c62370023.filter(chkc,tp) end
	-- 判定是否存在可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c62370023.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c62370023.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 这张卡发动的回合，作为对象的怪兽不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	g:GetFirst():RegisterEffect(e1)
end
-- 效果处理的执行函数
function c62370023.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取除对象怪兽以外的自己场上所有表侧表示且原本攻击力大于0的怪兽
		local g=Duel.GetMatchingGroup(c62370023.atkfilter,tp,LOCATION_MZONE,0,tc)
		local atk=g:GetSum(Card.GetBaseAttack)
		-- 那只怪兽的攻击力直到回合结束时上升那只怪兽以外的自己场上的怪兽的原本攻击力的合计数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
