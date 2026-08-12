--白の救済
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己墓地1只鱼族怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡被对方的效果破坏送去墓地的场合才能发动。从卡组把1只鱼族怪兽加入手卡或特殊召唤。
function c63509474.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己墓地1只鱼族怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63509474,0))  --"墓地回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,63509474)
	e2:SetTarget(c63509474.thtg)
	e2:SetOperation(c63509474.thop)
	c:RegisterEffect(e2)
	-- ②：这张卡被对方的效果破坏送去墓地的场合才能发动。从卡组把1只鱼族怪兽加入手卡或特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c63509474.condition)
	e3:SetTarget(c63509474.target)
	e3:SetOperation(c63509474.operation)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地可以加入手牌的鱼族怪兽
function c63509474.thfilter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToHand()
end
-- ①号效果的发动准备与目标选择
function c63509474.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c63509474.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1只可以加入手牌的鱼族怪兽
	if chk==0 then return Duel.IsExistingTarget(c63509474.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只鱼族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c63509474.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①号效果的效果处理
function c63509474.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 检查是否满足“这张卡在自己场上被对方的效果破坏并送去墓地”的条件
function c63509474.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY)
		and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
-- 过滤卡组中可以加入手牌或可以特殊召唤的鱼族怪兽
function c63509474.filter(c,e,tp,spchk)
	return c:IsRace(RACE_FISH) and (c:IsAbleToHand() or spchk and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ②号效果的发动准备
function c63509474.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否有空余的怪兽区域
		local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的鱼族怪兽
		return Duel.IsExistingMatchingCard(c63509474.filter,tp,LOCATION_DECK,0,1,nil,e,tp,spchk)
	end
end
-- ②号效果的效果处理
function c63509474.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域
	local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择1只满足条件的鱼族怪兽
	local g=Duel.SelectMatchingCard(tp,c63509474.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,spchk)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		if spchk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 若该怪兽不能加入手牌，或者玩家在“加入手牌”和“特殊召唤”中选择了“特殊召唤”
			and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选择的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选择的怪兽加入手牌
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sc)
		end
	end
end
