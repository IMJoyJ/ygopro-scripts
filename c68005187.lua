--クロス・ソウル
-- 效果：
-- 这张卡发动的回合，自己不能进行战斗阶段。
-- ①：以对方场上1只怪兽为对象才能发动。这个回合，自己把怪兽解放的场合，必须作为自己场上1只怪兽的代替而把作为对象的对方怪兽解放。
function c68005187.initial_effect(c)
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：以对方场上1只怪兽为对象才能发动。这个回合，自己把怪兽解放的场合，必须作为自己场上1只怪兽的代替而把作为对象的对方怪兽解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c68005187.cost)
	e1:SetTarget(c68005187.target)
	e1:SetOperation(c68005187.activate)
	c:RegisterEffect(e1)
end
-- 过滤可以被解放的怪兽（排除同时具有不能作为上级召唤和其他解放祭品效果的怪兽）
function c68005187.filter(c)
	return not (c:IsHasEffect(EFFECT_UNRELEASABLE_SUM) and c:IsHasEffect(EFFECT_UNRELEASABLE_NONSUM))
end
-- 发动代价：检查当前阶段并注册本回合不能进行战斗阶段的效果
function c68005187.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在第一阶段（chk==0）判断当前是否不是主要阶段2（如果是主要阶段2则不能发动）
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_MAIN2 end
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：以对方场上1只怪兽为对象才能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能进行战斗阶段的效果注册给发动玩家
	Duel.RegisterEffect(e1,tp)
end
-- 效果发动时的对象选择：选择对方场上1只可以被解放的怪兽作为对象
function c68005187.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c68005187.filter(chkc) end
	-- 在第一阶段（chk==0）判断对方场上是否存在至少1只可以被解放的怪兽
	if chk==0 then return Duel.IsExistingTarget(c68005187.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息：请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只可以被解放的怪兽作为效果的对象
	Duel.SelectTarget(tp,c68005187.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使作为对象的怪兽在自己解放怪兽时必须代替自己场上的怪兽被解放
function c68005187.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 这个回合，自己把怪兽解放的场合，必须作为自己场上1只怪兽的代替而把作为对象的对方怪兽解放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_RELEASE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
