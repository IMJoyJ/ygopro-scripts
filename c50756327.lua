--魔導原典 クロウリー
-- 效果：
-- 魔法师族怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把「魔导书」卡3种类给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩下的卡回到卡组。
-- ②：只要这张卡在怪兽区域存在，自己在5星以上的魔法师族怪兽召唤的场合需要的解放可以不用。这个效果1回合只能适用1次。
function c50756327.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2只魔法师族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_SPELLCASTER),2,2)
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把「魔导书」卡3种类给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩下的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50756327,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,50756327)
	e1:SetCondition(c50756327.thcon)
	e1:SetTarget(c50756327.thtg)
	e1:SetOperation(c50756327.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己在5星以上的魔法师族怪兽召唤的场合需要的解放可以不用。这个效果1回合只能适用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50756327,1))  --"不用解放召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCountLimit(1)
	e2:SetCondition(c50756327.ntcon)
	e2:SetTarget(c50756327.nttg)
	c:RegisterEffect(e2)
end
-- 效果发动的条件：确认此卡是以连接召唤方式特殊召唤成功
function c50756327.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤器：筛选出卡组中属于「魔导书」系列且能加入手牌的卡片
function c50756327.thfilter(c)
	return c:IsSetCard(0x106e) and c:IsAbleToHand()
end
-- 效果处理时的判断：确认卡组中是否存在至少3种不同的「魔导书」系列卡片
function c50756327.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取满足条件的「魔导书」系列卡片组
		local dg=Duel.GetMatchingGroup(c50756327.thfilter,tp,LOCATION_DECK,0,nil)
		return dg:GetClassCount(Card.GetCode)>=3
	end
	-- 设置连锁操作信息，表示将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理流程：从满足条件的卡片中选择3种不同种类的卡片给对方确认，然后随机选1张加入自己手牌并洗切卡组
function c50756327.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「魔导书」系列卡片组
	local g=Duel.GetMatchingGroup(c50756327.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		-- 向玩家提示选择要给对方确认的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从符合条件的卡片中选择3种不同种类的卡片组成子组
		local sg1=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		-- 将所选的卡片公开给对方玩家查看
		Duel.ConfirmCards(1-tp,sg1)
		local cg=sg1:RandomSelect(1-tp,1)
		local tc=cg:GetFirst()
		tc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将选定的卡片加入自己的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将卡组进行洗切
		Duel.ShuffleDeck(tp)
	end
end
-- 效果发动的条件：确认召唤时不需要支付解放费用
function c50756327.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足不需支付解放的条件（即没有需要支付的解放数量且场上存在空位）
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 召唤目标筛选器：筛选出等级5以上且为魔法师族的怪兽
function c50756327.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_SPELLCASTER)
end
