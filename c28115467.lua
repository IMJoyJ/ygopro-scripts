--ミドレミコード・エリーティア
-- 效果：
-- ←6 【灵摆】 6→
-- ①：自己的「七音服」灵摆怪兽的灵摆召唤不会被无效化。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡。
-- ②：只要自己的灵摆区域有偶数的灵摆刻度存在，自己的「七音服」灵摆怪兽的战斗发生的对自己的战斗伤害变成0。
function c28115467.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己的「七音服」灵摆怪兽的灵摆召唤不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(c28115467.distg)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28115467,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,28115467)
	e2:SetTarget(c28115467.thtg)
	e2:SetOperation(c28115467.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：只要自己的灵摆区域有偶数的灵摆刻度存在，自己的「七音服」灵摆怪兽的战斗发生的对自己的战斗伤害变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(c28115467.avcon)
	e4:SetTarget(c28115467.avfilter)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 判断目标是否为自己的「七音服」灵摆怪兽且为灵摆召唤成功
function c28115467.distg(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤函数，用于筛选可以送回手牌的魔法·陷阱卡
function c28115467.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果发动时的选择目标，选择对方场上的魔法·陷阱卡
function c28115467.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c28115467.thfilter(chkc) end
	-- 检查是否有满足条件的对方场上的魔法·陷阱卡作为目标
	if chk==0 then return Duel.IsExistingTarget(c28115467.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的对方场上的魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c28115467.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理时的操作信息，指定将目标卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果处理，将目标卡送回持有者手牌
function c28115467.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选灵摆刻度为偶数的灵摆区域卡片
function c28115467.pfilter(c)
	return c:GetCurrentScale()%2==0
end
-- 判断自己的灵摆区域是否存在偶数刻度的灵摆刻度
function c28115467.avcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己灵摆区域是否有至少一张偶数刻度的灵摆刻度
	return Duel.IsExistingMatchingCard(c28115467.pfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- 判断目标是否为「七音服」灵摆怪兽
function c28115467.avfilter(e,c)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM)
end
