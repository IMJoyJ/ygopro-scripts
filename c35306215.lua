--失楽の堕天使
-- 效果：
-- 天使族怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己作需要怪兽2只解放的天使族怪兽的上级召唤的场合，可以不把怪兽2只解放而从自己墓地把2只怪兽除外来上级召唤。
-- ②：丢弃1张手卡才能发动。从卡组选1只「堕天使」怪兽加入手卡或送去墓地。
-- ③：自己结束阶段发动。自己回复场上的天使族怪兽数量×500基本分。
function c35306215.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2只满足种族为天使的卡片作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_FAIRY),2,2)
	-- ①：只要这张卡在怪兽区域存在，自己作需要怪兽2只解放的天使族怪兽的上级召唤的场合，可以不把怪兽2只解放而从自己墓地把2只怪兽除外来上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35306215,0))  --"把墓地2只怪兽除外上级召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c35306215.otcon)
	e1:SetTarget(c35306215.ottg)
	e1:SetOperation(c35306215.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e4)
	-- ②：丢弃1张手卡才能发动。从卡组选1只「堕天使」怪兽加入手卡或送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35306215,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,35306215)
	e2:SetCost(c35306215.thcost)
	e2:SetTarget(c35306215.thtg)
	e2:SetOperation(c35306215.thop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段发动。自己回复场上的天使族怪兽数量×500基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35306215,2))  --"回复基本分"
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c35306215.reccon)
	e3:SetTarget(c35306215.rectg)
	e3:SetOperation(c35306215.recop)
	c:RegisterEffect(e3)
end
-- 定义墓地除外怪兽的过滤条件，即必须是怪兽类型且能作为费用除外
function c35306215.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 上级召唤条件函数，检查是否满足2只怪兽除外的条件并有足够召唤区域
function c35306215.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查召唤者是否有足够的召唤区域
	return minc<=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查召唤者墓地是否有2只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c35306215.rmfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 上级召唤目标函数，检查召唤对象是否满足2只 tribute 要求且种族为天使
function c35306215.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2 and c:IsRace(RACE_FAIRY)
end
-- 上级召唤操作函数，选择2只墓地怪兽除外并设置召唤材料
function c35306215.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择2只满足条件的墓地怪兽
	local g=Duel.SelectMatchingCard(tp,c35306215.rmfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的怪兽除外作为召唤的费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	c:SetMaterial(nil)
end
-- 检索效果的费用函数，丢弃1张手牌作为费用
function c35306215.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可丢弃的手牌
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手牌的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义检索卡组中堕天使怪兽的过滤条件
function c35306215.thfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 检索效果的目标函数，设置检索目标为卡组中堕天使怪兽
function c35306215.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的堕天使怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35306215.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡送去手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息为将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的操作函数，选择卡组中堕天使怪兽加入手牌或送去墓地
function c35306215.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择卡组中满足条件的堕天使怪兽
	local g=Duel.SelectMatchingCard(tp,c35306215.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 判断是否可以将卡送去手牌，否则送去墓地
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将选中的卡送去手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认送去手牌的卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- 结束阶段回复基本分的条件函数，检查是否为当前回合玩家
function c35306215.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 定义场上的天使族怪兽过滤条件
function c35306215.recfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY)
end
-- 结束阶段回复基本分的目标函数，计算回复基本分数量并设置操作信息
function c35306215.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算场上的天使族怪兽数量并乘以500作为回复基本分
	local rec=Duel.GetMatchingGroupCount(c35306215.recfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*500
	-- 设置操作信息中的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息中的目标参数为回复基本分数量
	Duel.SetTargetParam(rec)
	-- 设置操作信息为回复基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 结束阶段回复基本分的操作函数，根据场上天使族怪兽数量回复基本分
function c35306215.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算场上的天使族怪兽数量并乘以500作为回复基本分
	local rec=Duel.GetMatchingGroupCount(c35306215.recfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*500
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 执行回复基本分的操作
	Duel.Recover(p,rec,REASON_EFFECT)
end
