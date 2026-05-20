--武神決戦
-- 效果：
-- 选择场上1只名字带有「武神」的怪兽才能发动。这个回合选择的怪兽战斗破坏持有那只怪兽的原本攻击力以上的攻击力的怪兽的场合，破坏的那只怪兽除外，再把那些同名怪兽从对方的手卡·卡组·额外卡组·墓地全部除外。
function c55599882.initial_effect(c)
	-- 选择场上1只名字带有「武神」的怪兽才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c55599882.target)
	e1:SetOperation(c55599882.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示的「武神」怪兽
function c55599882.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x88)
end
-- 效果发动时的对象选择与合法性检测
function c55599882.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c55599882.filter(chkc) end
	-- 检查场上是否存在可以作为目标的表侧表示「武神」怪兽
	if chk==0 then return Duel.IsExistingTarget(c55599882.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的「武神」怪兽作为效果对象
	Duel.SelectTarget(tp,c55599882.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 魔法卡发动时的效果处理，给目标怪兽添加战斗破坏怪兽时触发的诱发效果
function c55599882.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的「武神」怪兽目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 这个回合选择的怪兽战斗破坏持有那只怪兽的原本攻击力以上的攻击力的怪兽的场合，破坏的那只怪兽除外，再把那些同名怪兽从对方的手卡·卡组·额外卡组·墓地全部除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(55599882,0))  --"除外"
		e1:SetCategory(CATEGORY_REMOVE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetTarget(c55599882.rmtg)
		e1:SetOperation(c55599882.rmop)
		e1:SetReset(RESET_EVENT+0x1620000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 检查被战斗破坏的怪兽是否满足除外条件（在墓地、因战斗破坏、是怪兽、攻击力大于等于「武神」怪兽的原本攻击力、且可以被除外）
function c55599882.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE) and bc:IsType(TYPE_MONSTER)
		and c:GetBaseAttack()<=bc:GetAttack() and bc:IsAbleToRemove() end
	-- 设置效果处理信息为除外被战斗破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
-- 过滤对方手牌、卡组、额外卡组、墓地中与被破坏怪兽同名且可以除外的怪兽卡
function c55599882.rmfilter(c,code)
	return c:IsCode(code) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 战斗破坏触发效果的实际处理：除外被破坏的怪兽，并除外对方手牌、卡组、额外卡组、墓地的同名怪兽
function c55599882.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	-- 将被战斗破坏的怪兽表侧表示除外，若除外失败则不处理后续效果
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==0 then return end
	-- 获取对方手卡、卡组、额外卡组、墓地中所有与被破坏怪兽同名的怪兽
	local g=Duel.GetMatchingGroup(c55599882.rmfilter,tp,0,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,nil,tc:GetCode())
	if g:GetCount()>0 then
		-- 中断当前效果处理，使后续的同名卡除外处理不与前一个除外处理同时进行
		Duel.BreakEffect()
		-- 将对方手卡、卡组、额外卡组、墓地的同名怪兽全部表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
