--ファーニマル・ラビット
-- 效果：
-- 「毛绒动物·兔子」的效果1回合只能使用1次。
-- ①：这张卡成为融合召唤的素材送去墓地的场合，以自己墓地1只「锋利小鬼·剪刀」或者1只「毛绒动物·兔子」以外的「毛绒动物」怪兽为对象才能发动。那只怪兽加入手卡。
function c38124994.initial_effect(c)
	-- ①：这张卡成为融合召唤的素材送去墓地的场合，以自己墓地1只「锋利小鬼·剪刀」或者1只「毛绒动物·兔子」以外的「毛绒动物」怪兽为对象才能发动。那只怪兽加入手卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38124994,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,38124994)
	e1:SetCondition(c38124994.condition)
	e1:SetTarget(c38124994.target)
	e1:SetOperation(c38124994.operation)
	c:RegisterEffect(e1)
end
-- 判断此卡是否作为融合素材送去墓地，以确定是否满足效果的发动条件
function c38124994.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤墓地中可以加入手牌的「锋利小鬼·剪刀」或除「毛绒动物·兔子」以外的「毛绒动物」怪兽卡
function c38124994.filter(c)
	return (c:IsCode(30068120) or (c:IsSetCard(0xa9) and c:IsType(TYPE_MONSTER) and not c:IsCode(38124994)))
		and c:IsAbleToHand()
end
-- 定义效果的对象确认、选择及连锁操作信息设置逻辑
function c38124994.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38124994.filter(chkc) end
	-- 判断自己墓地中是否存在至少1张满足条件的目标卡片
	if chk==0 then return Duel.IsExistingTarget(c38124994.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地中1张符合条件的目标卡片作为效果的对象
	local g=Duel.SelectTarget(tp,c38124994.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 向系统声明此效果的操作信息为“将选中的1张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果的具体处理逻辑：将选中的对象卡片加入手牌
function c38124994.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为效果对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为效果对象的目标卡片加入玩家手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
