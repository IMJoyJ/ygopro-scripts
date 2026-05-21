--ジェネティック・ウーマン
-- 效果：
-- 支付1000基本分，选择从游戏中除外的1只自己的念动力族怪兽发动。除外的那只怪兽加入手卡。这个效果1回合只能使用1次。
function c98147766.initial_effect(c)
	-- 支付1000基本分，选择从游戏中除外的1只自己的念动力族怪兽发动。除外的那只怪兽加入手卡。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98147766,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c98147766.cost)
	e1:SetTarget(c98147766.target)
	e1:SetOperation(c98147766.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的Cost（支付1000基本分）判定与执行函数
function c98147766.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000基本分作为发动Cost
	Duel.PayLPCost(tp,1000)
end
-- 过滤条件：表侧表示、念动力族且能加入手牌的怪兽
function c98147766.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsAbleToHand()
end
-- 效果发动的Target（选择除外的1只自己的念动力族怪兽）判定与处理函数
function c98147766.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c98147766.filter(chkc) end
	-- 检查除外区是否存在至少1只满足条件的自己的怪兽
	if chk==0 then return Duel.IsExistingTarget(c98147766.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外区1只满足条件的自己的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c98147766.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息为“将选中的1张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理（将除外的怪兽加入手卡）的执行函数
function c98147766.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
