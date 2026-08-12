--V・HERO ファリス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1只其他的「英雄」怪兽才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「幻影英雄 独善人」以外的1只「幻影英雄」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。这个效果的发动后，直到回合结束时自己不是「英雄」怪兽不能从额外卡组特殊召唤。
function c18094166.initial_effect(c)
	-- ①：从手卡丢弃1只其他的「英雄」怪兽才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18094166,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,18094166)
	e1:SetCost(c18094166.spcost)
	e1:SetTarget(c18094166.sptg)
	e1:SetOperation(c18094166.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「幻影英雄 独善人」以外的1只「幻影英雄」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。这个效果的发动后，直到回合结束时自己不是「英雄」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18094166,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,18094167)
	e2:SetTarget(c18094166.target)
	e2:SetOperation(c18094166.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断手卡中是否包含其他「英雄」怪兽（除了自身）
function c18094166.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8) and c:IsDiscardable()
end
-- 检查手卡中是否存在满足条件的「英雄」怪兽并将其丢弃作为发动①效果的代价
function c18094166.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的「英雄」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c18094166.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃手卡中满足条件的1只「英雄」怪兽
	Duel.DiscardHand(tp,c18094166.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 判断是否满足特殊召唤的条件
function c18094166.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c18094166.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选卡组中非「幻影英雄 独善人」的「幻影英雄」怪兽
function c18094166.filter(c)
	return c:IsSetCard(0x5008) and c:IsType(TYPE_MONSTER) and not c:IsForbidden() and not c:IsCode(18094166)
end
-- 判断是否满足发动②效果的条件
function c18094166.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「幻影英雄」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c18094166.filter,tp,LOCATION_DECK,0,1,nil)
		-- 检查场上是否有足够的魔法与陷阱区域
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 执行②效果的操作，选择并放置一张「幻影英雄」怪兽到魔法与陷阱区域，并设置不能从额外卡组特殊召唤的效果
function c18094166.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查场上是否有足够的魔法与陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从卡组中选择1张满足条件的「幻影英雄」怪兽
		local g=Duel.SelectMatchingCard(tp,c18094166.filter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的怪兽移动到魔法与陷阱区域
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 将选中的怪兽转换为永续陷阱卡
			local e1=Effect.CreateEffect(c)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		end
	end
	-- 设置直到回合结束时自己不能从额外卡组特殊召唤的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c18094166.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使对方不能从额外卡组特殊召唤非「英雄」怪兽
	Duel.RegisterEffect(e2,tp)
end
-- 限制效果的过滤函数，用于判断是否为非「英雄」怪兽且在额外卡组
function c18094166.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x8) and c:IsLocation(LOCATION_EXTRA)
end
