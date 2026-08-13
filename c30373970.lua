--結瘴龍ティスティナ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「结瘴龙 提斯蒂娜」以外的1只「提斯蒂娜」怪兽加入手卡。这个回合中，自己场上的光属性「提斯蒂娜」怪兽的攻击力上升1000。
-- ②：这张卡被送去墓地的场合，若场地区域有卡存在则能发动。这张卡特殊召唤。这个回合，自己不是「提斯蒂娜」怪兽不能从手卡·墓地特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册：为这张卡创建并注册①效果（召唤/特殊召唤成功时检索「提斯蒂娜」怪兽并提升光属性「提斯蒂娜」怪兽攻击力）和②效果（被送去墓地时若场地区有卡则自身特殊召唤并附加回合自肃），同名卡①②分别1回合1次。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「结瘴龙 提斯蒂娜」以外的1只「提斯蒂娜」怪兽加入手卡。
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
	-- ②：这张卡被送去墓地的场合，若场地区域有卡存在则能发动。这张卡特殊召唤。
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
-- 检索过滤器：筛选符合条件的「提斯蒂娜」怪兽，要求卡名不是「结瘴龙 提斯蒂娜」、属于「提斯蒂娜」系列、是怪兽卡且能够加入手卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1a4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动条件与操作信息：检测卡组中是否存在1张符合条件的「提斯蒂娜」怪兽；若存在，在连锁信息中登记“从卡组把1张卡加入手卡”的处理。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：卡组中存在至少1张符合s.thfilter的「提斯蒂娜」怪兽时才允许发动检索效果。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：登记当前连锁处理的是“从卡组把1张卡加入手卡”（不取对象，数量1，目标玩家为tp），供相关卡片/效果进行时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理：让玩家从卡组选择1张符合条件的「提斯蒂娜」怪兽加入手卡并让对方确认；然后给己方场上光属性「提斯蒂娜」怪兽附加攻击力上升1000的效果，持续到结束阶段。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出卡片选择提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选择1张符合s.thfilter的卡（不取对象，数量1）作为加入手卡的对象。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡以效果原因加入手卡（送入其持有者的手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个回合中，自己场上的光属性「提斯蒂娜」怪兽的攻击力上升1000。②：这张卡被送去墓地的场合，若场地区域有卡存在则能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(1000)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击力上升效果注册为场上永续效果，作用于己方场上的光属性「提斯蒂娜」怪兽，数值1000，结束阶段重置。
	Duel.RegisterEffect(e1,tp)
end
-- 攻击力上升的适用对象判定：怪兽必须属于「提斯蒂娜」系列且为光属性。
function s.atktg(e,c)
	return c:IsSetCard(0x1a4) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果②的发动条件判定与操作信息：己方主要怪兽区有空位、场地区域存在卡、且这张卡可以被特殊召唤；满足后登记特殊召唤自身的信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：己方主要怪兽区必须存在可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件判定：场地区域（双方场地卡区域合计）必须存在至少1张卡。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：登记本次处理为将这张卡特殊召唤（1只，对象为效果发动者自身），供相关时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②处理：若仍满足特召条件且此卡不受王家长眠之谷影响并与连锁相关，则将其表侧特殊召唤；随后给自己附加“这个回合不能从手卡·墓地特殊召唤非「提斯蒂娜」怪兽”的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 特殊召唤执行前判定：己方怪兽区仍有空位、此卡不受王家长眠之谷影响、且此卡与当前效果连锁仍有联系（仍在墓地且未被除外）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and aux.NecroValleyFilter()(c) and c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到己方场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是「提斯蒂娜」怪兽不能从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将特殊召唤限制效果注册到玩家（己方），持续到结束阶段：不能从手卡·墓地特殊召唤非「提斯蒂娜」怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制条件判断：位于手卡或墓地，且不是「提斯蒂娜」系列的怪兽，则禁止特殊召唤。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) and not c:IsSetCard(0x1a4)
end
