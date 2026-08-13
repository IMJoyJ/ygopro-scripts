--EMトランポリンクス
-- 效果：
-- ←4 【灵摆】 4→
-- 「娱乐伙伴 蹦床猞猁」的灵摆效果1回合只能使用1次。
-- ①：自己灵摆召唤成功时，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。
-- 【怪兽效果】
-- ①：这张卡召唤成功时，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。
function c43241495.initial_effect(c)
	-- 为灵摆怪兽c添加灵摆怪兽属性（灵摆召唤、灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- 「娱乐伙伴 蹦床猞猁」的灵摆效果1回合只能使用1次。①：自己灵摆召唤成功时，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。
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
	-- 【怪兽效果】①：这张卡召唤成功时，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。
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
-- 筛选出由玩家tp进行的灵摆召唤成功的怪兽（即检查怪兽的召唤玩家是tp且召唤类型为灵摆召唤）
function c43241495.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 灵摆效果的发动条件：自己灵摆召唤成功时才能发动（检查特殊召唤成功的一组怪兽中是否存在至少1只由自己灵摆召唤的怪兽）
function c43241495.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c43241495.cfilter,1,nil,tp)
end
-- 选择对象的筛选条件：该卡可以被加入手牌（即没有“不能加入手牌”的限制）
function c43241495.filter(c)
	return c:IsAbleToHand()
end
-- 效果发动时的目标处理：指定自己或对方灵摆区域1张可以被加入手牌的卡为对象，并设置回手牌的操作信息
function c43241495.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and c43241495.filter(chkc) end
	-- 效果发动时（chk==0）检查双方灵摆区域是否存在至少1张满足条件的卡可以作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c43241495.filter,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	-- 向操作玩家显示选择提示“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己或对方的灵摆区域选择1张满足条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c43241495.filter,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,nil)
	-- 设置处理信息：将选择的卡返回持有者手牌（CATEGORY_TOHAND），数量1
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 灵摆效果处理：将作为对象的灵摆区域的卡返回持有者手卡
function c43241495.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡（取对象效果选中的那张卡）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡返回持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 怪兽效果处理：将作为对象的灵摆区域的卡返回持有者手卡
function c43241495.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡（取对象效果选中的那张卡）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡返回持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
