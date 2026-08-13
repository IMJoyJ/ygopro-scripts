--影霊衣の大魔道士
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡被效果解放的场合才能发动。从卡组把1只魔法师族「影灵衣」仪式怪兽加入手卡。
-- ②：这张卡被除外的场合才能发动。从卡组把「影灵衣大魔道士」以外的1只「影灵衣」怪兽送去墓地。
function c27796375.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡被效果解放的场合才能发动。从卡组把1只魔法师族「影灵衣」仪式怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27796375,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,27796375)
	e1:SetCondition(c27796375.thcon)
	e1:SetCost(c27796375.cost)
	e1:SetTarget(c27796375.thtg)
	e1:SetOperation(c27796375.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。从卡组把「影灵衣大魔道士」以外的1只「影灵衣」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27796375,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,27796375)
	e2:SetCost(c27796375.cost)
	e2:SetTarget(c27796375.tgtg)
	e2:SetOperation(c27796375.tgop)
	c:RegisterEffect(e2)
end
-- 两个效果共用的代价函数：不消耗任何资源，仅在发动时向对方提示当前发动效果的描述文本。
function c27796375.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家发送HINT_OPSELECTED提示，显示“对方选择了：”并展示当前效果的描述，使对方知道发动的是哪个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ①的发动条件：判断本卡被解放的原因是否为效果（REASON_EFFECT），满足“被效果解放的场合”。
function c27796375.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 检索目标过滤器：从卡组中筛选满足「影灵衣」字段、仪式怪兽、魔法师族且能加入手卡的卡。
function c27796375.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_RITUAL) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- ①的发动目标处理：效果发动时检查卡组是否存在符合条件的检索对象；若存在，则登记将1张卡从卡组加入手卡的操作信息。
function c27796375.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己卡组中必须存在至少1张符合thfilter条件的「影灵衣」魔法师族仪式怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c27796375.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：向系统登记本效果处理时会将1张卡从卡组加入手卡（CATEGORY_TOHAND），用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：从卡组选择1张符合条件的「影灵衣」魔法师族仪式怪兽加入手牌，并向对手展示。
function c27796375.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给出“请选择要加入手牌的卡”的提示，进入检索选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己卡组中选取1张满足thfilter条件的卡作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c27796375.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡加入其持有者的手卡，移动原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认，保证双方对检索结果知情。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 送墓目标过滤器：筛选卡组中满足「影灵衣」字段、不是「影灵衣大魔道士」、是怪兽卡且能送去墓地的卡。
function c27796375.tgfilter(c)
	return c:IsSetCard(0xb4) and not c:IsCode(27796375) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ②的发动目标处理：效果发动时检查卡组是否存在符合条件的送墓对象；若存在，则登记将1张卡从卡组送去墓地的操作信息。
function c27796375.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己卡组中必须存在至少1张符合tgfilter条件的「影灵衣」怪兽（除「影灵衣大魔道士」外），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c27796375.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：向系统登记本效果处理时会将1张卡从卡组送去墓地（CATEGORY_TOGRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②的效果处理：从卡组选择1张符合条件的「影灵衣」怪兽送去墓地。
function c27796375.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给出“请选择要送去墓地的卡”的提示，进入送墓选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己卡组中选取1张满足tgfilter条件的卡作为送去墓地的对象。
	local g=Duel.SelectMatchingCard(tp,c27796375.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡从卡组送去墓地，移动原因为效果（REASON_EFFECT）。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
