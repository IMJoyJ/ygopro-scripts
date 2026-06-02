--幻爪の王ガゼル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只恶魔族·5星怪兽或1张「合成兽融合」加入手卡。
-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1只幻想魔族怪兽加入手卡。
local s,id,o=GetID()
-- 初始化此卡的效果注册：在卡片关联列表中注册「合成兽融合」；注册①效果（召唤・特殊召唤成功的场合，从卡组检索恶魔族5星怪兽或「合成兽融合」）；注册②效果（作为融合素材送去墓地的场合，从卡组检索幻想魔族怪兽）。
function s.initial_effect(c)
	-- 在卡片的关联卡片列表中注册「合成兽融合」，以便进行相关卡名检测。
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
-- 过滤卡组中卡密码为63136489（「合成兽融合」）或等级为5的恶魔族怪兽，且可以加入手卡的卡。
function s.filter(c)
	return (c:IsCode(63136489) or c:IsLevel(5) and c:IsRace(RACE_FIEND)) and c:IsAbleToHand()
end
-- 检查此卡是否作为融合召唤的素材被送入墓地，以判断是否满足效果发动条件。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤卡组中种族为幻想魔族的怪兽，且可以加入手卡的卡。
function s.ifilter(c)
	return c:IsRace(RACE_ILLUSION) and c:IsAbleToHand()
end
-- 效果发动的合法性检查与操作准备通用函数，确认卡组中是否存在可以加入手卡的卡，并设置加入手卡的操作信息。
function s.thtg(f)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk)
				-- 判断卡组中是否存在满足检索过滤条件的卡，以作为效果发动的可行性检查。
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,LOCATION_DECK,0,1,nil) end
				-- 设置当前连锁的操作信息，标记该效果包含从卡组将1张卡加入手卡的效果分类。
				Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
			end
end
-- 效果实效处理通用函数：提示并让玩家从卡组检索满足条件的卡片，加入手卡后向对方展示。
function s.thop(f)
	return  function(e,tp,eg,ep,ev,re,r,rp)
				-- 提示玩家选择要加入手牌的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				-- 让玩家从卡组中选择1张满足过滤条件的卡。
				local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_DECK,0,1,1,nil)
				-- 通过卡片效果将选中的卡片加入玩家手卡。
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 将加入手牌的卡展示给对方玩家确认。
				Duel.ConfirmCards(1-tp,g)
			end
end
