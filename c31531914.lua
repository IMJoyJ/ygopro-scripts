--破械式鬼シュマ
local s,id,o=GetID()
-- 创建两个诱发效果，分别在通常召唤成功时和被破坏时发动
function s.initial_effect(c)
	-- 通常召唤成功时，自己场上特殊召唤1只等级4以下的「破械式」怪兽，然后选择场上1张卡破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 被破坏时，自己手牌或卡组中特殊召唤1只「破械式」怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「破械式」怪兽（等级4以下且非此卡）
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and not c:IsCode(id) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否可以发动效果：场上有空位且卡组中有符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上有无空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只怪兽到自己场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 获取自己场上的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	if g:GetCount()>0 then
		-- 设置连锁操作信息：准备破坏场上1张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 处理通常召唤成功时的效果，先特殊召唤再破坏
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上有无空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只符合条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 若成功特殊召唤，则继续执行后续效果
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 中断当前效果处理，使之后的效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择场上任意1张卡作为破坏对象
			local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
			if sg:GetCount()>0 then
				-- 显示选中卡的动画效果
				Duel.HintSelection(sg)
				-- 将选中的卡破坏
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
	-- 设置永续效果：自己不能特殊召唤非恶魔族怪兽，持续到回合结束
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该永续效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 设定不能特殊召唤的条件为非恶魔族怪兽
function s.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- 设定被破坏时发动效果的触发条件：因战斗或效果被破坏且之前在场上
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and not re:GetHandler():IsCode(id))) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤满足条件的「破械式」怪兽（非此卡）
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x130) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否可以发动效果：场上有空位且手牌或卡组中有符合条件的怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上有无空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌或卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只怪兽到自己场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 处理被破坏时的效果，从手牌或卡组中特殊召唤1只怪兽
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上有无空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
