--マシンナーズ・メタルクランチ
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上没有表侧表示的卡存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡的①的方法召唤的这张卡的原本攻击力变成1800。
-- ③：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把3只机械族·地属性怪兽给对方观看，对方从那之中随机选1只。那1只怪兽加入自己手卡，剩下的怪兽回到卡组。
function c69838761.initial_effect(c)
	-- ①：自己场上没有表侧表示的卡存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69838761,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c69838761.ntcon)
	e1:SetOperation(c69838761.ntop)
	c:RegisterEffect(e1)
	-- ③：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把3只机械族·地属性怪兽给对方观看，对方从那之中随机选1只。那1只怪兽加入自己手卡，剩下的怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69838761,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,69838761)
	e2:SetTarget(c69838761.thtg)
	e2:SetOperation(c69838761.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 不用解放作召唤的判定条件
function c69838761.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定召唤需要的解放怪兽数量为0、自身等级在5星以上且怪兽区域有空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判定自己场上没有表侧表示的卡存在
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
-- 不用解放作召唤成功时的处理（设置原本攻击力）
function c69838761.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- ②：这张卡的①的方法召唤的这张卡的原本攻击力变成1800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 过滤卡组中可检索的机械族·地属性怪兽
function c69838761.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检测
function c69838761.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组中是否存在至少3只满足条件的机械族·地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69838761.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置连锁运营信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际处理
function c69838761.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的机械族·地属性怪兽
	local g=Duel.GetMatchingGroup(c69838761.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 给对方玩家确认选出的3张卡
		Duel.ConfirmCards(1-tp,sg)
		local tg=sg:RandomSelect(1-tp,1)
		-- 洗切自己卡组
		Duel.ShuffleDeck(tp)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将随机选出的那1张怪兽加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
