--捕食植物ビブリスプ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡被送去墓地的场合才能发动。从卡组把「捕食植物 腺毛草胡蜂」以外的1只「捕食植物」怪兽加入手卡。
-- ②：这张卡在墓地存在，场上的怪兽有捕食指示物放置中的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 定义卡片效果初始化函数，用于注册该卡的各种效果。
function c44932065.initial_effect(c)
	-- ①：这张卡被送去墓地的场合才能发动。从卡组把「捕食植物 腺毛草胡蜂」以外的1只「捕食植物」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44932065,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,44932065)
	e1:SetTarget(c44932065.thtg)
	e1:SetOperation(c44932065.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，场上的怪兽有捕食指示物放置中的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44932065,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,44932065+o)
	e2:SetCondition(c44932065.spcon)
	e2:SetTarget(c44932065.sptg)
	e2:SetOperation(c44932065.spop)
	c:RegisterEffect(e2)
end
c44932065.mentioned_counter={
	[0x1041]=true,
}
-- 定义一个过滤函数，用于检索符合条件的“捕食植物”怪兽（不包括“捕食植物 腺毛草胡蜂”）。
function c44932065.thfilter(c)
	return c:IsSetCard(0x10f3) and c:IsType(TYPE_MONSTER) and not c:IsCode(44932065) and c:IsAbleToHand()
end
-- 定义触发效果的目标选择函数，检查卡组中是否存在符合条件的“捕食植物”怪兽。
function c44932065.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足过滤条件c44932065.thfilter的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c44932065.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示这是一个将卡牌加入手牌的效果。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义触发效果的操作函数，用于从卡组检索符合条件的“捕食植物”怪兽并将其加入手牌。
function c44932065.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示提示信息：“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 使用Duel.SelectMatchingCard函数让玩家从卡组中选择一张符合c44932065.thfilter条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c44932065.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选定的卡片送入玩家的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认所加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义一个过滤函数，用于检查场上的怪兽是否具有捕食指示物。
function c44932065.cfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- 定义特殊召唤效果的条件判断函数，检查场上是否存在具有捕食指示物的表侧表示怪兽。
function c44932065.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足c44932065.cfilter条件的卡片。
	return Duel.IsExistingMatchingCard(c44932065.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 定义特殊召唤效果的目标选择函数，用于确定可以特殊召唤的“捕食植物 腺毛草胡蜂”。
function c44932065.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家的怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示这是一个特殊召唤的效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义特殊召唤效果的操作函数，用于将“捕食植物 腺毛草胡蜂”从墓地特殊召唤到场上，并附加一个离场重定向效果。
function c44932065.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前卡片是否与该效果相关联，并且成功特殊召唤了这张卡。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
