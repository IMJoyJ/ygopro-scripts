--占術姫クリスタルウンディーネ
-- 效果：
-- ①：这张卡反转的场合才能发动。从自己的卡组·墓地选1只仪式怪兽加入手卡。
function c67503139.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从自己的卡组·墓地选1只仪式怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c67503139.thtg)
	e1:SetOperation(c67503139.thop)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为仪式怪兽且可以加入手卡
function c67503139.thfilter(c)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand()
end
-- 效果①的发动准备，用于检查发动条件并设置操作信息
function c67503139.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己卡组或墓地是否存在至少1张满足条件的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67503139.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，声明此效果包含将自己卡组或墓地的1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的效果处理，执行从卡组或墓地将仪式怪兽加入手卡的操作
function c67503139.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组或墓地选择1张满足条件的仪式怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c67503139.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
