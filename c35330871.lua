--彼岸の鬼神 ヘルレイカー
-- 效果：
-- 「善恶的彼岸」降临。这张卡不用仪式召唤不能特殊召唤。
-- ①：1回合1次，从手卡把1只「彼岸」怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力·守备力直到回合结束时下降因为这个效果发动而送去墓地的怪兽的各自数值。这个效果在对方回合也能发动。
-- ②：这张卡从场上送去墓地的场合，以场上1张卡为对象才能发动。那张卡送去墓地。
function c35330871.initial_effect(c)
	-- 将卡片「善恶的彼岸」加入到此卡的关联卡片代码列表中
	aux.AddCodeList(c,62835876)
	c:EnableReviveLimit()
	-- 这张卡不用仪式召唤不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 限制此卡只能通过仪式召唤来特殊召唤
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，从手卡把1只「彼岸」怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只对方怪兽的攻击力·守备力直到回合结束时下降因为这个效果发动而送去墓地的怪兽的各自数值。这个效果在对方回合也能发动
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1)
	-- 限制此效果在伤害步骤中只能在伤害计算前发动
	e2:SetCondition(aux.dscon)
	e2:SetCost(c35330871.atkcost)
	e2:SetTarget(c35330871.atktg)
	e2:SetOperation(c35330871.atkop)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上送去墓地的场合，以场上1张卡为对象才能发动。那张卡送去墓地
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c35330871.tgcon)
	e3:SetTarget(c35330871.tgtg)
	e3:SetOperation(c35330871.tgop)
	c:RegisterEffect(e3)
end
-- 过滤手卡中可以作为发动成本送去墓地的「彼岸」怪兽卡
function c35330871.cfilter(c)
	return c:IsSetCard(0xb1) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 定义攻击力·守备力下降效果的发动代价：从手卡将1只「彼岸」怪兽送去墓地，并记录该怪兽以便后续读取其攻守数值
function c35330871.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前，确认自己手卡中是否存在至少1只可送去墓地的「彼岸」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35330871.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择手卡中1只满足条件的「彼岸」怪兽
	local g=Duel.SelectMatchingCard(tp,c35330871.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的「彼岸」怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 定义攻击力·守备力下降效果的对象确认和选择逻辑
function c35330871.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 在效果发动前，确认对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择对方场上1只表侧表示的怪兽作为效果的对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 定义攻击力·守备力下降效果的具体处理逻辑：获取送去墓地的怪兽的攻守数值，并使目标怪兽的攻守下降对应数值
function c35330871.atkop(e,tp,eg,ep,ev,re,r,rp)
	local cc=e:GetLabelObject()
	local atk=cc:GetAttack()
	local def=cc:GetDefense()
	-- 获取当前效果中被选为对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只对方怪兽的攻击力直到回合结束时下降因为这个效果发动而送去墓地的怪兽的各自数值
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-atk)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-def)
		tc:RegisterEffect(e2)
	end
end
-- 判断此卡是否是从场上送去墓地，以确定是否满足效果发动条件
function c35330871.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义送去墓地效果的对象确认、选择及连锁操作信息设置逻辑
function c35330871.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToGrave() end
	-- 确认场上是否存在可以送去墓地的卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1张可以送去墓地的卡片作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 向系统声明此效果的操作信息为“将选中的1张卡送去墓地”
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 定义送去墓地效果的具体处理逻辑：将对象卡送去墓地
function c35330871.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为效果对象的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为效果对象的目标卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
