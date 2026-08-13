--THE・スターハム
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，丢弃1张手卡才能发动。那1只作为同调素材的怪兽从自己墓地特殊召唤。这个效果特殊召唤的怪兽当作调整使用。
-- ②：这张卡在墓地存在的场合，丢弃2张手卡才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 定义此卡的效果注册函数：添加同调召唤手续（调整+调整以外怪兽1只以上），并注册效果①（同调召唤成功时丢弃1张手卡，从墓地特殊召唤1只同调素材并当作调整使用）和效果②（墓地中丢弃2张手卡将自身特殊召唤，且这样特殊召唤的此卡离场时除外）
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整 + 1只以上调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，丢弃1张手卡才能发动。那1只作为同调素材的怪兽从自己墓地特殊召唤。这个效果特殊召唤的怪兽当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤素材"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，丢弃2张手卡才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡是以同调召唤的方式成功召唤的场合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的代价函数：从手卡丢弃1张卡作为发动代价
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己手卡中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：选择并丢弃1张手卡，丢弃原因视为代价和丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果①选择特殊召唤对象的过滤条件：该怪兽是这次同调召唤使用的素材（通过reason和reasoncard判定），在自己墓地，且可以被特殊召唤
function s.spfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动目标检查：同调召唤使用的素材组存在、其中有满足条件的怪兽，并且自己场上主怪兽区有空位
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	if chk==0 then return mg:GetCount()>0 and mg:FilterCount(s.spfilter,nil,e,tp,c)
		-- 检查自己场上是否有可用的主怪兽区空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 将同调召唤的素材组设置为当前连锁的对象，以便后续处理时获取
	Duel.SetTargetCard(mg)
	-- 设置操作信息：特殊召唤对象为素材组，预计特殊召唤1只，用于相关效果的连锁检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,1,0,0)
end
-- 效果①的处理：从对象素材中选出1只满足条件且不受王家长眠之谷影响的怪兽，进行特殊召唤，并让它获得当作调整使用的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得同调召唤的素材卡组
	local mg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=mg:Filter(Card.IsRelateToChain,nil)
	-- 处理时再次确认自己场上存在可用的主怪兽区空格，否则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	-- 从关联的素材卡中筛选并选择1只满足特招条件且不受王家长眠之谷影响的怪兽
	local sg=g:FilterSelect(tp,aux.NecroValleyFilter(s.spfilter),1,1,nil,e,tp,e:GetHandler())
	local tc=sg:GetFirst()
	-- 如果成功选出素材，则以表侧表示进行特殊召唤（分步特殊召唤的一步）
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽当作调整使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 完成分步特殊召唤处理，与SpecialSummonStep配套使用
		Duel.SpecialSummonComplete()
	end
end
-- 效果②的代价函数：从手卡丢弃2张卡作为发动代价
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己手卡中是否存在至少2张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) end
	-- 实际执行代价：选择并丢弃2张手卡，丢弃原因视为代价和丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
-- 效果②的发动目标检查：自己场上主怪兽区有空位，且这张卡可以被特殊召唤
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认自己场上主怪兽区有空格且这张卡满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡自身作为特殊召唤对象，用于相关效果的连锁检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的处理：从墓地特殊召唤自身，如果成功则给它附加“从场上离开时除外”且不会被无效的效果
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡仍与效果关联、不受王家长眠之谷影响，并且特殊召唤成功（返回数量大于0）
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
