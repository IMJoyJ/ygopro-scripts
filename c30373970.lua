--結瘴龍ティスティナ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「结瘴龙 提斯蒂娜」以外的1只「提斯蒂娜」怪兽加入手卡。这个回合中，自己场上的光属性「提斯蒂娜」怪兽的攻击力上升1000。
-- ②：这张卡被送去墓地的场合，若场地区域有卡存在则能发动。这张卡特殊召唤。这个回合，自己不是「提斯蒂娜」怪兽不能从手卡·墓地特殊召唤。
local s,id,o=GetID()
-- 创建并注册该卡的三个效果，分别对应①②效果的发动条件和处理
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「结瘴龙 提斯蒂娜」以外的1只「提斯蒂娜」怪兽加入手卡。这个回合中，自己场上的光属性「提斯蒂娜」怪兽的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合，若场地区域有卡存在则能发动。这张卡特殊召唤。这个回合，自己不是「提斯蒂娜」怪兽不能从手卡·墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义检索过滤条件：非自身且为提斯蒂娜卡组、怪兽类型、可加入手牌
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1a4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的发动条件：确认卡组中存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 设置检索效果的发动条件：确认卡组中存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的连锁信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理检索效果的发动：选择并加入手牌，确认对方查看，再添加攻击力提升效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 创建并注册攻击力提升效果：自己场上的光属性提斯蒂娜怪兽攻击力上升1000
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(1000)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击力提升效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义攻击力提升效果的目标过滤条件：提斯蒂娜卡组且光属性
function s.atktg(e,c)
	return c:IsSetCard(0x1a4) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 设置特殊召唤效果的发动条件：确认场上存在空位、场地区域有卡、自身可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 设置特殊召唤效果的发动条件：确认场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 设置特殊召唤效果的发动条件：确认场地区域有卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的连锁信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理特殊召唤效果的发动：确认满足条件后特殊召唤自身，并注册不能特殊召唤非提斯蒂娜怪兽的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断特殊召唤是否满足条件：确认场上存在空位、自身未被王家长眠之谷影响、自身在连锁中
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and aux.NecroValleyFilter()(c) and c:IsRelateToChain() then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建并注册不能特殊召唤非提斯蒂娜怪兽的效果：本回合不能从手卡或墓地特殊召唤非提斯蒂娜怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义不能特殊召唤效果的目标过滤条件：在手卡或墓地且非提斯蒂娜怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) and not c:IsSetCard(0x1a4)
end
