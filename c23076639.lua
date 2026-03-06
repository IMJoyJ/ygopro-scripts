--幻爪の王ガゼル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只恶魔族·5星怪兽或1张「合成兽融合」加入手卡。
-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1只幻想魔族怪兽加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个触发效果和一个条件效果
function s.initial_effect(c)
	-- 记录该卡拥有「合成兽融合」的卡号，用于效果判定
	aux.AddCodeList(c,63136489)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只恶魔族·5星怪兽或1张「合成兽融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg(s.filter))
	e1:SetOperation(s.thop(s.filter))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1只幻想魔族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.thtg(s.ifilter))
	e3:SetOperation(s.thop(s.ifilter))
	c:RegisterEffect(e3)
end
-- 过滤函数，用于检索满足条件的恶魔族5星怪兽或「合成兽融合」
function s.filter(c)
	return (c:IsCode(63136489) or c:IsLevel(5) and c:IsRace(RACE_FIEND)) and c:IsAbleToHand()
end
-- 条件函数，判断该卡是否因融合召唤而进入墓地
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION
end
-- 过滤函数，用于检索满足条件的幻想魔族怪兽
function s.ifilter(c)
	return c:IsRace(RACE_ILLUSION) and c:IsAbleToHand()
end
-- 构造效果的处理函数，设置检索和回手的处理信息
function s.thtg(f)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk)
				-- 检查是否满足检索条件，即卡组中是否存在符合条件的卡
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,LOCATION_DECK,0,1,nil) end
				-- 设置连锁操作信息，表示将从卡组检索1张卡并加入手牌
				Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
			end
end
-- 构造效果的发动函数，执行检索和加入手牌的操作
function s.thop(f)
	return  function(e,tp,eg,ep,ev,re,r,rp)
				-- 提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				-- 从卡组中选择1张满足条件的卡
				local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_DECK,0,1,1,nil)
				-- 将选中的卡加入手牌
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 向对方确认加入手牌的卡
				Duel.ConfirmCards(1-tp,g)
			end
end
