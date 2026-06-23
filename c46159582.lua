--リチュアの儀水鏡
-- 效果：
-- 「遗式」仪式怪兽的降临必需。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放，从手卡把1只「遗式」仪式怪兽仪式召唤。
-- ②：让墓地的这张卡回到卡组，以自己墓地1只「遗式」仪式怪兽为对象才能发动。那只怪兽加入手卡。
function c46159582.initial_effect(c)
	-- 为卡片添加仪式召唤效果，要求仪式怪兽的等级总和等于仪式召唤的怪兽等级
	aux.AddRitualProcEqual2(c,c46159582.ritual_filter)
	-- ②：让墓地的这张卡回到卡组，以自己墓地1只「遗式」仪式怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46159582,0))  --"墓地的仪式怪兽回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(c46159582.cost)
	e1:SetTarget(c46159582.tg)
	e1:SetOperation(c46159582.op)
	c:RegisterEffect(e1)
end
-- 定义仪式怪兽的筛选条件：必须是「遗式」系列且类型为仪式怪兽
function c46159582.ritual_filter(c)
	return c:IsSetCard(0x3a) and bit.band(c:GetType(),0x81)==0x81
end
-- 支付效果代价：将自身送入卡组洗牌
function c46159582.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	-- 将自身从场上送入卡组并洗牌作为发动代价
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 定义目标卡片筛选条件：墓地中的「遗式」仪式怪兽且可以加入手牌
function c46159582.thfilter(c)
	return c:IsSetCard(0x3a) and bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand()
end
-- 设置效果的目标选择逻辑：选择1只符合条件的墓地怪兽作为对象
function c46159582.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46159582.thfilter(chkc) end
	-- 检查是否有满足条件的墓地怪兽可选
	if chk==0 then return Duel.IsExistingTarget(c46159582.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c46159582.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选定的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 设置效果的处理流程：将目标怪兽送入手牌并确认对方查看
function c46159582.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认查看该怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
