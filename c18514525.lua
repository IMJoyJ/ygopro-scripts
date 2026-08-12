--プランキッズ・ロケット
-- 效果：
-- 「调皮宝贝」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤成功的场合才能发动。这个回合这张卡攻击力下降1000，并且也能直接攻击。
-- ②：把这张卡解放，以融合怪兽以外的自己墓地2只「调皮宝贝」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c18514525.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置此卡的融合召唤条件为使用2个「调皮宝贝」卡组的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x120),2,true)
	-- ①：这张卡融合召唤成功的场合才能发动。这个回合这张卡攻击力下降1000，并且也能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18514525,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,18514525)
	e1:SetCondition(c18514525.atkcon)
	e1:SetOperation(c18514525.atkop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，以融合怪兽以外的自己墓地2只「调皮宝贝」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18514525,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,18514526)
	e2:SetCost(c18514525.spcost)
	e2:SetTarget(c18514525.sptg)
	e2:SetOperation(c18514525.spop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为融合召唤 summoned
function c18514525.atkcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 使此卡攻击力下降1000，并且获得直接攻击能力
function c18514525.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or atk<1000 then return end
	-- 使此卡攻击力下降1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		-- 使此卡获得直接攻击能力
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 过滤满足条件的卡：卡面朝上或在墓地、可作为费用除外、具有效果25725326（青眼精灵龙）
function c18514525.excostfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(25725326,tp)
end
-- 检查是否满足特殊召唤的费用条件：场上怪兽数量大于1且剩余卡组中不同卡名数量大于等于2
function c18514525.costfilter(c,tp,g)
	local tg=g:Clone()
	tg:RemoveCard(c)
	-- 检查场上怪兽数量大于1且剩余卡组中不同卡名数量大于等于2
	return Duel.GetMZoneCount(tp,c)>1 and tg:GetClassCount(Card.GetCode)>=2
end
-- 设置此卡的发动费用：选择满足条件的卡作为解放或除外的费用
function c18514525.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	-- 获取场上和墓地中满足条件的卡组
	local g=Duel.GetMatchingGroup(c18514525.excostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	-- 获取墓地中满足特殊召唤条件的卡组
	local tg=Duel.GetMatchingGroup(c18514525.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if e:GetHandler():IsReleasable() then g:AddCard(e:GetHandler()) end
	if chk==0 then
		e:SetLabel(100)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133) and g:IsExists(c18514525.costfilter,1,nil,tp,tg)
	end
	local cg=g:Filter(c18514525.costfilter,nil,tp,tg)
	local tc
	if #cg>1 then
		-- 提示玩家选择要解放或代替解放除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25725326,0))  --"请选择要解放或代替解放除外的卡"
		tc=cg:Select(tp,1,1,nil):GetFirst()
	else
		tc=cg:GetFirst()
	end
	local te=tc:IsHasEffect(25725326,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将选中的卡除外作为费用
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 将选中的卡解放作为费用
		Duel.Release(tc,REASON_COST)
	end
end
-- 过滤满足条件的卡：属于「调皮宝贝」卡组、不是融合怪兽、可作为效果对象、可特殊召唤
function c18514525.spfilter(c,e,tp)
	return c:IsSetCard(0x120) and not c:IsType(TYPE_FUSION)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置此卡的特殊召唤目标：选择2张满足条件的卡
function c18514525.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetLabel()==100 end
	e:SetLabel(0)
	-- 获取墓地中满足特殊召唤条件的卡组
	local g=Duel.GetMatchingGroup(c18514525.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从满足条件的卡组中选择2张不同卡名的卡
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 设置选中的卡为特殊召唤的目标
	Duel.SetTargetCard(g1)
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 执行特殊召唤操作：将选中的卡特殊召唤到场上，并设置不能攻击效果
function c18514525.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁的目标卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or ft<=0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft<g:GetCount() then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	local tc=g:GetFirst()
	while tc do
		-- 特殊召唤一张卡
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 设置特殊召唤的怪兽在本回合不能攻击
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
