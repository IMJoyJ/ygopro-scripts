--天馬の翼
-- 效果：
-- ①：自己墓地有同盟怪兽存在的场合，以自己场上的「女武神」怪兽任意数量为对象才能发动。这个回合，那些怪兽可以直接攻击。那次直接攻击给与对方的战斗伤害变成一半。
function c72083436.initial_effect(c)
	-- ①：自己墓地有同盟怪兽存在的场合，以自己场上的「女武神」怪兽任意数量为对象才能发动。这个回合，那些怪兽可以直接攻击。那次直接攻击给与对方的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72083436,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c72083436.dacon)
	e1:SetTarget(c72083436.datg)
	e1:SetOperation(c72083436.daop)
	c:RegisterEffect(e1)
end
c72083436.has_text_type=TYPE_UNION
-- 过滤函数：是否为同盟怪兽
function c72083436.cfilter(c)
	return c:IsType(TYPE_UNION)
end
-- 发动条件：自己墓地有同盟怪兽存在，且当前回合可以进入战斗阶段
function c72083436.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在同盟怪兽，且当前回合可以进入战斗阶段
	return Duel.IsExistingMatchingCard(c72083436.cfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsAbleToEnterBP()
end
-- 过滤函数：自己场上表侧表示、未获得直接攻击效果的的「女武神」怪兽
function c72083436.filter(c)
	return c:IsSetCard(0x122) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and not c:IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- 效果的对象选择与判定：选择自己场上任意数量的「女武神」怪兽作为对象
function c72083436.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c72083436.filter(chkc) end
	-- 检查自己场上是否存在至少1张符合条件的「女武神」怪兽
	if chk==0 then return Duel.IsExistingTarget(c72083436.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上符合条件的「女武神」怪兽的数量，作为可选对象的最大数量
	local ct=Duel.GetMatchingGroupCount(c72083436.filter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择1张到最大数量的符合条件的「女武神」怪兽作为对象
	local g=Duel.SelectTarget(tp,c72083436.filter,tp,LOCATION_MZONE,0,1,ct,nil)
end
-- 过滤函数：筛选仍存在于场上且未获得直接攻击效果的对象怪兽
function c72083436.dafilter(c,e)
	return not c:IsHasEffect(EFFECT_DIRECT_ATTACK) and c:IsRelateToEffect(e)
end
-- 效果处理：使选择的对象怪兽在这个回合可以直接攻击，且该直接攻击给与对方的战斗伤害变成一半
function c72083436.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中成为对象的卡片，并过滤出仍符合条件的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c72083436.dafilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 这个回合，那些怪兽可以直接攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那次直接攻击给与对方的战斗伤害变成一半。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e2:SetCondition(c72083436.rdcon)
		-- 设置战斗伤害改变效果：给与对方的战斗伤害变成一半
		e2:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(72083436,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
		tc=g:GetNext()
	end
end
-- 伤害减半效果的适用条件判定
function c72083436.rdcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	-- 判定攻击对象为空（即进行的是直接攻击）
	return Duel.GetAttackTarget()==nil
		-- 且自身直接攻击效果数量小于2（确保是此卡赋予的直接攻击）、对方场上有怪兽存在（若对方场上无怪兽则本就是直接攻击，不触发减半），且带有此效果的标记
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and c:GetFlagEffect(72083436)>0
end
