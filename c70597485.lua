--マテリアクトル・ギガヴォロス
-- 效果：
-- 3星怪兽×2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的攻击力·守备力上升自己手卡数量×500。
-- ②：把这张卡1个超量素材取除才能发动。从卡组选1只「原质炉」怪兽在这张卡下面重叠作为超量素材。
-- ③：对方的主要阶段以及战斗阶段才能发动。这张卡作为超量素材中的1张卡加入持有者手卡。
function c70597485.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置该卡所需的超量召唤素材条件为3星怪兽2只以上
	aux.AddXyzProcedure(c,nil,3,2,nil,nil,99)
	-- ①：这张卡的攻击力·守备力上升自己手卡数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c70597485.adval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：把这张卡1个超量素材取除才能发动。从卡组选1只「原质炉」怪兽在这张卡下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70597485,0))  --"攻守上升"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,70597485)
	e3:SetCost(c70597485.matcost)
	e3:SetTarget(c70597485.mattg)
	e3:SetOperation(c70597485.matop)
	c:RegisterEffect(e3)
	-- ③：对方的主要阶段以及战斗阶段才能发动。这张卡作为超量素材中的1张卡加入持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(70597485,1))  --"卡组怪兽作为超量素材"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,70597486)
	e4:SetCondition(c70597485.thcon)
	e4:SetTarget(c70597485.thtg)
	e4:SetOperation(c70597485.thop)
	c:RegisterEffect(e4)
end
-- 计算并返回该卡因手牌数量而上升的攻击力与守备力数值的辅助函数
function c70597485.adval(e,c)
	-- 获取自己手牌数量并乘以500作为上升的数值
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*500
end
-- 效果②的发动代价：检查并取除这张卡的1个超量素材
function c70597485.matcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤卡组中可以作为超量素材的「原质炉」怪兽的条件函数
function c70597485.matfilter(c)
	return c:IsSetCard(0x160) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 效果②的发动目标：检查自身是否为超量怪兽且卡组中是否存在可重叠的「原质炉」怪兽
function c70597485.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否为超量怪兽，以及卡组中是否存在至少1只满足条件的「原质炉」怪兽
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(c70597485.matfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②的效果处理：从卡组选择1只「原质炉」怪兽重叠在这张卡下作为超量素材
function c70597485.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 让玩家从卡组中选择1只满足条件的「原质炉」怪兽
		local g=Duel.SelectMatchingCard(tp,c70597485.matfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽重叠在这张卡下面作为超量素材
			Duel.Overlay(c,g)
		end
	end
end
-- 效果③的发动条件：在对方的主要阶段或战斗阶段才能发动
function c70597485.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- 效果③的发动目标：检查超量素材中是否存在可以加入手牌的卡，并设置回收手牌的操作信息
function c70597485.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetOverlayGroup()
	if chk==0 then return g:IsExists(Card.IsAbleToHand,1,nil) end
	-- 设置效果处理的操作信息，表示将从超量素材中将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_OVERLAY)
end
-- 效果③的效果处理：将这张卡作为超量素材中的1张卡加入持有者手牌
function c70597485.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local g=c:GetOverlayGroup()
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
		if tg:GetCount()>0 then
			-- 将选中的超量素材卡送回持有者的手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 向对方玩家展示并确认加入手牌的卡片
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
