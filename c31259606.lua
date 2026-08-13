--絶海のマーレ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「绝海之马雷」以外的1只水族怪兽送去墓地。
-- ②：自己结束阶段，把这张卡解放，以「绝海之马雷」以外的自己墓地1只水族怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：创建并注册三个效果。e1为①的通常召唤成功时触发，从卡组把「绝海之马雷」以外的1只水族怪兽送去墓地；e2是e1的克隆，改为特殊召唤成功时触发；e3为②的己方结束阶段解放自身，以墓地1只「绝海之马雷」以外的水族怪兽为对象加入手卡。e1/e2共用自id的1回合1次限制，e3使用id+o的限制，实现“这个卡名的①②的效果1回合各能使用1次”。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「绝海之马雷」以外的1只水族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段，把这张卡解放，以「绝海之马雷」以外的自己墓地1只水族怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 定义①效果的卡组筛选函数：检查卡片是否为怪兽、水族、卡名不是「绝海之马雷」，且可以被送去墓地。
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_AQUA) and not c:IsCode(id) and c:IsAbleToGrave()
end
-- ①效果的发动条件判断与操作信息设定：满足条件时设置从卡组将1张卡送去墓地的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发起动时检查：卡组中是否存在至少1张满足s.tgfilter条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为“从卡组把1张卡送去墓地”，供相关效果/时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张符合s.tgfilter条件的卡，将其送去墓地。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择“要送去墓地的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选出1张满足条件的卡（效果处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以REASON_EFFECT（效果）原因送入墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果的发动条件：仅在当前回合玩家是自己（自己的结束阶段）时允许发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于这张卡的控制者tp，确保是己方结束阶段。
	return Duel.GetTurnPlayer()==tp
end
-- ②效果的发动代价：检查这张卡是否可以被解放，并支付解放代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 把这张卡解放作为②效果发动的COST（代价）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义②效果选择墓地卡的筛选函数：检查是否为怪兽、水族、卡名不是「绝海之马雷」，且可以加入手卡。
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_AQUA) and not c:IsCode(id) and c:IsAbleToHand()
end
-- ②效果的取对象目标处理：从自己墓地选择1张符合条件的卡作为对象，并设置加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 发动时检查：自己墓地是否存在至少1张满足s.thfilter条件且能成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择“要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张自己墓地符合条件的卡作为②效果的对象（取对象）。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的对象卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：取得对象卡，若对象仍与效果关联，则将其加入持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以REASON_EFFECT（效果）原因送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
