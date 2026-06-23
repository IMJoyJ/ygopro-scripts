--海晶乙女シーエンジェル
-- 效果：
-- 4星以下的「海晶少女」怪兽1只
-- 自己对「海晶少女 海天使」1回合只能有1次连接召唤。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「海晶少女」魔法卡加入手卡。
function c30691817.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用1到1个满足条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,c30691817.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c30691817.condition)
	e1:SetOperation(c30691817.regop)
	c:RegisterEffect(e1)
	-- 从卡组把1张「海晶少女」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30691817,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,30691817)
	e2:SetCondition(c30691817.condition)
	e2:SetTarget(c30691817.thtg)
	e2:SetOperation(c30691817.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选4星以下且属于海晶少女卡组的怪兽
function c30691817.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkSetCard(0x12b)
end
-- 判断是否为连接召唤 summoned
function c30691817.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 创建一个影响对方玩家的永续效果，禁止对方特殊召唤海晶少女海天使
function c30691817.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 禁止对方特殊召唤海晶少女海天使的连接召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c30691817.splimit)
	-- 将效果注册给指定玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标为海晶少女海天使且召唤类型为连接召唤
function c30691817.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(30691817) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 过滤函数，用于筛选海晶少女卡组的魔法卡并能加入手牌
function c30691817.thfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置连锁处理信息，确定要处理的卡为1张来自卡组的魔法卡
function c30691817.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c30691817.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，确定要处理的卡为1张来自卡组的魔法卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果，选择并把魔法卡加入手牌
function c30691817.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c30691817.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
