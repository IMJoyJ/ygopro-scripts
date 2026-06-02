--Checkker
-- 效果：
-- 自己场上有怪兽存在的场合，这张卡不能召唤。
-- 可以把这张卡解放；从卡组把攻击力和守备力的数值相同的1只机械族怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
-- 可以从自己墓地把这张卡除外，丢弃1张手卡；在自己场上把1只「碎铁片衍生物」（机械族·地·1星·攻0/守0）特殊召唤，这衍生物不能作为融合·同调·连接召唤的素材。
-- 「检固机工」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化效果：注册不能召唤的限制、解放自身特招同攻守机械族怪兽的效果，以及墓地除外并丢弃手卡特招衍生物的效果。
function s.initial_effect(c)
	-- 自己场上有怪兽存在的场合，这张卡不能召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	e0:SetCondition(s.sumcon)
	c:RegisterEffect(e0)
	-- 可以把这张卡解放；从卡组把攻击力和守备力的数值相同的1只机械族怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 可以从自己墓地把这张卡除外，丢弃1张手卡；在自己场上把1只「碎铁片衍生物」（机械族·地·1星·攻0/守0）特殊召唤，这衍生物不能作为融合·同调·连接召唤的素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.tkcost)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
end
-- 不能召唤效果的Condition限制判定函数
function s.sumcon(e)
	-- 检查自己场上是否存在怪兽，若存在则该卡不能召唤
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 从卡组特殊召唤效果的Cost代价处理函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 解放这张卡作为发动的代价
	Duel.Release(c,REASON_COST)
end
-- 过滤从卡组特殊召唤的怪兽：攻击力和守备力数值相同的机械族怪兽
function s.spfilter(c,e,tp)
	-- 攻击力和守备力的数值相同的机械族怪兽
	return c:IsRace(RACE_MACHINE) and aux.AtkEqualsDef(c)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 从卡组特殊召唤效果的Target目标处理函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 检查解放这张卡后自己场上是否有可用的怪兽区域空格
		return Duel.GetMZoneCount(tp,c)>0
			-- 检查卡组中是否存在满足条件的可以特殊召唤的怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置从卡组特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 从卡组特殊召唤效果的Operation具体操作处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有可用的怪兽区域空格，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功特殊召唤了所选怪兽
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在结束阶段回到手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetOperation(s.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCountLimit(1)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
-- 在结束阶段将怪兽回到手卡的操作处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家展示该卡的卡片提示
	Duel.Hint(HINT_CARD,0,id)
	-- 将这只怪兽回到持有者的手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
-- 特殊召唤衍生物效果的Cost代价处理函数
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以将墓地的此卡除外
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
		-- 且自己手卡中存在可丢弃的卡片
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 将此卡除外作为发动的代价
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 丢弃1张手卡作为发动的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤衍生物效果的Target目标处理函数
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用于特殊召唤的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤对应的衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置特殊召唤衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤衍生物效果的Operation具体操作处理函数
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有可用怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 并且能特殊召唤对应的衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	-- 在自己场上创建「碎铁片衍生物」
	local token=Duel.CreateToken(tp,id+o)
	-- 如果衍生物被成功特殊召唤
	if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这衍生物不能作为融合·同调·连接召唤的素材。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e2:SetValue(s.fuslimit)
		token:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		token:RegisterEffect(e3)
	end
end
-- 融合素材限制的过滤判定函数
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
