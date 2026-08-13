--スニッフィング・ドラゴン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「嗅探龙」加入手卡。
function c27877771.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「嗅探龙」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27877771,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,27877771)
	e1:SetTarget(c27877771.target)
	e1:SetOperation(c27877771.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡是否为「嗅探龙」并且能够被加入手卡，作为检索卡组时的筛选条件。
function c27877771.filter(c)
	return c:IsCode(27877771) and c:IsAbleToHand()
end
-- 发动时的目标函数：检查卡组是否存在满足条件的「嗅探龙」，并设置本次效果为从卡组把1张卡加入手卡的操作信息。
function c27877771.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：在发动时（chk==0）判断自己卡组是否存在至少1张满足过滤条件的「嗅探龙」，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c27877771.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本效果处理时会将卡组的1张卡加入手卡（具体卡在处理时确定，因此目标设为nil），目标玩家为发动者tp，检索位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：实际执行从卡组检索「嗅探龙」加入手卡，并让对方确认检索到的卡。
function c27877771.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组中检索第一张满足filter条件（卡名「嗅探龙」且可加入手卡）的卡，作为本次加入手卡的对象。
	local tc=Duel.GetFirstMatchingCard(c27877771.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将以效果原因（REASON_EFFECT）将检索到的「嗅探龙」送去其持有者的手卡，即加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 因检索的是非公开区域的卡，需要让对方玩家确认这张加入手卡的「嗅探龙」。
		Duel.ConfirmCards(1-tp,tc)
	end
end
