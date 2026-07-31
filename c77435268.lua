--チェツカー
-- 效果：
-- 自己场上有怪兽存在的场合，这张卡不能召唤。
-- 可以把这张卡解放；从卡组把攻击力和守备力的数值相同的1只机械族怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
-- 可以从自己墓地把这张卡除外，丢弃1张手卡；在自己场上把1只「碎铁片衍生物」（机械族·地·1星·攻0/守0）特殊召唤，这衍生物不能作为融合·同调·连接召唤的素材。
-- 「检固机工」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册场上有怪兽时召唤限制、解放自身卡组特召攻守相同机械族效果及墓地除外特召衍生物效果
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
	-- 可以从自己墓地把这张卡除外，丢弃1张手卡；在自己场把1只「碎铁片衍生物」（机械族·地·1星·攻0/守0）特殊召唤
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
-- 召唤限制条件：己方场上存在怪兽
function s.sumcon(e)
	-- 检查己方怪兽区域是否存在怪兽
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- ①效果Cost：解放场上的自身
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 解放场上的自身
	Duel.Release(c,REASON_COST)
end
-- 卡组特召过滤条件：机械族且攻击力与守备力数值相等
function s.spfilter(c,e,tp)
	-- 检查怪兽是否为机械族且攻击力等于守备力
	return c:IsRace(RACE_MACHINE) and aux.AtkEqualsDef(c)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动准备：检查可用区域与卡组符合条件的怪兽，并设置连锁操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 检查解放自身后主要怪兽区域是否有空位
		return Duel.GetMZoneCount(tp,c)>0
			-- 检查卡组是否存在攻守相同的机械族怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选1只攻守相同的机械族怪兽特殊召唤，并注册结束阶段回手效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 怪兽区域无空位时终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的机械族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特召步骤并注册后续处理
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
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 结束阶段效果处理：将特召的怪兽返回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片效果发动提示
	Duel.Hint(HINT_CARD,0,id)
	-- 将特召怪兽送回持有者手牌
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
-- ②效果Cost检查：墓地的自身能否除外且手牌是否有可丢弃的卡
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地的自身是否能够除外
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
		-- 检查手牌中是否存在可丢弃的卡片
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 将墓地的自身除外
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从手牌丢弃1张卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ②效果发动准备：检查怪兽区空位与衍生物特召权限，并设置连锁操作信息
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能够特殊召唤指定的衍生怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置连锁操作信息：生成1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果处理：特殊召唤1只「碎铁片衍生物」，并赋予不能作为融合/同调/连接素材的限制
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查玩家是否仍可特殊召唤该衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	-- 生成1只「碎铁片衍生物」卡片对象
	local token=Duel.CreateToken(tp,id+o)
	-- 将生成衍生物成功表侧表示特殊召唤后注册素材限制
	if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这衍生物不能作为融合·同调·连接素材的素材。
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
-- 融合素材限制判断：检查召唤方式是否为融合召唤
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
