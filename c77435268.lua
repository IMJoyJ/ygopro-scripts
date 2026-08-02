--チェツカー
-- 效果：
-- 自己场上有怪兽存在的场合，这张卡不能召唤。
-- 可以把这张卡解放；从卡组把攻击力和守备力的数值相同的1只机械族怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
-- 可以从自己墓地把这张卡除外，丢弃1张手卡；在自己场上把1只「碎铁片衍生物」（机械族·地·1星·攻0/守0）特殊召唤，这衍生物不能作为融合·同调·连接召唤的素材。
-- 「检固机工」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化效果
function s.initial_effect(c)
	-- 自己场上有怪兽存在的场合，这张卡不能召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	e0:SetCondition(s.sumcon)
	c:RegisterEffect(e0)
	-- 可以把这张卡解放；从卡组把攻击力和守备力的数值相同的1只机械族怪兽特殊召唤。
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
-- 判断自己场上是否有怪兽
function s.sumcon(e)
	-- 检查自己场上是否存在怪兽
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 发动代价：可以把这张卡解放
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 把这张卡解放作为发动的代价
	Duel.Release(c,REASON_COST)
end
-- 用于过滤攻守相同且能特殊召唤的机械族怪兽
function s.spfilter(c,e,tp)
	-- 检查怪兽是否为机械族且攻守相同
	return c:IsRace(RACE_MACHINE) and aux.AtkEqualsDef(c)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标（发动时）：从卡组把1只满足条件的怪兽特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 检查场上是否有足够的怪兽区
		return Duel.GetMZoneCount(tp,c)>0
			-- 检查卡组中是否存在满足条件的怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置当前处理的连锁的操作信息为从卡组特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组把1只怪兽特殊召唤，并在结束阶段回到手卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有怪兽区域的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择目标，内容为：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的机械族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 如果选择了卡片并且特殊召唤步骤成功
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
	-- 完成特殊召唤
	Duel.SpecialSummonComplete()
end
-- 效果处理：结束阶段怪兽回到手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示卡片效果的发动
	Duel.Hint(HINT_CARD,0,id)
	-- 怪兽回到手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
-- 发动代价：从自己墓地把这张卡除外，丢弃1张手卡
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能从自己墓地把这张卡除外
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
		-- 检查是否有可以丢弃的手卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从自己墓地把这张卡除外
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果目标（发动时）：特殊召唤「碎铁片衍生物」
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有怪兽区域的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤「碎铁片衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置当前处理的连锁的操作信息为衍生物产生
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置当前处理的连锁的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：特殊召唤「碎铁片衍生物」并施加限制
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有怪兽区域的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查是否可以特殊召唤「碎铁片衍生物」
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	-- 创建1只「碎铁片衍生物」
	local token=Duel.CreateToken(tp,id+o)
	-- 特殊召唤「碎铁片衍生物」
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
-- 检查是否为融合召唤
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
