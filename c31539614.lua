--ワクチンゲール
-- 效果：
-- 3星怪兽×2只以上
-- ①：自己·对方回合，把这张卡1个超量素材取除，以攻击力或守备力和原本数值不同的场上1只怪兽为对象才能发动。那只怪兽的攻击力·守备力变成原本数值。以自己场上的怪兽为对象发动的场合，再让那只怪兽在这个回合不会被战斗·效果破坏。
-- ②：1回合1次，自己场上有其他怪兽特殊召唤的场合，若这张卡的超量素材是3个以上则能发动。那些怪兽的攻击力上升900。
local s,id,o=GetID()
-- 初始化效果函数，设置XYZ召唤手续、效果1和效果2
function s.initial_effect(c)
	-- 添加XYZ召唤手续，要求3星怪兽2只以上作为素材
	aux.AddXyzProcedure(c,nil,3,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 效果1：自己·对方回合，把这张卡1个超量素材取除，以攻击力或守备力和原本数值不同的场上1只怪兽为对象才能发动。那只怪兽的攻击力·守备力变成原本数值。以自己场上的怪兽为对象发动的场合，再让那只怪兽在这个回合不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻守变原本并破坏耐性"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- 效果2：1回合1次，自己场上有其他怪兽特殊召唤的场合，若这张卡的超量素材是3个以上则能发动。那些怪兽的攻击力上升900。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon2)
	e2:SetTarget(s.atktg2)
	e2:SetOperation(s.atkop2)
	c:RegisterEffect(e2)
	-- 注册合并延迟事件，用于处理同时发生的特殊召唤事件
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SPSUMMON_SUCCESS)
end
-- 效果1的费用支付函数，消耗1个超量素材
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选条件函数，用于判断怪兽是否满足效果1的对象条件
function s.arkfilter(c)
	return c:IsFaceup() and (not c:IsAttack(c:GetBaseAttack()) or (not c:IsType(TYPE_LINK) and not c:IsDefense(c:GetBaseDefense())))
end
-- 效果1的目标选择函数，选择符合条件的怪兽作为对象
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.arkfilter(chkc) end
	-- 判断是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.arkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.arkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 and g:GetFirst():IsControler(tp) then
		e:SetLabel(1)
	end
end
-- 效果1的发动处理函数，改变目标怪兽的攻守值并赋予破坏耐性
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) then
		if s.arkfilter(tc) then
			-- 将目标怪兽的攻击力设置为原本数值
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(tc:GetBaseAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 将目标怪兽的守备力设置为原本数值
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(tc:GetBaseDefense())
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		if e:GetLabel()==1 then
			-- 使目标怪兽在本回合不会被战斗破坏
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetValue(1)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			local e4=e3:Clone()
			e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			tc:RegisterEffect(e4)
		end
	end
end
-- 筛选条件函数，用于判断卡片是否为己方控制
function s.cfilter(c,tp)
	return c:IsControler(tp)
end
-- 效果2的发动条件函数，判断是否有己方怪兽被特殊召唤
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 筛选条件函数，用于判断怪兽是否满足效果2的目标条件
function s.atkfilter(c,e,tp)
	return c:IsControler(tp) and (not e or c:IsRelateToEffect(e))
		and c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
-- 效果2的目标选择函数，选择符合条件的己方怪兽
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.atkfilter,1,nil,nil,tp) and e:GetHandler():GetOverlayCount()>2 end
	local g=eg:Filter(s.atkfilter,nil,nil,tp)
	-- 设置效果2的目标怪兽
	Duel.SetTargetCard(g)
end
-- 效果2的发动处理函数，使目标怪兽攻击力上升900
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsRelateToChain,nil)
	-- 遍历目标怪兽组中的每张卡
	for tc in aux.Next(g) do
		if tc:IsType(TYPE_MONSTER) and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
			-- 使目标怪兽的攻击力上升900
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(900)
			tc:RegisterEffect(e1)
		end
	end
end
