--鉄壁の布陣
-- 效果：
-- 选择自己场上1只怪兽发动。自己场上存在2只以上的怪兽并且全部守备表示的场合，选择怪兽的守备力上升700。选择的怪兽从场上离开时，这张卡破坏。
function c96631852.initial_effect(c)
	-- 选择自己场上1只怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c96631852.target)
	e1:SetOperation(c96631852.operation)
	c:RegisterEffect(e1)
	-- 选择的怪兽从场上离开时，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c96631852.descon)
	e2:SetOperation(c96631852.desop)
	c:RegisterEffect(e2)
	-- 自己场上存在2只以上的怪兽并且全部守备表示的场合，选择怪兽的守备力上升700。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c96631852.defcon)
	e3:SetValue(700)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选具有守备力的怪兽（即可以成为对象的怪兽）
function c96631852.filter(c)
	return c:IsDefenseAbove(0)
end
-- 效果发动的靶向处理：在发动时选择自己场上的1只怪兽作为对象
function c96631852.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 在发动准备阶段，检查自己场上是否存在至少1只符合条件的对象怪兽
	if chk==0 then return Duel.IsExistingTarget(c96631852.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上的1只怪兽作为该效果的对象
	Duel.SelectTarget(tp,c96631852.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：如果此卡和对象怪兽都仍在场，则为此卡建立与该怪兽的持续对象关系
function c96631852.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 守备力上升效果的适用条件：自己场上存在2只以上的怪兽且全部为守备表示
function c96631852.defcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上的怪兽数量是否大于或等于2只
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=2
		-- 检查自己场上是否不存在攻击表示的怪兽（即全部为守备表示）
		and not Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,LOCATION_MZONE,0,1,nil)
end
-- 自毁效果的触发条件：检查离场的怪兽中是否包含此卡当前持续指向的对象怪兽
function c96631852.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 自毁效果的处理：将此卡自身破坏
function c96631852.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将此卡自身破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
