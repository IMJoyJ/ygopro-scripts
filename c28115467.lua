--ミドレミコード・エリーティア
-- 效果：
-- ←6 【灵摆】 6→
-- ①：自己的「七音服」灵摆怪兽的灵摆召唤不会被无效化。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡。
-- ②：只要自己的灵摆区域有偶数的灵摆刻度存在，自己的「七音服」灵摆怪兽的战斗发生的对自己的战斗伤害变成0。
function c28115467.initial_effect(c)
	-- 为这张卡注册灵摆怪兽属性，使其拥有灵摆召唤和作为灵摆卡发动的能力。
	aux.EnablePendulumAttribute(c)
	-- ①：自己的「七音服」灵摆怪兽的灵摆召唤不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(c28115467.distg)
	c:RegisterEffect(e1)
	-- 这个卡名的①的怪兽效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡。
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
-- e1效果的Target函数：筛选适用‘灵摆召唤不会被无效化’的怪兽——由我方控制、卡名属于「七音服」且通过灵摆召唤特殊召唤的灵摆怪兽。
function c28115467.distg(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 回手牌对象筛选：对象必须是魔法·陷阱卡，并且能够加入手卡。
function c28115467.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 怪兽效果①的发动流程：先检查是否存在可选对象，再让玩家选择对方场上1张魔法·陷阱卡作为对象，并登记回手牌操作。
function c28115467.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c28115467.thfilter(chkc) end
	-- 发动合法性检查：若对方场上不存在满足条件的魔法·陷阱卡，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c28115467.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家进行选择，消息内容为“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 在对方场上选择1张满足条件的魔法·陷阱卡作为效果对象，并将对象登记到当前连锁。
	local g=Duel.SelectTarget(tp,c28115467.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记本连锁的处理信息：该效果会将1张卡返回手牌，供相关卡牌效果和时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取得前面选择的对象卡，只要它仍与效果相关，就将其送回持有者手卡。
function c28115467.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁上登记的第一张对象卡（本效果只选择了1张对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以‘效果’为原因，将对象卡送回持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判定此灵摆卡当前的灵摆刻度是否为偶数（用于判断是否存在偶数刻度）。
function c28115467.pfilter(c)
	return c:GetCurrentScale()%2==0
end
-- ②效果的适用条件：自己灵摆区域存在至少1张刻度为偶数的灵摆卡时才适用。
function c28115467.avcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己灵摆区域是否存在满足偶数刻度条件的卡。
	return Duel.IsExistingMatchingCard(c28115467.pfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- ②效果的目标筛选：被减伤效果保护的是我方场上的「七音服」灵摆怪兽。
function c28115467.avfilter(e,c)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM)
end
