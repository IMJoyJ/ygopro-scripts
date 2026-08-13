--聖占術の儀式
-- 效果：
-- 「圣占术姬 塔罗光巫女」的降临必需。
-- ①：从自己的手卡·场上把等级合计直到9以上的怪兽解放，从手卡把「圣占术姬 塔罗光巫女」仪式召唤。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「占术姬」怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c30392583.initial_effect(c)
	-- 为这张卡添加仪式召唤效果：从自己的手卡·场上把等级合计直到9以上的怪兽解放，从手卡把「圣占术姬 塔罗光巫女」（卡号94997874）仪式召唤，且素材等级合计可以超过仪式怪兽的原本等级。
	aux.AddRitualProcGreaterCode(c,94997874)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「占术姬」怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 设置效果的发动条件，限制为“这张卡送去墓地的回合不能发动”这一自肃条件。
	e1:SetCondition(aux.exccon)
	-- 设置效果的发动代价：把墓地里的这张卡除外。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c30392583.thtg)
	e1:SetOperation(c30392583.thop)
	c:RegisterEffect(e1)
end
-- 定义检索过滤函数：筛选卡组中持有「占术姬」字段、属于怪兽卡且能被加入手卡的卡。
function c30392583.thfilter(c)
	return c:IsSetCard(0xcc) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设定效果发动时的目标选择与操作信息：确认可以检索1张「占术姬」怪兽，并登记本次操作是从卡组将1张卡加入手卡。
function c30392583.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：检查卡组中是否存在至少1张满足检索条件的「占术姬」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c30392583.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果处理时会从卡组把1张卡加入手卡，用于连锁判定和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：实际从卡组选择1只符合条件的「占术姬」怪兽加入手卡，并向对方玩家确认。
function c30392583.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选出1张满足过滤条件的「占术姬」怪兽。
	local g=Duel.SelectMatchingCard(tp,c30392583.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去持有者手卡，即加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手玩家确认被加入手卡的卡牌。
		Duel.ConfirmCards(1-tp,g)
	end
end
