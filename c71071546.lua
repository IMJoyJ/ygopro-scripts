--オービタル 7
-- 效果：
-- ①：这张卡反转的场合发动。给这张卡放置1个遵命指示物。
-- ②：自己主要阶段，把这张卡的遵命指示物全部取除才能发动。这张卡的攻击力变成2000，这个回合不能直接攻击，结束阶段送去墓地。
-- ③：把这张卡解放，以自己墓地1只「光子」怪兽或者「银河」怪兽为对象才能发动。那只怪兽加入手卡。
function c71071546.initial_effect(c)
	c:EnableCounterPermit(0x2c)
	-- ①：这张卡反转的场合发动。给这张卡放置1个光子指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71071546,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_FLIP)
	e1:SetOperation(c71071546.ctop)
	c:RegisterEffect(e1)
	-- ②：把这张卡的光子指示物全部去除才能发动。这张卡的攻击力变成2000。这个回合，这张卡不能直接攻击，结束阶段送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetDescription(aux.Stringid(71071546,1))  --"这张卡的攻击力变成2000"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c71071546.atkcost)
	e2:SetTarget(c71071546.atktg)
	e2:SetOperation(c71071546.atkop)
	c:RegisterEffect(e2)
	-- ③：把这张卡解放，以自己墓地1只「光子」怪兽或「银河」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71071546,2))  --"自己墓地「光子」或者「银河」怪兽加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c71071546.thcost)
	e3:SetTarget(c71071546.thtg)
	e3:SetOperation(c71071546.thop)
	c:RegisterEffect(e3)
end
c71071546.mentioned_counter={
	[0x2c]=true,
}
-- ①效果处理：给此卡放置1个光子指示物
function c71071546.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(0x2c,1)
	end
end
-- ②效果发动Cost：去除此卡所有的光子指示物
function c71071546.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetCounter(0x2c)
	if chk==0 then return ct>0 and e:GetHandler():IsCanRemoveCounter(tp,0x2c,ct,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x2c,ct,REASON_COST)
end
-- ②效果发动准备：检查自身攻击力是否不为2000
function c71071546.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsAttack(2000) end
end
-- ②效果处理：使自身攻击力变成2000，赋予不能直接攻击的约束，并注册结束阶段送墓效果
function c71071546.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力变成2000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 这个回合，这张卡不能直接攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e2)
		-- 结束阶段送去墓地。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetOperation(c71071546.tgop)
		e3:SetReset(RESET_EVENT+0xc6e0000)
		c:RegisterEffect(e3)
	end
end
-- 结束阶段送墓效果处理：将此卡送去墓地
function c71071546.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
-- ③效果发动Cost：解放此卡
function c71071546.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放此卡作为Cost
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 墓地回收过滤条件：墓地的「光子」或「银河」怪兽且可加入手牌
function c71071546.filter(c)
	return c:IsSetCard(0x55,0x7b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ③效果发动准备：选择墓地1只「光子」或「银河」怪兽为对象，设置加入手牌的操作信息
function c71071546.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c71071546.filter(chkc) end
	-- 发动条件检查：墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c71071546.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地1只「光子」或「银河」怪兽作为对象
	local g=Duel.SelectTarget(tp,c71071546.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果处理：将对象怪兽从墓地加入手牌并展示
function c71071546.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
