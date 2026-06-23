--聖占術の儀式
-- 效果：
-- 「圣占术姬 塔罗光巫女」的降临必需。
-- ①：从自己的手卡·场上把等级合计直到9以上的怪兽解放，从手卡把「圣占术姬 塔罗光巫女」仪式召唤。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「占术姬」怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c30392583.initial_effect(c)
	-- 为卡片添加等级合计超过仪式怪兽原本等级的仪式召唤效果，仪式怪兽卡号为94997874
	aux.AddRitualProcGreaterCode(c,94997874)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1只「占术姬」怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 设置效果发动条件为：这张卡不能在送去墓地的回合发动
	e1:SetCondition(aux.exccon)
	-- 设置效果发动费用为：把这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c30392583.thtg)
	e1:SetOperation(c30392583.thop)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于筛选「占术姬」怪兽类型且可以送去手卡的卡片
function c30392583.thfilter(c)
	return c:IsSetCard(0xcc) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标函数，检查卡组中是否存在满足条件的卡片并设置操作信息
function c30392583.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c30392583.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置效果处理函数，选择并把符合条件的卡加入手牌并确认对方查看
function c30392583.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的卡作为目标
	local g=Duel.SelectMatchingCard(tp,c30392583.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
