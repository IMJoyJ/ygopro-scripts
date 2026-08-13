--剣闘獣ティゲル
-- 效果：
-- 这张卡不能作为融合素材怪兽使用。这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，可以从手卡把1张名字带有「剑斗兽」的卡丢弃，从自己卡组把1只名字带有「剑斗兽」的怪兽加入手卡。
function c50893987.initial_effect(c)
	-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，可以从手卡把1张名字带有「剑斗兽」的卡丢弃，从自己卡组把1只名字带有「剑斗兽」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50893987,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置效果的发动条件：必须是用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时才能发动（剑斗兽通用特殊召唤成功判定）。
	e1:SetCondition(aux.gbspcon)
	e1:SetCost(c50893987.sccost)
	e1:SetTarget(c50893987.sctg)
	e1:SetOperation(c50893987.scop)
	c:RegisterEffect(e1)
	-- 这张卡不能作为融合素材怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 代价过滤条件：筛选手卡中名字带有「剑斗兽」且可以被丢弃的卡，作为发动代价的候选。
function c50893987.costfilter(c)
	return c:IsSetCard(0x1019) and c:IsDiscardable()
end
-- 设置发动代价：从手卡丢弃1张名字带有「剑斗兽」的卡；先检查是否存在满足条件的卡，若存在则执行丢弃。
function c50893987.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查（chk==0）：确认己方手卡中是否存在至少1张满足过滤条件的剑斗兽卡，以判断能否支付丢弃代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c50893987.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：玩家从手卡选择1张满足条件的卡丢弃，丢弃原因标记为丢弃+代价。
	Duel.DiscardHand(tp,c50893987.costfilter,1,1,REASON_DISCARD+REASON_COST,nil)
end
-- 检索过滤条件：卡组中的卡需满足名字带有「剑斗兽」、是怪兽且可以加入手卡，作为检索目标。
function c50893987.scfilter(c)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果的目标：检查卡组中是否存在满足条件的剑斗兽怪兽，并设定操作信息为从卡组将1张卡加入手卡。
function c50893987.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查（chk==0）：确认己方卡组中是否存在至少1只满足过滤条件的剑斗兽怪兽，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c50893987.scfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣告本效果将把卡组中的1张卡加入手卡（对象不确定，数量1），供连锁判定等系统使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：提示玩家选择，从卡组检索1只剑斗兽怪兽加入手卡，并向对方展示。
function c50893987.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：让玩家选择要加入手卡的卡（提示文字为“请选择要加入手牌的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 执行选择：从己方卡组选择1张满足过滤条件的剑斗兽怪兽作为检索对象。
	local g=Duel.SelectMatchingCard(tp,c50893987.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 处理检索：将选中的卡加入持有者的手卡（原因：效果），不指定接收玩家则加入其原持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认：展示加入手卡的卡，保证检索信息的公开性。
		Duel.ConfirmCards(1-tp,g)
	end
end
