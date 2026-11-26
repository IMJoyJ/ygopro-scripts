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
	-- 这个卡名的①的效果1回合只能使用1次。 ①：以自己墓地1只鱼族怪兽为对象才能发动。那只怪兽加入手卡。
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
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c63509474.condition)
	e3:SetTarget(c63509474.target)
	e3:SetOperation(c63509474.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查是否为墓地中可加入手卡的鱼族怪兽
function c63509474.thfilter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToHand()
end
-- 检查自己墓地是否存在可加入手卡的鱼族怪兽，选择1只作为对象并设置操作信息
function c63509474.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c63509474.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1只可作为对象加入手卡的鱼族怪兽
	if chk==0 then return Duel.IsExistingTarget(c63509474.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示控制者从墓地选择要加入手卡的鱼族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只鱼族怪兽作为本次连锁的对象
	local g=Duel.SelectTarget(tp,c63509474.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将对象怪兽加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理，确认对象怪兽仍与效果关联后将其加入自己手卡
function c63509474.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象选择的墓地鱼族怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的鱼族怪兽加入自己手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 发动条件检查，确认之前由自己控制的这张卡是被对方的效果破坏而送去墓地的
function c63509474.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY)
		and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
-- 过滤函数，检查是否为鱼族怪兽且能加入手卡或在有空位时可特殊召唤
function c63509474.filter(c,e,tp,spchk)
	return c:IsRace(RACE_FISH) and (c:IsAbleToHand() or spchk and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 发动条件检查，根据自己怪兽区是否有空位确认卡组存在可加入手卡或特殊召唤的鱼族怪兽
function c63509474.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己主要怪兽区是否至少有1个空位
		local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在至少1只满足加入手卡或特殊召唤条件的鱼族怪兽
		return Duel.IsExistingMatchingCard(c63509474.filter,tp,LOCATION_DECK,0,1,nil,e,tp,spchk)
	end
end
-- 效果处理，从卡组选1只鱼族怪兽加入手卡或表侧表示特殊召唤
function c63509474.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时确认自己怪兽区是否有可用空位
	local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 提示控制者从卡组选择要加入手卡或特殊召唤的鱼族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组选择1只满足条件的鱼族怪兽
	local g=Duel.SelectMatchingCard(tp,c63509474.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,spchk)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		if spchk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断是特殊召唤还是加入手卡（无法加手或玩家选择特召时执行特殊召唤）
			and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选中的鱼族怪兽表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选中的鱼族怪兽加入自己手卡
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的鱼族怪兽
			Duel.ConfirmCards(1-tp,sc)
		end
	end
end
