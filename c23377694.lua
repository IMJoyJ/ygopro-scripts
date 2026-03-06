--EMオオヤヤドカリ
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，自己的「娱乐伙伴」怪兽被战斗破坏时，以自己的灵摆区域1张「娱乐伙伴」卡或者「异色眼」卡为对象才能发动。那张卡特殊召唤。
-- 【怪兽效果】
-- ①：1回合1次，以自己场上1只灵摆怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升自己场上的「娱乐伙伴」怪兽数量×300。
function c23377694.initial_effect(c)
	-- 为怪兽添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只灵摆怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升自己场上的「娱乐伙伴」怪兽数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c23377694.atktg)
	e1:SetOperation(c23377694.atkop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己的「娱乐伙伴」怪兽被战斗破坏时，以自己的灵摆区域1张「娱乐伙伴」卡或者「异色眼」卡为对象才能发动。那张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c23377694.spcon)
	e2:SetTarget(c23377694.sptg)
	e2:SetOperation(c23377694.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为表侧表示的灵摆怪兽
function c23377694.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 设置效果目标，选择自己场上一只表侧表示的灵摆怪兽
function c23377694.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c23377694.filter1(chkc) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c23377694.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c23377694.filter1,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤函数，用于判断是否为表侧表示的「娱乐伙伴」怪兽
function c23377694.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 处理攻击力提升效果，将自己场上的「娱乐伙伴」怪兽数量乘以300作为攻击力加成
function c23377694.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 统计自己场上表侧表示的「娱乐伙伴」怪兽数量
	local ct=Duel.GetMatchingGroupCount(c23377694.filter2,tp,LOCATION_MZONE,0,nil)
	if ct>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个攻击力提升的效果并注册到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数，用于判断是否为「娱乐伙伴」或「异色眼」卡且之前在自己的控制下
function c23377694.cfilter(c,tp)
	return c:IsSetCard(0x9f) and c:IsPreviousControler(tp)
end
-- 判断被战斗破坏的怪兽是否为自己的「娱乐伙伴」怪兽
function c23377694.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23377694.cfilter,1,nil,tp)
end
-- 过滤函数，用于判断是否为「娱乐伙伴」或「异色眼」卡且可以特殊召唤
function c23377694.spfilter(c,e,tp)
	return c:IsSetCard(0x9f,0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，选择自己灵摆区域的一张符合条件的卡
function c23377694.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_PZONE) and c23377694.spfilter(chkc,e,tp) end
	-- 检查是否有满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c23377694.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c23377694.spfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果，将目标卡特殊召唤到场上
function c23377694.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
