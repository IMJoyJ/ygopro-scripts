--クッキィ★ヤミーウェイ
-- 效果：
-- 调整＋调整以外的怪兽1只
-- 这张卡同调召唤的场合，可以把自己场上1只连接1怪兽当作1星调整使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，以场上最多2只表侧表示怪兽为对象才能发动。那些怪兽变成里侧守备表示。
-- ②：对方把魔法·陷阱·怪兽的效果发动时，让这张卡回到额外卡组才能发动。从自己墓地把最多2只「味美喵」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、当作调整使用的效果、同调召唤成功时改变表示形式的效果，以及对方发动效果时回到额外卡组特殊召唤墓地怪兽的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：1只调整（或满足matfilter1的怪兽）+ 1只调整以外的怪兽（满足matfilter2）。
	aux.AddSynchroMixProcedure(c,s.matfilter1,nil,nil,s.matfilter2,1,1)
	-- 这张卡同调召唤的场合，可以把自己场上1只连接1怪兽当作1星调整使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SYNCHRO_LEVEL_EX)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(s.syntg)
	e0:SetValue(s.synval)
	c:RegisterEffect(e0)
	-- ①：这张卡同调召唤的场合，以场上最多2只表侧表示怪兽为对象才能发动。那些怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tdcon)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱·怪兽的效果发动时，让这张卡回到额外卡组才能发动。从自己墓地把最多2只「味美喵」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤同调素材中的调整怪兽，或者自己场上的连接1怪兽。
function s.matfilter1(c,syncard)
	return c:IsTuner(syncard) or c:IsType(TYPE_LINK) and c:IsLink(1)
end
-- 过滤同调素材中的非调整怪兽，且不能是连接怪兽。
function s.matfilter2(c,syncard)
	return c:IsNotTuner(syncard) and not c:IsType(TYPE_LINK)
end
-- 限制当作调整使用的效果的目标为连接1怪兽。
function s.syntg(e,c)
	return c:IsType(TYPE_LINK) and c:IsLink(1)
end
-- 若用于此卡的同调召唤，则将该连接1怪兽当作1星怪兽使用。
function s.synval(e,syncard)
	if e:GetHandler()==syncard then
		return 1
	else
		return 0
	end
end
-- 检查此卡是否是通过同调召唤特殊召唤的。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的发动准备：检查并选择场上最多2只可以变成里侧守备表示的表侧表示怪兽作为对象，并设置操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanTurnSet() end
	-- 检查场上是否存在至少1只可以变成里侧守备表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 玩家选择1到2只可以变成里侧守备表示的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
	-- 设置操作信息，表示此效果包含改变表示形式的操作，涉及对象为选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
-- 效果①的处理：将作为对象的怪兽变成里侧守备表示。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理时仍与该效果关联的怪兽卡。
	local sg=Duel.GetTargetsRelateToChain():Filter(Card.IsType,nil,TYPE_MONSTER)
	if #sg==0 then return end
	-- 将这些怪兽全部变成里侧守备表示。
	Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
end
-- 检查是否为对方发动了效果。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 效果②的消耗：将此卡回到额外卡组。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	-- 将自身作为发动成本送回额外卡组。
	Duel.SendtoDeck(e:GetHandler(),nil,0,REASON_COST)
end
-- 过滤自己墓地中可以特殊召唤的「味美喵」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1ca) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查自己场上是否有空位且墓地有可特殊召唤的「味美喵」怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡离开场后是否有可用的怪兽区域，且墓地是否存在至少1只可特殊召唤的「味美喵」怪兽。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler(),tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，表示此效果包含从墓地特殊召唤怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的处理：从自己墓地选择最多2只「味美喵」怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算当前可用于特殊召唤的怪兽区域数量，最大为2。
	local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ft==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从墓地选择最多ft只不受「王家长眠之谷」影响的「味美喵」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
