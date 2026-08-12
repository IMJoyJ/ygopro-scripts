--アームド・ドラゴン・カタパルトキャノン
-- 效果：
-- 「VWXYZ-神龙强击炮」＋「武装龙 LV7」
-- 自己对上记的卡全部的特殊召唤成功的决斗中，把自己的场上·墓地的上记的卡除外的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：只要这张卡在怪兽区域存在，对方不能把和除外的自己·对方的卡同名卡的效果发动。
-- ②：对方回合1次，从卡组·额外卡组把1张卡除外才能发动。对方的场上·墓地的卡全部除外。
function c75906310.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「VWXYZ-神龙强击炮」和「武装龙 LV7」
	aux.AddFusionProcCode2(c,84243274,73879377,true,true)
	-- 添加接触融合召唤手续，将自己场上·墓地的素材正面表示除外
	aux.AddContactFusionProcedure(c,c75906310.cfilter,LOCATION_ONFIELD+LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 自己对上记的卡全部的特殊召唤成功的决斗中，把自己的场上·墓地的上记的卡除外的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c75906310.splimit)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方不能把和除外的自己·对方的卡同名卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c75906310.aclimit)
	c:RegisterEffect(e3)
	-- ②：对方回合1次，从卡组·额外卡组把1张卡除外才能发动。对方的场上·墓地的卡全部除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(75906310,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(c75906310.rmcon)
	e4:SetCost(c75906310.rmcost)
	e4:SetTarget(c75906310.rmtg)
	e4:SetOperation(c75906310.rmop)
	c:RegisterEffect(e4)
	if not c75906310.global_flag then
		c75906310.global_flag=true
		-- 自己对上记的卡全部的特殊召唤成功的决斗中
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c75906310.regop)
		-- 注册全局环境效果，用于记录双方玩家在决斗中特殊召唤过素材怪兽的标记
		Duel.RegisterEffect(ge1,0)
	end
end
-- 记录特殊召唤成功历史的全局效果操作函数
function c75906310.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历当前特殊召唤成功的怪兽组
	for tc in aux.Next(eg) do
		if tc:IsCode(84243274) then
			-- 给特殊召唤了「VWXYZ-神龙强击炮」的玩家注册全局标识
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),75906310,0,0,0)
		elseif tc:IsCode(73879377) then
			-- 给特殊召唤了「武装龙 LV7」的玩家注册全局标识
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),75906311,0,0,0)
		end
	end
end
-- 限制该卡从额外卡组特殊召唤的条件函数（只能通过自身规则特殊召唤）
function c75906310.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 接触融合素材的过滤条件函数，需满足是指定素材、能被除外且该玩家在决斗中曾特殊召唤过这两种素材
function c75906310.cfilter(c,fc)
	local tp=fc:GetControler()
	-- 检查卡片是否为指定素材之一、能否作为代价除外，且玩家已达成两张素材在决斗中都特殊召唤成功的条件
	return c:IsFusionCode(84243274,73879377) and c:IsAbleToRemoveAsCost() and Duel.GetFlagEffect(tp,75906310)>0 and Duel.GetFlagEffect(tp,75906311)>0
end
-- 过滤除外状态中与要发动的效果同名的正面表示卡片
function c75906310.acfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 对方不能发动效果的限制函数
function c75906310.aclimit(e,re,tp)
	-- 检查双方除外的卡中是否存在与企图发动的效果同名的卡
	return Duel.IsExistingMatchingCard(c75906310.acfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED,1,nil,re:GetHandler():GetCode())
end
-- 效果②的发动条件函数
function c75906310.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 效果②的发动代价处理函数
function c75906310.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或额外卡组是否存在可以作为代价除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己的卡组或额外卡组选择1张卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的卡正面表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的目标选择与效果分类注册函数
function c75906310.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上或墓地是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 获取对方场上及墓地所有可以除外的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	-- 设置效果处理信息为除外对方场上和墓地的所有卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果②的效果处理（除外对方场上·墓地全部卡）函数
function c75906310.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取对方场上及墓地所有可以除外的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if g:GetCount()>0 then
		-- 将获取到的对方场上及墓地的卡全部正面表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
