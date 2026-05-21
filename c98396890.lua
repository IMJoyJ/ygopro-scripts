--ヴィジョン・リゾネーター
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场上有5星以上的暗属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把有「红莲魔龙」的卡名记述的1张魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果的手卡特殊召唤规则和②效果的送墓检索效果。
function s.initial_effect(c)
	-- 注册该卡记述了「红莲魔龙」（卡号70902743）的卡名。
	aux.AddCodeList(c,70902743)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：场上有5星以上的暗属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被送去墓地的场合才能发动。从卡组把有「红莲魔龙」的卡名记述的1张魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示、5星以上、暗属性怪兽的条件函数。
function s.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(5)
end
-- 特殊召唤规则的条件判定函数，检查怪兽区域是否有空位以及场上是否存在满足条件的怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上的怪兽区域是否有可用的空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方场上是否存在至少1只满足条件的怪兽（表侧表示、5星以上、暗属性）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤卡组中记述有「红莲魔龙」卡名的魔法·陷阱卡且能加入手卡的条件函数。
function s.thfilter(c)
	-- 判定卡片是否记述有「红莲魔龙」卡名、是否为魔法或陷阱卡、以及是否能加入手卡。
	return aux.IsCodeListed(c,70902743) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的发动准备（Target）函数，检查卡组中是否存在可检索的卡，并设置检索的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动判定阶段（chk==0），检查自己卡组中是否存在至少1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的操作信息，表示该效果会从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理（Operation）函数，执行从卡组选择卡片加入手卡并给对方确认的操作。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示其选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选择1张满足检索条件的卡。
	local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #tg>0 then
		-- 将选中的卡片因效果加入玩家手卡。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,tg)
	end
end
