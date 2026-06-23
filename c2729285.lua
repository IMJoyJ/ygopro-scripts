--ファーニマル・キャット
-- 效果：
-- 「毛绒动物·猫」的效果1回合只能使用1次。
-- ①：这张卡成为融合召唤的素材送去墓地的场合，以自己墓地1张「融合」为对象才能发动。那张卡加入手卡。
function c2729285.initial_effect(c)
	-- ①：这张卡成为融合召唤的素材送去墓地的场合，以自己墓地1张「融合」为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2729285,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,2729285)
	e1:SetCondition(c2729285.condition)
	e1:SetTarget(c2729285.target)
	e1:SetOperation(c2729285.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否作为融合召唤的素材送去墓地
function c2729285.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤自己墓地中名为「融合」且可以加入手牌的卡片
function c2729285.filter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- ①效果的对象选择与发动检测声明
function c2729285.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2729285.filter(chkc) end
	-- 在chk==0的发动检测阶段，检查自己墓地中是否存在至少1张「融合」
	if chk==0 then return Duel.IsExistingTarget(c2729285.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的对象卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地的1张「融合」作为效果的对象
	local g=Duel.SelectTarget(tp,c2729285.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果分类为加入手牌，预计将选择的对象加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的实际处理函数
function c2729285.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果锁定的第一个对象卡片（即选中的「融合」）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡片加入玩家手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
