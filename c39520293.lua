--ジャンク・メイル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡为同调素材的同调怪兽不会被战斗破坏。
-- ②：这个回合没有送去墓地的这张卡在墓地存在，原本卡名包含「战士」、「同调士」、「星尘」之内任意种的同调怪兽在自己场上存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 创建并注册两个效果：①作为同调素材时，给那只同调怪兽附加不会被战斗破坏的效果；②在墓地且满足条件下发动，特殊召唤自身，并给此卡附加离场时除外的效果，同时②有1回合1次限制。
function s.initial_effect(c)
	-- ①：这张卡为同调素材的同调怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e1:SetCondition(s.indcon)
	e1:SetOperation(s.indop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这个回合没有送去墓地的这张卡在墓地存在，原本卡名包含「战士」、「同调士」、「星尘」之内任意种的同调怪兽在自己场上存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动条件：这张卡不是这个回合被送去墓地的场合才能发动，即“这个回合没有送去墓地的这张卡在墓地存在”。
	e2:SetCondition(aux.exccon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果触发条件：这张卡作为同调素材被使用（r==REASON_SYNCHRO）时触发。
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- ①效果处理：取得那次同调召唤的怪兽，给它附加“不会被战斗破坏”的效果，效果持续到该怪兽离场等标准重置时。
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ①：这张卡为同调素材的同调怪兽不会被战斗破坏。这个卡名的②的效果1回合只能使用1次。②：这个回合没有送去墓地的这张卡在墓地存在，原本卡名包含「战士」、「同调士」、「星尘」之内任意种的同调怪兽在自己场上存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"「废品盔甲」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
-- 过滤函数：筛选出自己场上表侧表示、原本卡名包含「战士」「同调士」「星尘」其中一种字段、且为同调怪兽的卡。
function s.spfilter(c)
	return c:IsFaceup() and c:IsOriginalSetCard(0xa3,0x1017,0x66) and c:IsType(TYPE_SYNCHRO)
end
-- ②效果发动时的合法性检查：自己主要怪兽区有空位、这张卡能够被特殊召唤，并且自己场上存在符合条件的同调怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在至少1张满足s.spfilter条件的同调怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息，声明效果处理时将要特殊召唤的对象是这张卡本身，供其他卡的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤成功时，为这张卡附加“从场上离开的场合除外”的永续效果，该效果不能被无效，并持续到卡离场。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与发动效果保持关联（没有被其他效果移走或重置），然后将其表侧表示特殊召唤；只有特殊召唤成功时才继续附加除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
