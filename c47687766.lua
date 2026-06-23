--ギアギアングラー
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把「齿轮齿轮钻地人」以外的1只机械族·地属性·4星怪兽加入手卡。这个回合，自己不能攻击宣言，不是机械族怪兽不能特殊召唤。
function c47687766.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47687766,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c47687766.target)
	e1:SetOperation(c47687766.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足4星、机械族、地属性且不是齿轮齿轮钻地人的怪兽
function c47687766.filter(c)
	return c:IsLevel(4) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsCode(47687766) and c:IsAbleToHand()
end
-- 检查卡组是否存在满足条件的怪兽，若存在则设置连锁操作信息为检索一张怪兽到手牌
function c47687766.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c47687766.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为检索一张怪兽到手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 发动效果时选择并检索符合条件的怪兽加入手牌，并确认对方查看该卡
function c47687766.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的一张怪兽
	local g=Duel.SelectMatchingCard(tp,c47687766.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选怪兽
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个回合，自己不能攻击宣言，不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能攻击宣言的效果
	Duel.RegisterEffect(e1,tp)
	-- 注册不能特殊召唤非机械族怪兽的效果
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c47687766.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制非机械族怪兽的特殊召唤
function c47687766.splimit(e,c)
	return c:GetRace()~=RACE_MACHINE
end
