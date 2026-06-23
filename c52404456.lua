--マドルチェ・メッセンジェラート
-- 效果：
-- ①：这张卡特殊召唤时才能发动。从卡组把1张「魔偶甜点」魔法·陷阱卡加入手卡。这个效果在自己场上有兽族「魔偶甜点」怪兽存在的场合才能发动和处理。
-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
function c52404456.initial_effect(c)
	-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52404456,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c52404456.retcon)
	e1:SetTarget(c52404456.rettg)
	e1:SetOperation(c52404456.retop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤时才能发动。从卡组把1张「魔偶甜点」魔法·陷阱卡加入手卡。这个效果在自己场上有兽族「魔偶甜点」怪兽存在的场合才能发动和处理。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52404456,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c52404456.shcon)
	e2:SetTarget(c52404456.shtg)
	e2:SetOperation(c52404456.shop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否因破坏而送去墓地，且为对方破坏，且之前在自己的控制下
function c52404456.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 设置效果处理时将此卡送回卡组的操作信息
function c52404456.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将此卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 执行将此卡送回卡组的效果处理
function c52404456.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以洗牌方式送回卡组
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤函数：检查场上是否存在表侧表示的兽族「魔偶甜点」怪兽
function c52404456.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x71) and c:IsRace(RACE_BEAST)
end
-- 判断自己场上是否存在兽族「魔偶甜点」怪兽
function c52404456.shcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在兽族「魔偶甜点」怪兽
	return Duel.IsExistingMatchingCard(c52404456.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤函数：检查卡组中是否存在「魔偶甜点」魔法或陷阱卡
function c52404456.filter(c)
	return c:IsSetCard(0x71) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果处理时从卡组检索一张「魔偶甜点」魔法或陷阱卡的操作信息
function c52404456.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「魔偶甜点」魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c52404456.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将一张「魔偶甜点」魔法或陷阱卡送入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行从卡组检索并加入手牌的效果处理
function c52404456.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上不存在兽族「魔偶甜点」怪兽则不发动效果
	if not Duel.IsExistingMatchingCard(c52404456.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张「魔偶甜点」魔法或陷阱卡
	local g=Duel.SelectMatchingCard(tp,c52404456.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果方式送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
