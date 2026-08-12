--魔弾－ネバー・エンドルフィン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「魔弹」怪兽为对象才能发动（这张卡发动的回合，作为对象的怪兽不能直接攻击）。那只怪兽的攻击力·守备力直到回合结束时变成原本数值的2倍。
function c67901914.initial_effect(c)
	-- ①：以自己场上1只「魔弹」怪兽为对象才能发动（这张卡发动的回合，作为对象的怪兽不能直接攻击）。那只怪兽的攻击力·守备力直到回合结束时变成原本数值的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,67901914+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件：在伤害步骤中，只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c67901914.target)
	e1:SetOperation(c67901914.activate)
	c:RegisterEffect(e1)
	if not c67901914.global_check then
		c67901914.global_check=true
		-- （这张卡发动的回合，作为对象的怪兽不能直接攻击）
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c67901914.checkop)
		-- 注册全局效果，用于记录本回合进行过直接攻击的怪兽
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局效果操作：当怪兽宣言直接攻击时，给该怪兽添加标记
function c67901914.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 判定怪兽未被标记且攻击对象为空（即进行直接攻击）
	if tc:GetFlagEffect(67901914)==0 and Duel.GetAttackTarget()==nil then
		tc:RegisterFlagEffect(67901914,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤条件：自己场上表侧表示的「魔弹」怪兽，且本回合没有进行过直接攻击
function c67901914.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x108) and c:GetFlagEffect(67901914)==0
end
-- 效果①的发动准备：选择对象，并给对象怪兽施加本回合不能直接攻击的限制
function c67901914.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c67901914.filter(chkc) end
	-- 判定是否存在可以作为对象的怪兽（自己场上表侧表示且本回合未直接攻击过的「魔弹」怪兽）
	if chk==0 then return Duel.IsExistingTarget(c67901914.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的「魔弹」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c67901914.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- （这张卡发动的回合，作为对象的怪兽不能直接攻击）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	g:GetFirst():RegisterEffect(e1)
end
-- 效果①的处理：使作为对象的怪兽的攻击力·守备力直到回合结束时变成原本数值的2倍
function c67901914.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时变成原本数值的2倍
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(tc:GetBaseDefense()*2)
		tc:RegisterEffect(e2)
	end
end
