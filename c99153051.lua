--蕾禍ノ毬首
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把手卡1只昆虫族·植物族·爬虫类族怪兽送去墓地，从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。「蕾祸之毬首」以外的自己的卡组·除外状态的最多2张「蕾祸」卡加入手卡（同名卡最多1张）。那之后，选自己1张手卡除外。这个回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 定义卡片的初始化函数，创建①特殊召唤规则效果e1（限制1回合1次、手卡送墓特招）和②召唤/特殊召唤时检索效果e2/e3（响应召唤与特殊召唤）。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以把手卡1只昆虫族·植物族·爬虫类族怪兽送去墓地，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。「蕾祸之毬首」以外的自己的卡组·除外状态的最多2张「蕾祸」卡加入手卡（同名卡最多1张）。那之后，选自己1张手卡除外。这个回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索「蕾祸」卡"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义①效果的送墓代价过滤器：手卡的怪兽必须是昆虫族·植物族·爬虫类族，且可以作为代价送去墓地。
function s.filter(c)
	return c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsAbleToGraveAsCost()
end
-- ①特殊召唤规则的发动条件：若请求特殊召唤的卡为nil则视为规则适用；否则检查自己主怪兽区是否有空位，以及手牌是否存在能作为代价的怪兽（不能是这张卡自身）。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上主怪兽区是否有可用的空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足s.filter条件的怪兽（可作为特殊召唤代价），并排除这张卡自身。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,c)
end
-- ①特殊召唤规则的处理：从手牌选择1只昆虫族·植物族·爬虫类族怪兽作为代价送去墓地，完成特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 弹出“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌中选择1只满足s.filter条件的怪兽作为特殊召唤的代价。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,c)
	-- 将选择的怪兽作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义②检索的过滤条件：不是「蕾祸之毬首」、为表侧表示、属于「蕾祸」系列、且可以加入手牌。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsFaceupEx() and c:IsSetCard(0x1ab) and c:IsAbleToHand()
end
-- ②的发动条件与目标设定：获取自己卡组和除外状态中满足条件的「蕾祸」卡，检查自己能否除外手牌且存在至少1张可检索对象，并设置处理信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组和除外状态中满足s.thfilter条件的卡片组。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil)
	-- 发动判定：若玩家能够除外手牌，且检索候选卡数量至少为1，则②效果满足发动条件。
	if chk==0 then return Duel.IsPlayerCanRemove(tp) and g:GetCount()>=1 end
	-- 设置效果处理信息：本次处理包含将卡组/除外状态的卡加入手牌的类别，预计处理1张，来源为卡组和除外状态。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- ②效果的实际处理：从候选卡中选择1～2张卡名互不相同的「蕾祸」卡加入手牌，然后选择自己1张手卡除外，最后设置本回合只能特殊召唤昆虫族·植物族·爬虫类族怪兽的自肃。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取当前满足s.thfilter条件的「蕾祸」卡组。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil)
	-- 弹出“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从候选卡中通过aux.dncheck确保卡名互不重复，选择1～2张卡加入手牌。
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
	-- 若成功选择且加入手牌成功，则继续执行让对方确认、洗牌、除外手牌和设置自肃的后续处理。
	if tg1 and Duel.SendtoHand(tg1,nil,REASON_EFFECT)~=0 then
		-- 让对方确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,tg1)
		-- 洗切己方手牌。
		Duel.ShuffleHand(tp)
		-- 弹出“请选择要除外的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从手牌中选择1张可以除外的卡。
		local tg2=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
		if #tg2>0 then
			-- 中断当前效果，使后续除外处理视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 将所选手牌表侧表示除外。
			Duel.Remove(tg2,POS_FACEUP,REASON_EFFECT)
		end
	end
	-- 这个回合，自己不是昆虫族·植物族·爬虫类族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给发动玩家，本回合内持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃的限制条件：要特殊召唤的怪兽不是昆虫族·植物族·爬虫类族时，禁止特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE)
end
