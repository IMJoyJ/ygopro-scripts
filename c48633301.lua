--TG ブースター・ラプトル
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「科技属」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。从卡组把「科技属 推进盗龙」以外的1只「科技属」怪兽加入手卡。
function c48633301.initial_effect(c)
	-- ①：自己场上有「科技属」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,48633301+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c48633301.sprcon)
	c:RegisterEffect(e1)
	-- 场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。从卡组把「科技属 推进盗龙」以外的1只「科技属」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c48633301.regop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否有「科技属」怪兽存在。
function c48633301.sprfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x27)
end
-- 特殊召唤条件函数，检查是否满足特殊召唤的条件。
function c48633301.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家场上是否存在至少1只「科技属」怪兽。
		and Duel.IsExistingMatchingCard(c48633301.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 当此卡被破坏送入墓地时触发的效果处理函数。
function c48633301.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) then
		-- 效果描述：从卡组把「科技属 推进盗龙」以外的1只「科技属」怪兽加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(48633301,0))
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c48633301.thtg)
		e1:SetOperation(c48633301.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 检索过滤函数，用于筛选符合条件的「科技属」怪兽。
function c48633301.thfilter(c)
	return c:IsSetCard(0x27) and not c:IsCode(48633301) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的目标和操作信息。
function c48633301.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即卡组中是否存在符合条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c48633301.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组检索一张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际处理函数，选择并把卡加入手牌。
function c48633301.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择符合条件的一张卡。
	local g=Duel.SelectMatchingCard(tp,c48633301.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
