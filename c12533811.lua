--ベビー・トラゴン
-- 效果：
-- 1星怪兽×3
-- 自己的主要阶段1把这张卡1个超量素材取除，选择自己场上表侧表示存在的1只1星的怪兽才能发动。选择的怪兽可以直接攻击对方玩家。
function c12533811.initial_effect(c)
	-- 添加XYZ召唤手续，使用1星怪兽3只进行叠放
	aux.AddXyzProcedure(c,nil,1,3)
	c:EnableReviveLimit()
	-- 自己的主要阶段1把这张卡1个超量素材取除，选择自己场上表侧表示存在的1只1星的怪兽才能发动。选择的怪兽可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12533811,0))  --"直接攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c12533811.condition)
	e1:SetCost(c12533811.cost)
	e1:SetTarget(c12533811.target)
	e1:SetOperation(c12533811.operation)
	c:RegisterEffect(e1)
end
-- 判断是否处于主要阶段1
function c12533811.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段必须为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 支付效果代价，移除1个超量素材
function c12533811.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选满足条件的怪兽（表侧表示、1星、未拥有直接攻击效果）
function c12533811.filter(c)
	return c:IsFaceup() and c:IsLevel(1) and c:GetEffectCount(EFFECT_DIRECT_ATTACK)==0
end
-- 设置效果目标，选择1只符合条件的怪兽
function c12533811.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c12533811.filter(chkc) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c12533811.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送选择提示消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c12533811.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动时执行的操作
function c12533811.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽可以直接攻击对方玩家
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
