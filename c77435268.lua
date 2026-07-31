--チェツカー
-- 效果：
-- 自己场上有怪兽存在的场合，这张卡不能召唤。
-- 可以把这张卡解放；从卡组把攻击力和守备力的数值相同的1只机械族怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
-- 可以从自己墓地把这张卡除外，丢弃1张手卡；在自己场上把1只「碎铁片衍生物」（机械族·地·1星·攻0/守0）特殊召唤，这衍生物不能作为融合·同调·连接召唤的素材。
-- 「检固机工」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册召唤限制、解放特召卡组怪兽效果、墓地除外特召衍生物效果
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
-- 召唤限制条件：自己场上有怪兽存在
function s.sumcon(e)
	-- 检查自己场上是否存在怪兽
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 解放特召效果Cost：将自身解放
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 把此卡解放
	Duel.Release(c,REASON_COST)
end
-- 卡组特召过滤条件：攻守数值相同的机械族怪兽
function s.spfilter(c,e,tp)
	-- 检查卡片是否为机械族且攻击力与守备力数值相同
	return c:IsRace(RACE_MACHINE) and aux.AtkEqualsDef(c)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 解放特召效果发动准备：设置从卡组特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 检查解放自身后怪兽区域是否有空位
		return Duel.GetMZoneCount(tp,c)>0
			-- 检查卡组是否存在满足攻守相同条件的机械族怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置连锁操作信息：从卡组特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 解放特召效果处理：从卡组特殊召唤1只攻守相同的机械族怪兽，并注册结束阶段回收效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只攻守相同的机械族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 进行特殊召唤的第一阶段处理，成功时为其注册后续效果
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
	-- 完成特殊召唤过程
	Duel.SpecialSummonComplete()
end
-- 结束阶段回收效果处理：将该怪兽返回手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动提示
	Duel.Hint(HINT_CARD,0,id)
	-- 将目标怪兽返回手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
-- 墓地特召衍生物Cost：墓地自身除外并丢弃1张手卡
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：检查自身是否能作为墓地Cost除外
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
		-- 检查手卡中是否有可丢弃的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 把墓地的这张卡除外
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从手卡丢弃1张卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 墓地特召衍生物发动准备：设置生成与特殊召唤衍生物的操作信息
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能在场上特殊召唤「碎铁片衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置连锁操作信息：生成1个衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息：特殊召唤1个衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 墓地特召衍生物效果处理：生成「碎铁片衍生物」并赋予素材限制
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查玩家是否能特殊召唤衍生物，若不能则中断处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	-- 创建「碎铁片衍生物」
	local token=Duel.CreateToken(tp,id+o)
	-- 将衍生物表侧表示特殊召唤，成功时为其注册素材限制
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
-- 融合素材限制判定：检查召唤类型是否为融合召唤
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
