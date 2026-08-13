--リチュアの儀水鏡
-- 效果：
-- 「遗式」仪式怪兽的降临必需。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放，从手卡把1只「遗式」仪式怪兽仪式召唤。
-- ②：让墓地的这张卡回到卡组，以自己墓地1只「遗式」仪式怪兽为对象才能发动。那只怪兽加入手卡。
function c46159582.initial_effect(c)
	-- 为「遗式」仪式怪兽添加仪式召唤效果，要求解放素材的等级合计等于仪式怪兽的等级，且素材/仪式怪兽需满足ritual_filter（是「遗式」仪式怪兽）。
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
-- 定义仪式素材/仪式怪兽的过滤条件：卡名含有「遗式」字段，且类型为仪式怪兽（TYPE_MONSTER+TYPE_RITUAL，即0x81）。
function c46159582.ritual_filter(c)
	return c:IsSetCard(0x3a) and bit.band(c:GetType(),0x81)==0x81
end
-- ②效果的发动代价函数：先检查墓地中的这张卡能否作为代价送回卡组；若可，则执行将这张卡送回卡组并洗牌的代价操作。
function c46159582.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	-- 将这张卡从墓地送回持有者卡组并洗牌，作为发动②效果的代价（REASON_COST）。
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 定义②效果选择对象的过滤条件：必须是自己墓地的「遗式」仪式怪兽，且可以被加入手卡。
function c46159582.thfilter(c)
	return c:IsSetCard(0x3a) and bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand()
end
-- ②效果的目标函数：从自己墓地选择1只符合条件的「遗式」仪式怪兽为对象；若已指定对象则验证该对象位于自己墓地且满足条件；发动前检查是否存在至少1只满足条件的对象。
function c46159582.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46159582.thfilter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1只符合条件的「遗式」仪式怪兽，可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c46159582.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给当前玩家显示“请选择要加入手牌的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从自己墓地选择1只符合条件的「遗式」仪式怪兽作为效果对象，该对象与当前连锁自动关联。
	local g=Duel.SelectTarget(tp,c46159582.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本连锁的操作信息：效果分类为“加入手卡”（CATEGORY_TOHAND），对象为已选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理函数：获取被选择的对象，确认其仍与此效果关联后，将其加入手牌，并向对方玩家展示那只怪兽。
function c46159582.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的唯一的对象卡（即②效果选择的那只「遗式」仪式怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标「遗式」仪式怪兽加入其持有者的手卡，原因记为“效果处理”（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家（1-tp）展示被加入手卡的那只「遗式」仪式怪兽。
		Duel.ConfirmCards(1-tp,tc)
	end
end
