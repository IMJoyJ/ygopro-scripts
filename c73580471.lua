--ブラック・ローズ・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤时才能发动。场上的卡全部破坏。
-- ②：1回合1次，从自己墓地把1只植物族怪兽除外，以对方场上1只守备表示怪兽为对象才能发动。那只对方的守备表示怪兽变成表侧攻击表示，那个攻击力直到回合结束时变成0。
function c73580471.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤时才能发动。场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73580471,0))  --"场上卡全部破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c73580471.descon)
	e1:SetTarget(c73580471.destg)
	e1:SetOperation(c73580471.desop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从自己墓地把1只植物族怪兽除外，以对方场上1只守备表示怪兽为对象才能发动。那只对方的守备表示怪兽变成表侧攻击表示，那个攻击力直到回合结束时变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73580471,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c73580471.poscost)
	e2:SetTarget(c73580471.postg)
	e2:SetOperation(c73580471.posop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否通过同调召唤的方式特殊召唤成功，作为①效果的发动条件
function c73580471.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果的目标过滤与操作信息设置：检查场上是否存在卡片，并设置破坏场上所有卡的操作信息
function c73580471.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查双方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取双方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置效果处理的操作信息为：破坏获取到的所有场上的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果的处理：获取双方场上的所有卡，若存在则将其全部破坏
function c73580471.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 因效果破坏获取到的所有场上的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤自己墓地中可以作为发动成本除外的植物族怪兽
function c73580471.costfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动成本：从自己墓地选择1只植物族怪兽除外
function c73580471.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自己墓地是否存在可作为成本除外的植物族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c73580471.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的植物族怪兽
	local g=Duel.SelectMatchingCard(tp,c73580471.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动成本
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标过滤与对象选择：选择对方场上1只守备表示怪兽作为效果对象，并设置改变表示形式的操作信息
function c73580471.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsDefensePos() end
	-- 在效果发动阶段，检查对方场上是否存在可以作为对象的守备表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择守备表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEFENSE)  --"请选择守备表示的怪兽"
	-- 让玩家选择对方场上1只守备表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsDefensePos,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的操作信息为：改变所选怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果的处理：将作为对象的怪兽变成表侧攻击表示，并使其攻击力直到回合结束时变成0
function c73580471.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc or tc:IsAttackPos() or not tc:IsRelateToEffect(e) then return end
	-- 将作为对象的怪兽变成表侧攻击表示，若改变表示形式失败则结束处理
	if Duel.ChangePosition(tc,POS_FACEUP_ATTACK)==0 then return end
	-- 那个攻击力直到回合结束时变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(0)
	tc:RegisterEffect(e1)
end
