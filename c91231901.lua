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
	-- 设置该效果在送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置发动成本为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c91231901.thtg)
	e2:SetOperation(c91231901.thop)
	c:RegisterEffect(e2)
end
c91231901.counter_add_list={0x100e}
-- 过滤函数：卡组中等级大于0且能送去墓地的「外星」怪兽
function c91231901.filter(c)
	return c:GetLevel()>0 and c:IsSetCard(0xc) and c:IsAbleToGrave()
end
-- 效果①的发动准备与对象选择
function c91231901.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以放置A指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x100e,1)
		-- 检查卡组中是否存在满足条件的「外星」怪兽
		and Duel.IsExistingMatchingCard(c91231901.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只可以放置A指示物的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x100e,1)
	-- 设置效果处理信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置效果处理信息：给选中的对象怪兽放置A指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x100e,1)
end
-- 效果①的处理逻辑
function c91231901.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只满足条件的「外星」怪兽
	local g=Duel.SelectMatchingCard(tp,c91231901.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local sg=g:GetFirst()
		-- 若成功将选中的怪兽送去墓地且该怪兽确实存在于墓地
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 and sg:IsLocation(LOCATION_GRAVE) then
			-- 获取效果①的对象怪兽
			local tc=Duel.GetFirstTarget()
			if tc:IsFaceup() and tc:IsRelateToEffect(e) then
				tc:AddCounter(0x100e,sg:GetLevel())
			end
		end
	end
end
-- 过滤函数：卡组中可以加入手牌的「外星」怪兽
function c91231901.thfilter(c)
	return c:IsSetCard(0xc) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备
function c91231901.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「外星」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91231901.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理逻辑
function c91231901.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的「外星」怪兽
	local g=Duel.SelectMatchingCard(tp,c91231901.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
