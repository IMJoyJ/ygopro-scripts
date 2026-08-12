--ドドレミコード・キューティア
-- 效果：
-- ←8 【灵摆】 8→
-- ①：自己的「七音服」灵摆怪兽的灵摆召唤不会被无效化。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「多之七音服·丘蒂娅」以外的1只「七音服」灵摆怪兽加入手卡。
-- ②：只要自己的灵摆区域有偶数的灵摆刻度存在，自己场上的「七音服」灵摆怪兽的攻击力上升自身的灵摆刻度×100。
function c55226153.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己的「七音服」灵摆怪兽的灵摆召唤不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(c55226153.distg)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「多之七音服·丘蒂娅」以外的1只「七音服」灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55226153,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,55226153)
	e2:SetTarget(c55226153.srtg)
	e2:SetOperation(c55226153.srop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：只要自己的灵摆区域有偶数的灵摆刻度存在，自己场上的「七音服」灵摆怪兽的攻击力上升自身的灵摆刻度×100。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(c55226153.atkcon)
	e4:SetTarget(c55226153.atktg)
	e4:SetValue(c55226153.atkval)
	c:RegisterEffect(e4)
end
-- 过滤属于自己且进行灵摆召唤的「七音服」灵摆怪兽
function c55226153.distg(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤卡组中除「多之七音服·丘蒂娅」以外的「七音服」灵摆怪兽且能加入手卡
function c55226153.srfilter(c)
	return not c:IsCode(55226153) and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 检索效果的发动准备与操作信息注册
function c55226153.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「七音服」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c55226153.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行，从卡组选择1张符合条件的卡加入手卡并给对方确认
function c55226153.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端显示提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c55226153.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤当前灵摆刻度为偶数的卡
function c55226153.pfilter(c)
	return c:GetCurrentScale()%2==0
end
-- 攻击力上升效果的适用条件：自己的灵摆区域存在偶数灵摆刻度的卡
function c55226153.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己的灵摆区域是否存在至少1张偶数灵摆刻度的卡
	return Duel.IsExistingMatchingCard(c55226153.pfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- 过滤受攻击力上升效果影响的卡：自己场上的「七音服」灵摆怪兽
function c55226153.atktg(e,c)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM)
end
-- 计算攻击力上升的数值：自身的灵摆刻度×100
function c55226153.atkval(e,c)
	return c:GetCurrentScale()*100
end
