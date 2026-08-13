--アルカナフォースⅩⅨ－THE SUN
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：持有进行投掷硬币效果的卡在场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·反转召唤·特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。
-- ●表：把持有进行投掷硬币效果的1张魔法卡从卡组到自己场上盖放。
-- ●里：双方的魔法与陷阱区域的卡全部破坏。
local s,id,o=GetID()
-- 初始化效果注册：①效果为手卡起动效果，满足条件时特殊召唤自身，1回合1次；②效果为召唤·反转召唤·特殊召唤成功时必发的硬币效果（通过克隆效果分别注册到三种召唤成功时点），处理抛硬币后的表里分支。
function s.initial_effect(c)
	-- 将光之结界（73206827）登记为该卡关联卡名，便于识别相关效果或显示文本。
	aux.AddCodeList(c,73206827)
	-- 对应效果原文：“这个卡名的①的效果1回合只能使用1次。①：持有进行投掷硬币效果的卡在场上存在的场合才能发动。这张卡从手卡特殊召唤。”
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
	-- 对应效果原文：“②：这张卡召唤·反转召唤·特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。●表：把持有进行投掷硬币效果的1张魔法卡从卡组到自己场上盖放。●里：双方的魔法与陷阱区域的卡全部破坏。”
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
-- 定义过滤器：用于筛选场上表侧表示且拥有投掷硬币效果（EFFECT_FLAG_COIN）的卡。
function s.cfilter(c)
	-- 判断卡是否表侧表示，并且其效果中带有投掷硬币标志（EFFECT_FLAG_COIN）。
	return c:IsFaceup() and c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN))
end
-- ①效果的发动条件：确认双方场上存在至少1张表侧表示且带有投掷硬币效果的卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足s.cfilter的卡片（表侧且带投掷硬币效果），有则返回真。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 特殊召唤的目标判定：在发动前（chk==0）检查自己主怪兽区是否有空位，且自身能否被玩家tp以表侧表示特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主怪兽区可用空格数是否大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次发动包含特殊召唤，对象为本卡，数量1，为后续时点/触发检测提供依据。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤处理：若这张卡仍与该效果保持关联，则将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片c以表侧表示特殊召唤到tp场上，不检查苏生限制和召唤条件。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动目标：必发效果，无额外条件；同时登记抛硬币的操作信息以备检测。
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本效果包含投掷硬币，目标玩家为tp，数量1次。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 定义盖放卡过滤器：筛选卡组中为魔法卡、可以盖放、且带有投掷硬币效果的卡。
function s.setfilter(c)
	-- 判断卡是否为魔法卡、能否盖放、且效果带投掷硬币标志。
	return c:IsType(TYPE_SPELL) and c:IsSSetable() and c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN))
end
-- 定义破坏过滤器：筛选项为魔法·陷阱卡，且位于非场地格的魔法与陷阱区域（sequence<5排除场地格）。
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetSequence()<5
end
-- ②效果实际处理：若光之结界适用则允许在表里都可选时选择（否则按可用分支自动决定）；不适用则投掷硬币。表侧效果：从卡组选1张带硬币效果的魔法卡盖放；里侧效果：破坏双方魔法与陷阱区域（非场地格）的所有卡。
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=-1
	-- 检测【光之结界】(73206827)的效果是否生效中。若在生效中，自己的「秘仪之力」怪兽的召唤·反转召唤·特殊召唤时发动的效果不进行投掷硬币而选里表的其中1个适用。
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 光之结界适用时，检查卡组中是否存在1张可盖放且带投掷硬币效果的魔法卡。
		local b1=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 光之结界适用时，检查双方魔法与陷阱区域是否存在1张可破坏的魔陷卡（非场地格）。
		local b2=Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil)
		if b1 and not b2 then
			-- 向对方玩家提示“选择了表面（表）”的选项结果。
			Duel.Hint(HINT_OPSELECTED,1-tp,60)
			res=1
		end
		if b2 and not b1 then
			-- 向对方玩家提示“选择了里面（里）”的选项结果。
			Duel.Hint(HINT_OPSELECTED,1-tp,61)
			res=0
		end
		if b1 and b2 then
			-- 当表里两种效果都可行时，让当前玩家在表（盖放）和里（破坏）之间选择1个适用。
			res=aux.SelectFromOptions(tp,
				{b1,60,1},
				{b2,61,0})
		end
	-- 若光之结界不在适用中，则正常进行1次投掷硬币：1为表，0为里。
	else res=Duel.TossCoin(tp,1) end
	if res==1 then
		-- 向玩家显示“请选择要盖放的卡”的选择提示，用于卡组选择。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从自己的卡组选择1张满足s.setfilter（可盖放且带硬币效果的魔法卡）的卡。
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的那张魔法卡盖放到自己场上。
			Duel.SSet(tp,g:GetFirst())
		end
	elseif res==0 then
		-- 获取双方魔法与陷阱区域内所有满足s.desfilter（魔陷且非场地格）的卡。
		local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
		-- 以效果原因破坏这些卡。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
