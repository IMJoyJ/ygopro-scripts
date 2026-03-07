--アルカナフォースⅩⅨ－THE SUN
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：持有进行投掷硬币效果的卡在场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·反转召唤·特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。
-- ●表：把持有进行投掷硬币效果的1张魔法卡从卡组到自己场上盖放。
-- ●里：双方的魔法与陷阱区域的卡全部破坏。
local s,id,o=GetID()
-- 创建卡片效果，注册手卡特殊召唤效果、投掷硬币效果及盖放魔法卡效果
function s.initial_effect(c)
	-- 记录该卡与另一张卡（卡号73206827）的关联
	aux.AddCodeList(c,73206827)
	-- ①：持有进行投掷硬币效果的卡在场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·反转召唤·特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COIN+CATEGORY_DESTROY+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.cointg)
	e2:SetOperation(s.coinop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
s.toss_coin=true
-- 定义用于筛选场上具有投掷硬币效果的卡的过滤函数
function s.cfilter(c)
	-- 筛选场上正面表示且具有投掷硬币效果的卡
	return c:IsFaceup() and c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN))
end
-- 判断手卡特殊召唤效果的发动条件：场上是否存在具有投掷硬币效果的卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在具有投掷硬币效果的卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 设置手卡特殊召唤效果的目标处理函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件：场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行手卡特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置投掷硬币效果的目标处理函数
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置投掷硬币操作信息
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 定义用于筛选可盖放的投掷硬币魔法卡的过滤函数
function s.setfilter(c)
	-- 筛选魔法卡类型、可盖放且具有投掷硬币效果的卡
	return c:IsType(TYPE_SPELL) and c:IsSSetable() and c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN))
end
-- 定义用于筛选场上魔法与陷阱卡的过滤函数
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetSequence()<5
end
-- 执行投掷硬币效果的操作函数
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=-1
	-- 判断玩家是否受到卡号73206827效果影响
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 检查卡组中是否存在可盖放的投掷硬币魔法卡
		local b1=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查场上是否存在魔法与陷阱区域的卡
		local b2=Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil)
		if b1 and not b2 then
			-- 提示对方玩家选择了盖放魔法卡效果
			Duel.Hint(HINT_OPSELECTED,1-tp,60)
			res=1
		end
		if b2 and not b1 then
			-- 提示对方玩家选择了破坏魔法与陷阱区域卡效果
			Duel.Hint(HINT_OPSELECTED,1-tp,61)
			res=0
		end
		if b1 and b2 then
			-- 通过选项选择投掷硬币结果
			res=aux.SelectFromOptions(tp,
				{b1,60,1},
				{b2,61,0})
		end
	-- 进行一次投掷硬币
	else res=Duel.TossCoin(tp,1) end
	if res==1 then
		-- 提示选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择一张可盖放的投掷硬币魔法卡
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的魔法卡盖放到场上
			Duel.SSet(tp,g:GetFirst())
		end
	elseif res==0 then
		-- 获取场上所有魔法与陷阱区域的卡
		local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
		-- 将场上所有魔法与陷阱区域的卡破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
