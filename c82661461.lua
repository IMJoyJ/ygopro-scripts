--EMオッドアイズ・バレット
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，对方怪兽的攻击宣言时才能发动。那只对方怪兽的攻击力下降自己的额外卡组的表侧表示的灵摆怪兽数量×300。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「娱乐伙伴 异色眼贴身男仆」以外的1只「娱乐伙伴」怪兽或者「异色眼」怪兽送去墓地。这张卡的等级直到回合结束时变成和送去墓地的怪兽的等级相同。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c82661461.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤及灵摆卡发动等基本属性。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，对方怪兽的攻击宣言时才能发动。那只对方怪兽的攻击力下降自己的额外卡组的表侧表示的灵摆怪兽数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c82661461.atkcon)
	e1:SetTarget(c82661461.atktg)
	e1:SetOperation(c82661461.atkop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「娱乐伙伴 异色眼贴身男仆」以外的1只「娱乐伙伴」怪兽或者「异色眼」怪兽送去墓地。这张卡的等级直到回合结束时变成和送去墓地的怪兽的等级相同。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,82661461)
	e2:SetTarget(c82661461.tgtg)
	e2:SetOperation(c82661461.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c82661461.pencon)
	e4:SetTarget(c82661461.pentg)
	e4:SetOperation(c82661461.penop)
	c:RegisterEffect(e4)
end
-- 灵摆效果①的发动条件函数：对方怪兽进行攻击宣言。
function c82661461.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击宣言的怪兽是否由对方玩家控制。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤函数：筛选自己额外卡组表侧表示的灵摆怪兽。
function c82661461.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 灵摆效果①的发动检测函数。
function c82661461.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在至少1张表侧表示的灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c82661461.atkfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
-- 灵摆效果①的效果处理函数：降低攻击力。
function c82661461.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前进行攻击宣言的怪兽。
	local bc=Duel.GetAttacker()
	-- 计算自己额外卡组表侧表示的灵摆怪兽数量，并乘以300。
	local ct=Duel.GetMatchingGroupCount(c82661461.atkfilter,tp,LOCATION_EXTRA,0,nil)*300
	if bc:IsFaceup() and bc:IsRelateToBattle() and ct>0 then
		-- 那只对方怪兽的攻击力下降自己的额外卡组的表侧表示的灵摆怪兽数量×300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
	end
end
-- 过滤函数：筛选卡组中除「娱乐伙伴 异色眼贴身男仆」以外的「娱乐伙伴」怪兽或「异色眼」怪兽。
function c82661461.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x9f,0x99) and not c:IsCode(82661461) and c:IsAbleToGrave()
end
-- 怪兽效果①的发动检测与效果分类设置函数。
function c82661461.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c82661461.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含将卡组的1张卡送去墓地的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果①的效果处理函数：送墓并改变等级。
function c82661461.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c82661461.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的怪兽送去墓地，并确认其成功送去墓地。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToEffect(e) then
		-- 这张卡的等级直到回合结束时变成和送去墓地的怪兽的等级相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 怪兽效果②的发动条件函数：在怪兽区域被破坏且表侧表示。
function c82661461.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果②的发动检测函数。
function c82661461.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域是否有空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果②的效果处理函数：放置到灵摆区域。
function c82661461.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示移动到自己的灵摆区域。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
