--「A」細胞組み換え装置
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。从卡组把1只「外星」怪兽送去墓地，送去墓地的怪兽的等级数量的A指示物给作为对象的怪兽放置。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「外星」怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c91231901.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。从卡组把1只「外星」怪兽送去墓地，送去墓地的怪兽的等级数量的A指示物给作为对象的怪兽放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c91231901.target)
	e1:SetOperation(c91231901.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「外星」怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91231901,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 发动条件：不在送到墓地的回合
	e2:SetCondition(aux.exccon)
	-- Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c91231901.thtg)
	e2:SetOperation(c91231901.thop)
	c:RegisterEffect(e2)
end
c91231901.counter_add_list={0x100e}
c91231901.mentioned_counter={
	[0x100e]=true,
}
-- 墓地卡片过滤条件：有等级的「外星」怪兽
function c91231901.filter(c)
	return c:GetLevel()>0 and c:IsSetCard(0xc) and c:IsAbleToGrave()
end
-- 放置指示物效果发动准备与目标确认
function c91231901.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断场上是否存在可以放置A指示物的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x100e,1)
		-- 判断卡组是否存在可以送去墓地的「外星」怪兽
		and Duel.IsExistingMatchingCard(c91231901.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x100e,1)
	-- 设置连锁操作信息：从卡组送去墓地1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置连锁操作信息：放置A指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x100e,1)
end
-- 效果处理：从卡组将1只「外星」怪兽送去墓地，并给目标怪兽放置其等级数量的A指示物
function c91231901.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的「外星」怪兽
	local g=Duel.SelectMatchingCard(tp,c91231901.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local sg=g:GetFirst()
		-- 判断选中的怪兽是否成功送去墓地
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 and sg:IsLocation(LOCATION_GRAVE) then
			-- 获取效果对象
			local tc=Duel.GetFirstTarget()
			if tc:IsFaceup() and tc:IsRelateToEffect(e) then
				tc:AddCounter(0x100e,sg:GetLevel())
			end
		end
	end
end
-- 检索过滤条件：「外星」怪兽
function c91231901.thfilter(c)
	return c:IsSetCard(0xc) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果发动准备与目标确认
function c91231901.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组存在可检索的「外星」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91231901.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：从卡组选1只「外星」怪兽加入手牌
function c91231901.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「外星」怪兽
	local g=Duel.SelectMatchingCard(tp,c91231901.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
