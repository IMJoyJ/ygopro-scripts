--エクス・ライゼオル
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把额外卡组1只超量怪兽送去墓地，从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，若4星·4阶的怪兽以外的表侧表示怪兽不在自己场上存在则能发动。从卡组把1只雷族·炎属性怪兽加入手卡。
local s,id,o=GetID()
-- 创建并注册两个效果：①手卡特殊召唤效果和②召唤·特殊召唤时检索效果
function s.initial_effect(c)
	-- ①：这张卡可以把额外卡组1只超量怪兽送去墓地，从手卡特殊召唤。
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
	-- ②：这张卡召唤·特殊召唤的场合，若4星·4阶的怪兽以外的表侧表示怪兽不在自己场上存在则能发动。从卡组把1只雷族·炎属性怪兽加入手卡。
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
-- 过滤函数，用于检查额外卡组中是否存在可作为cost送去墓地的超量怪兽
function s.cfilter(c,tp)
	return c:IsAbleToGraveAsCost() and c:IsType(TYPE_XYZ)
end
-- 判断特殊召唤条件是否满足：场上存在空位且额外卡组存在超量怪兽
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断额外卡组是否存在至少1只超量怪兽
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
end
-- 设置特殊召唤目标：选择1只额外卡组的超量怪兽送去墓地
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取额外卡组中所有满足条件的超量怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,nil,tp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤操作：将选中的超量怪兽送去墓地并设置后续限制
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的超量怪兽以特殊召唤原因送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	-- 创建并注册一个场上的效果，禁止玩家从额外卡组特殊召唤非4阶超量怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标：禁止非4阶超量怪兽从额外卡组特殊召唤
function s.splimit(e,c)
	return not (c:IsType(TYPE_XYZ) and c:IsRank(4)) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数，用于检查场上是否存在非4星/4阶的表侧表示怪兽
function s.confilter(c)
	return c:IsFaceup() and not (c:IsRank(4) or c:IsLevel(4))
end
-- 过滤函数，用于检查卡组中是否存在雷族·炎属性怪兽
function s.thfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 设置检索效果的发动条件：场上不存在非4星/4阶的表侧表示怪兽且卡组存在符合条件的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在非4星/4阶的表侧表示怪兽
	if chk==0 then return not Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断卡组中是否存在符合条件的雷族·炎属性怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息：从卡组将1张符合条件的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果：选择1张符合条件的怪兽加入手牌并确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽以效果原因加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
