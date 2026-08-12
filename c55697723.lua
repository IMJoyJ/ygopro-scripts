--浮上するビッグ・ジョーズ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：魔法卡发动的回合的自己主要阶段才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只鱼族「鲨」怪兽加入手卡。
-- ③：把这张卡在水属性怪兽的超量召唤使用的场合，可以把这张卡的等级当作3星或5星使用。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特召、检索鱼族「鲨」怪兽、作为水属性超量素材时当作3星或5星，以及魔法卡发动计数器
function s.initial_effect(c)
	-- ①：魔法卡发动的回合的自己主要阶段才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只鱼族「鲨」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
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
	-- ③：把这张卡在水属性怪兽的超量召唤使用的场合，可以把这张卡的等级当作3星或5星使用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_XYZ_LEVEL)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.xyzlv)
	e4:SetLabel(3)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetLabel(5)
	c:RegisterEffect(e5)
	-- 添加自定义活动计数器，用于检测是否有魔法卡发动
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 过滤函数，用于计数器排除魔法卡的发动（即只对魔法卡的发动返回false，从而使计数器增加）
function s.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 特殊召唤效果的发动条件：本回合有魔法卡发动过
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己或对方在本回合是否发动过魔法卡
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0 or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的处理信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：将自身特殊召唤，并注册“直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤”的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只鱼族「鲨」怪兽加入手卡。③：把这张卡在水属性怪兽的超量召唤使用的场合，可以把这张卡的等级当作3星或5星使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册限制效果（不能从额外卡组特殊召唤超量怪兽以外的怪兽）
	Duel.RegisterEffect(e1,tp)
end
-- 限制过滤函数：限制不能从额外卡组特殊召唤非超量怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 检索过滤条件：卡组中属于鱼族且带有「鲨」字段、并且能加入手牌的怪兽
function s.filter(c)
	return c:IsSetCard(0x1b8) and c:IsRace(RACE_FISH) and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查卡组中是否存在满足条件的怪兽，并设置检索和加入手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1只满足条件的鱼族「鲨」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的处理信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组选择1只鱼族「鲨」怪兽加入手牌，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的鱼族「鲨」怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 等级变更函数：若作为水属性怪兽的超量素材，则可以将等级当作3星或5星使用
function s.xyzlv(e,c,rc)
	if rc:IsAttribute(ATTRIBUTE_WATER) then
		return c:GetLevel()+0x10000*e:GetLabel()
	else
		return c:GetLevel()
	end
end
