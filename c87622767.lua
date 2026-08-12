--ファイナルサイコオーガ
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，可以支付800基本分选择自己墓地存在的1只念动力族怪兽加入手卡。
function c87622767.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，可以支付800基本分选择自己墓地存在的1只念动力族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87622767,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCost(c87622767.thcost)
	e1:SetTarget(c87622767.thtg)
	e1:SetOperation(c87622767.thop)
	c:RegisterEffect(e1)
end
-- 定义发动代价（Cost）函数
function c87622767.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800点基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 支付800点基本分
	Duel.PayLPCost(tp,800)
end
-- 过滤条件：念动力族且能加入手牌的怪兽
function c87622767.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToHand()
end
-- 定义效果的目标（Target）函数
function c87622767.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c87622767.filter(chkc) end
	-- 检查自己墓地是否存在符合条件的念动力族怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c87622767.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的念动力族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c87622767.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果的处理（Operation）函数
function c87622767.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_PSYCHO) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
