--祝福の教会－リチューアル・チャーチ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1张魔法卡才能发动。从卡组把1只光属性仪式怪兽或者1张仪式魔法卡加入手卡。
-- ②：让自己墓地的魔法卡任意数量回到卡组，以持有和回去数量相同等级的自己墓地1只天使族·光属性怪兽为对象才能发动。那只怪兽特殊召唤。
function c95658967.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从手卡丢弃1张魔法卡才能发动。从卡组把1只光属性仪式怪兽或者1张仪式魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95658967,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,95658967)
	e2:SetCost(c95658967.thcost)
	e2:SetTarget(c95658967.thtg)
	e2:SetOperation(c95658967.thop)
	c:RegisterEffect(e2)
	-- ②：让自己墓地的魔法卡任意数量回到卡组，以持有和回去数量相同等级的自己墓地1只天使族·光属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95658967,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,95658968)
	e3:SetCost(c95658967.spcost)
	e3:SetTarget(c95658967.sptg)
	e3:SetOperation(c95658967.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡中可以丢弃的魔法卡
function c95658967.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 效果①的发动代价（Cost）处理：从手卡丢弃1张魔法卡
function c95658967.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以丢弃的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c95658967.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡中的魔法卡作为发动代价
	Duel.DiscardHand(tp,c95658967.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡组中的光属性仪式怪兽或仪式魔法卡
function c95658967.thfilter(c)
	return ((c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_LIGHT)) or c:IsType(TYPE_SPELL))
		and c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- 效果①的发动准备（Target）处理：检查卡组中是否存在可检索的卡并设置操作信息
function c95658967.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在满足条件的光属性仪式怪兽或仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c95658967.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）：从卡组将1只光属性仪式怪兽或1张仪式魔法卡加入手卡
function c95658967.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的光属性仪式怪兽或仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,c95658967.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己墓地中可以特殊召唤的天使族·光属性怪兽，且墓地中存在与其等级相同数量的魔法卡
function c95658967.spfilter(c,e,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己墓地中是否存在至少与该怪兽等级相同数量的魔法卡
		and Duel.IsExistingMatchingCard(c95658967.cfilter2,tp,LOCATION_GRAVE,0,lv,nil)
end
-- 过滤条件：自己墓地中可以回到卡组的魔法卡
function c95658967.cfilter2(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeckAsCost()
end
-- 效果②的发动代价（Cost）处理：设置标签以标记此效果需要支付代价
function c95658967.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤条件：用于效果发动时判断对象是否合法的辅助过滤函数（指定等级的天使族·光属性怪兽）
function c95658967.spfilter2(c,e,tp,lv)
	return c:IsLevel(lv) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（Target）处理：选择墓地的天使族·光属性怪兽作为对象，并让相同数量的魔法卡回到卡组作为代价
function c95658967.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c95658967.spfilter2(chkc,e,tp,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否有可用的怪兽区域空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己墓地中是否存在可以作为对象且满足特殊召唤条件的天使族·光属性怪兽
			and Duel.IsExistingTarget(c95658967.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的天使族·光属性怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c95658967.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local lv=g:GetFirst():GetLevel()
	e:SetLabel(lv)
	-- 提示玩家选择要回到卡组的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择与对象怪兽等级相同数量的自己墓地中的魔法卡
	local tg=Duel.SelectMatchingCard(tp,c95658967.cfilter2,tp,LOCATION_GRAVE,0,lv,lv,nil)
	-- 在场上/墓地中显式框选并提示被选为回到卡组代价的魔法卡
	Duel.HintSelection(tg)
	-- 将选择的魔法卡送回卡组并洗牌，作为发动的代价
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_COST)
	-- 设置操作信息：将选中的1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理（Operation）：将作为对象的怪兽特殊召唤
function c95658967.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
