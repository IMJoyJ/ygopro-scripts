--バイス・シャーク
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，把自己场上1只鱼族怪兽解放才能发动。从卡组把1只鱼族「鲨」怪兽特殊召唤。这个回合，自己不是水属性怪兽不能特殊召唤。
-- ②：持有这张卡作为素材中的「鲨龙兽」超量怪兽得到以下效果。
-- ●1回合1次，魔法·陷阱卡的效果发动时，把这张卡2个超量素材取除才能发动。那个效果无效并破坏。
local s,id,o=GetID()
-- 初始化卡片效果：①召唤·特召成功时解放鱼族特召卡组鱼族「鲨」怪兽；②作为「鲨龙兽」超量素材时赋予其无效并破坏魔陷效果的能力
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，把自己场上1只鱼族怪兽解放才能发动。从卡组把1只鱼族「鲨」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：持有这张卡作为素材中的「鲨龙兽」超量怪兽得到以下效果。●1回合1次，魔法·陷阱卡的效果发动时，把这张卡2个超量素材取除才能发动。那个效果无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"魔法·陷阱卡的效果发动无效（白煞鲨）"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 定义鱼族怪兽解放过滤函数，同时检查解放后是否能留出怪兽区域
function s.cfilter(c,e,tp)
	-- 检查怪兽是否为鱼族，且解放该怪兽后自己场上是否有空余的怪兽区域
	return c:IsRace(RACE_FISH) and Duel.GetMZoneCount(tp,c)>0
		and (c:IsControler(tp) or c:IsFaceup())
end
-- 定义卡组鱼族「鲨」怪兽的特殊召唤过滤函数
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FISH) and c:IsSetCard(0x1b8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义①效果的发动代价：解放自己场上1只鱼族怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的鱼族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,e,tp) end
	-- 选择自己场上1只鱼族怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,e,tp)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 定义①效果的发动准备：检查卡组中是否存在可特召的鱼族「鲨」怪兽并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可特殊召唤的鱼族「鲨」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义①效果的效果处理：从卡组特殊召唤1只鱼族「鲨」怪兽，并适用本回合只能特殊召唤水属性怪兽的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的鱼族「鲨」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 特殊召唤选中的怪兽
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是水属性怪兽不能特殊召唤。②：持有这张卡作为素材中的「鲨龙兽」超量怪兽得到以下效果。●1回合1次，魔法·陷阱卡的效果发动时，把这张卡2个超量素材取除才能发动。那个效果无效并破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该特殊召唤限制效果，使其在当前回合内对玩家生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非水属性的怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 定义赋予效果的发动条件：自身是「鲨龙兽」超量怪兽、未被战斗破坏，且对方发动了可以被无效的魔法·陷阱卡的效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x11b8)
		and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查发动的效果是否为魔法·陷阱卡的效果，且该效果可以被无效
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
-- 定义赋予效果的发动代价：取除这张卡的2个超量素材
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 定义赋予效果的发动准备：设置无效与破坏的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示发动了该无效效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置无效效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏卡片的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义赋予效果的效果处理：使该魔法·陷阱卡的效果无效并破坏
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功无效该效果，且该卡在场上（或与效果相关联）
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该魔法·陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
