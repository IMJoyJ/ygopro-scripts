--エクス・ライゼオル
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把额外卡组1只超量怪兽送去墓地，从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，若4星·4阶的怪兽以外的表侧表示怪兽不在自己场上存在则能发动。从卡组把1只雷族·炎属性怪兽加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册①规则召唤效果（从手卡特殊召唤，需要额外卡组1只超量怪兽作代价）、②召唤成功时检索效果及其克隆版用于特殊召唤成功时检索。
function s.initial_effect(c)
	-- 对应效果原文：‘这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以把额外卡组1只超量怪兽送去墓地，从手卡特殊召唤。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"手卡特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 对应效果原文：‘②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤的场合，若4星·4阶的怪兽以外的表侧表示怪兽不在自己场上存在则能发动。从卡组把1只雷族·炎属性怪兽加入手卡。’
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
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
-- 过滤条件：额外卡组中可以作为COST送去墓地，并且是超量怪兽的卡。
function s.cfilter(c,tp)
	return c:IsAbleToGraveAsCost() and c:IsType(TYPE_XYZ)
end
-- ①规则召唤的发动条件：自己主要怪兽区有空位，且额外卡组有可作为代价的超量怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 返回条件是否成立：自己主怪兽区有空位，且额外卡组存在至少1张满足s.cfilter的超量怪兽。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
end
-- ①规则召唤的对象选择处理：从额外卡组选择1只满足条件的超量怪兽作为要送去墓地的代价，并将选择结果存入效果e。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取额外卡组中所有可作为COST的超量怪兽集合。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,nil,tp)
	-- 弹出选择提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- ①特殊召唤处理：将选择的超量怪兽送去墓地，并给发动玩家附加本回合不能从额外卡组特殊召唤非4阶超量怪兽的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的超量怪兽作为特殊召唤的代价送入墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	-- 对应效果原文：‘这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。②：这张卡召唤·特殊召唤的场合，若4星·4阶的怪兽以外的表侧表示怪兽不在自己场上存在则能发动。从卡组把1只雷族·炎属性怪兽加入手卡。’
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能从额外卡组特殊召唤非4阶超量怪兽”的誓约效果注册给当前玩家，效果持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制条件：若怪兽是额外卡组的怪兽且不是4阶超量怪兽，则不能特殊召唤。
function s.splimit(e,c)
	return not (c:IsType(TYPE_XYZ) and c:IsRank(4)) and c:IsLocation(LOCATION_EXTRA)
end
-- 检索发动条件的过滤：存在表侧表示且既不是4星也不是4阶的怪兽。
function s.confilter(c)
	return c:IsFaceup() and not (c:IsRank(4) or c:IsLevel(4))
end
-- 检索目标过滤：卡组中种族为雷族、属性为炎且可以加入手卡的怪兽。
function s.thfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- ②效果的发动条件：自己场上没有‘4星·4阶怪兽以外的表侧表示怪兽’，且卡组中存在符合条件的检索目标。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断前半部分：自己场上不存在4星·4阶怪兽以外的表侧表示怪兽。
	if chk==0 then return not Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
		-- 条件判断后半部分：卡组中存在至少1张符合检索条件的雷族·炎属性怪兽。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本次效果会将卡组中的1张卡加入手卡（CATEGORY_TOHAND），来源是卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张符合条件的雷族·炎属性怪兽加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并选择1张满足检索条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡送去持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
