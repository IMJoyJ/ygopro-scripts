--家電機塊世界エレクトリリカル・ワールド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把场地魔法卡以外的1张「机块」卡加入手卡。
-- ②：1回合1次，自己对「机块」连接怪兽的连接召唤成功的场合才能发动。从自己墓地选1只「机块」怪兽加入手卡。
-- ③：1回合1次，自己或者对方的怪兽的攻击宣言时才能发动。选自己场上1只「机块」怪兽，那个位置向其他的自己的主要怪兽区域移动。
function c3875465.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把场地魔法卡以外的1张「机块」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,3875465+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c3875465.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己对「机块」连接怪兽的连接召唤成功的场合才能发动。从自己墓地选1只「机块」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3875465,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c3875465.thcon)
	e2:SetTarget(c3875465.thtg)
	e2:SetOperation(c3875465.thop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己或者对方的怪兽的攻击宣言时才能发动。选自己场上1只「机块」怪兽，那个位置向其他的自己的主要怪兽区域移动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3875465,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c3875465.mvtg)
	e3:SetOperation(c3875465.mvop)
	c:RegisterEffect(e3)
end
-- 过滤函数，返回满足条件的「机块」卡（非场地魔法卡）
function c3875465.thfilter1(c)
	return not c:IsType(TYPE_FIELD) and c:IsSetCard(0x14b) and c:IsAbleToHand()
end
-- 发动时的效果处理，检索满足条件的卡组卡片并加入手牌
function c3875465.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组卡片组
	local g=Duel.GetMatchingGroup(c3875465.thfilter1,tp,LOCATION_DECK,0,nil)
	-- 判断是否有满足条件的卡组卡片并询问玩家是否发动效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(3875465,0)) then  --"是否从卡组把「机块」卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡片送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤函数，返回满足条件的「机块」连接怪兽
function c3875465.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x14b) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsSummonPlayer(tp)
end
-- 判断是否满足发动效果的条件（有「机块」连接怪兽特殊召唤成功）
function c3875465.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c3875465.cfilter,1,nil,tp)
end
-- 过滤函数，返回满足条件的「机块」怪兽
function c3875465.thfilter2(c)
	return c:IsSetCard(0x14b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果处理时的操作信息，准备从墓地选卡加入手牌
function c3875465.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动效果的条件（墓地有「机块」怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(c3875465.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理时的操作信息，准备从墓地选卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 发动效果，从墓地选择「机块」怪兽加入手牌
function c3875465.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地「机块」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c3875465.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤函数，返回满足条件的「机块」场上怪兽
function c3875465.mvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14b)
end
-- 设置效果处理时的条件，判断是否有「机块」怪兽且场上存在空位
function c3875465.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有「机块」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3875465.mvfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断场上是否存在空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
end
-- 发动效果，将场上「机块」怪兽移动到其他空位
function c3875465.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 提示玩家选择要移动位置的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(3875465,3))  --"请选择要移动位置的怪兽"
	-- 选择满足条件的场上「机块」怪兽
	local g=Duel.SelectMatchingCard(tp,c3875465.mvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要移动到的位置
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 选择一个可用的场上空位
		local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		local nseq=math.log(s,2)
		-- 将选择的怪兽移动到指定位置
		Duel.MoveSequence(g:GetFirst(),nseq)
	end
end
