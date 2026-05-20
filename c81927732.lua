--RR－レヴォリューション・ファルコン
-- 效果：
-- 鸟兽族6星怪兽×3
-- ①：把这张卡1个超量素材取除才能发动。这个回合，这张卡可以向对方怪兽全部各作1次攻击。
-- ②：这张卡和特殊召唤的表侧表示怪兽进行战斗的伤害步骤开始时发动。那只怪兽的攻击力·守备力变成0。
-- ③：这张卡有「急袭猛禽」超量怪兽在作为超量素材的场合，得到以下效果。
-- ●1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，给与对方那个攻击力一半数值的伤害。
function c81927732.initial_effect(c)
	-- 设置XYZ召唤手续：鸟兽族6星怪兽×3
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WINDBEAST),6,3)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。这个回合，这张卡可以向对方怪兽全部各作1次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81927732,0))  --"多次攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c81927732.condition)
	e1:SetCost(c81927732.cost)
	e1:SetOperation(c81927732.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡和特殊召唤的表侧表示怪兽进行战斗的伤害步骤开始时发动。那只怪兽的攻击力·守备力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81927732,2))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c81927732.adcon)
	e2:SetOperation(c81927732.adop)
	c:RegisterEffect(e2)
	-- ③：这张卡有「急袭猛禽」超量怪兽在作为超量素材的场合，得到以下效果。●1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，给与对方那个攻击力一半数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81927732,1))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c81927732.descon)
	e3:SetTarget(c81927732.destg)
	e3:SetOperation(c81927732.desop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定函数
function c81927732.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家能否进入战斗阶段，且自身尚未获得向全部怪兽攻击的效果
	return Duel.IsAbleToEnterBP() and not e:GetHandler():IsHasEffect(EFFECT_ATTACK_ALL)
end
-- 效果①的发动代价：取除这张卡的1个超量素材
function c81927732.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的处理：给这张卡赋予可以向对方全部怪兽各作1次攻击的效果
function c81927732.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这个回合，这张卡可以向对方怪兽全部各作1次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件判定：与特殊召唤的表侧表示怪兽进行战斗
function c81927732.adcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsFaceup() and bc:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果②的处理：将进行战斗的对方怪兽的攻击力和守备力变成0
function c81927732.adop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 那只怪兽的攻击力·守备力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		bc:RegisterEffect(e2)
	end
end
-- 过滤条件：属于「急袭猛禽」且是超量怪兽
function c81927732.filter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ)
end
-- 效果③的发动条件判定：这张卡有「急袭猛禽」超量怪兽在作为超量素材
function c81927732.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(c81927732.filter,1,nil)
end
-- 效果③的对象选择与效果分类注册
function c81927732.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 判定对方场上是否存在可以作为对象破坏的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息：包含破坏选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息：包含给与对方该怪兽攻击力一半数值伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(g:GetFirst():GetAttack()/2))
end
-- 效果③的处理：破坏选定的怪兽，并给与对方其攻击力一半数值的伤害
function c81927732.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选定的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local dam=math.floor(tc:GetAttack()/2)
		if dam<0 or tc:IsFacedown() then dam=0 end
		-- 尝试破坏该怪兽，若成功破坏则执行后续伤害处理
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给与对方该怪兽攻击力一半数值的伤害
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
