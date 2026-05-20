--始原竜プライマル・ドラゴン
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的战斗发生的对对方的战斗伤害变成0。
-- ②：从自己墓地把1只龙族怪兽除外才能发动。这张卡的攻击力·守备力直到下个回合的结束时上升除外的怪兽的攻击力数值。
-- ③：这张卡被解放的场合，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
function c64025981.initial_effect(c)
	-- ①：这张卡的战斗发生的对对方的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把1只龙族怪兽除外才能发动。这张卡的攻击力·守备力直到下个回合的结束时上升除外的怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetDescription(aux.Stringid(64025981,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,64025981)
	e2:SetCost(c64025981.atkcost)
	e2:SetOperation(c64025981.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡被解放的场合，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64025981,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,64025982)
	e3:SetCondition(c64025981.condition)
	e3:SetTarget(c64025981.target)
	e3:SetOperation(c64025981.operation)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中攻击力大于0且可以作为代价除外的龙族怪兽
function c64025981.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:GetAttack()>0 and c:IsAbleToRemoveAsCost()
end
-- 效果②的代价处理：从自己墓地将1只龙族怪兽除外，并记录其攻击力
function c64025981.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足过滤条件的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c64025981.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地中1只满足过滤条件的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c64025981.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetAttack())
end
-- 效果②的实际处理：使这张卡的攻击力·守备力直到下个回合的结束时上升除外怪兽的攻击力数值
function c64025981.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力·守备力直到下个回合的结束时上升除外的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
-- 效果③的发动条件：必须在自己的回合，且处于可以进行战斗相关操作的时点
function c64025981.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为自己回合，且是否处于可以进入或已经处于战斗阶段的时点
	return Duel.GetTurnPlayer()==tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤场上表侧表示且未获得追加攻击效果的怪兽
function c64025981.filter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 效果③的对象选择：以自己场上1只表侧表示怪兽为对象
function c64025981.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c64025981.filter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c64025981.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c64025981.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果③的实际处理：使作为对象的怪兽在同1次的战斗阶段中可以作2次攻击
function c64025981.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
