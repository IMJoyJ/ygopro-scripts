--コールド・タイガー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只5星以上的魔法师族·水属性怪兽或1张「极寒冰柱」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包括记录卡名「极寒冰柱」，以及注册该卡召唤或特殊召唤成功的检索效果
function s.initial_effect(c)
	-- 在脚本中记录这张卡涉及到的特定卡名「极寒冰柱」
	aux.AddCodeList(c,88477149)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只5星以上的魔法师族·水属性怪兽或1张「极寒冰柱」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 卡组检索过滤条件：卡名为「极寒冰柱」（代码88477149），或水属性、魔法师族且等级在5星以上的怪兽，且能加入手牌
function s.thfilter(c)
	return (c:IsCode(88477149) or (c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelAbove(5)))
		and c:IsAbleToHand()
end
-- 检索效果的发动目标检测，设定检索卡组中1张满足过滤条件的卡加入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置在效果处理时将1张卡组的卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行操作：从卡组中选择1张满足条件的卡加入手牌，并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，指示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
