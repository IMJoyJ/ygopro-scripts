--EMトランポリンクス
-- 效果：
-- ←4 【灵摆】 4→
-- 「娱乐伙伴 蹦床猞猁」的灵摆效果1回合只能使用1次。
-- ①：自己灵摆召唤成功时，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。
-- 【怪兽效果】
-- ①：这张卡召唤成功时，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。
function c43241495.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己灵摆召唤成功时，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43241495,0))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,43241495)
	e2:SetCondition(c43241495.thcon)
	e2:SetTarget(c43241495.thtg)
	e2:SetOperation(c43241495.thop1)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤成功时，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43241495,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c43241495.thtg)
	e3:SetOperation(c43241495.thop2)
	c:RegisterEffect(e3)
end
-- 过滤器函数，用于判断目标怪兽是否为灵摆召唤成功
function c43241495.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 条件函数，判断是否满足灵摆召唤成功的触发条件
function c43241495.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c43241495.cfilter,1,nil,tp)
end
-- 过滤器函数，用于判断目标卡是否可以送回手牌
function c43241495.filter(c)
	return c:IsAbleToHand()
end
-- 目标选择函数，选择一个可以送回手牌的灵摆区域卡片
function c43241495.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and c43241495.filter(chkc) end
	-- 检查阶段，判断是否存在可选的目标卡片
	if chk==0 then return Duel.IsExistingTarget(c43241495.filter,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	-- 提示玩家选择要送回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择一个灵摆区域的卡片作为目标
	local g=Duel.SelectTarget(tp,c43241495.filter,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,nil)
	-- 设置连锁操作信息，指定将目标卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数1，将目标卡片送回手牌
function c43241495.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果处理函数2，将目标卡片送回手牌
function c43241495.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
