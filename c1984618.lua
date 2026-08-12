--天底の使徒
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从额外卡组把1只怪兽送去墓地。那之后，把持有送去墓地的怪兽的攻击力以下的攻击力的1只「教导」怪兽或「阿不思的落胤」从自己的卡组·墓地加入手卡。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
function c1984618.initial_effect(c)
	-- 记录此卡具有「阿不思的落胤」的卡名
	aux.AddCodeList(c,68468459)
	-- ①：从额外卡组把1只怪兽送去墓地。那之后，把持有送去墓地的怪兽的攻击力以下的攻击力的1只「教导」怪兽或「阿不思的落胤」从自己的卡组·墓地加入手卡。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1984618+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c1984618.target)
	e1:SetOperation(c1984618.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：用于判断额外卡组中是否存在可以送去墓地且后续能检索满足条件的「教导」或「阿不思的落胤」怪兽的怪兽
function c1984618.tgfilter(c,tp)
	-- 返回值：该怪兽可以送去墓地，并且在自己卡组或墓地中存在攻击力不超过该怪兽攻击力的「教导」或「阿不思的落胤」怪兽
	return c:IsAbleToGrave() and Duel.IsExistingMatchingCard(c1984618.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c:GetAttack())
end
-- 过滤函数：用于判断额外卡组中是否存在可以送去墓地且后续能检索满足条件的「教导」或「阿不思的落胤」怪兽的怪兽（考虑王家长眠之谷影响）
function c1984618.opfilter(c,tp)
	-- 返回值：该怪兽可以送去墓地，并且在自己卡组或墓地中存在攻击力不超过该怪兽攻击力的「教导」或「阿不思的落胤」怪兽（不受王家长眠之谷影响）
	return c:IsAbleToGrave() and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c1984618.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c:GetAttack())
end
-- 过滤函数：用于判断卡组或墓地中是否存在满足条件的「教导」或「阿不思的落胤」怪兽
function c1984618.thfilter(c,atk)
	return (c:IsSetCard(0x145) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) and c:IsAttackBelow(atk) and c:IsAbleToHand()
end
-- 效果处理的准备阶段：检查是否存在满足条件的额外怪兽用于送去墓地，并设置操作信息
function c1984618.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的额外怪兽用于送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c1984618.tgfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 设置操作信息：将要从额外卡组送去墓地的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：将要从卡组或墓地加入手牌的「教导」或「阿不思的落胤」怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理阶段：选择并处理送去墓地和检索手牌的逻辑
function c1984618.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从额外卡组选择满足条件的怪兽用于送去墓地
	local g=Duel.SelectMatchingCard(tp,c1984618.opfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 判断所选怪兽是否成功送去墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		local atk=tc:GetAttack()
		-- 提示玩家选择要加入手牌的「教导」或「阿不思的落胤」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组或墓地中选择满足条件的「教导」或「阿不思的落胤」怪兽加入手牌
		local hg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1984618.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,atk)
		local hc=hg:GetFirst()
		if hc then
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(hc,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的怪兽
			Duel.ConfirmCards(1-tp,hc)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- ①：从额外卡组把1只怪兽送去墓地。那之后，把持有送去墓地的怪兽的攻击力以下的攻击力的1只「教导」怪兽或「阿不思的落胤」从自己的卡组·墓地加入手卡。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c1984618.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果：使自己在本回合不能从额外卡组特殊召唤怪兽
		Duel.RegisterEffect(e1,tp)
	end
end
-- 效果限制函数：限制从额外卡组特殊召唤怪兽
function c1984618.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
