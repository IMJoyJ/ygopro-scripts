--超竜災禍
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己的手卡·墓地·除外状态的1只「征龙」怪兽特殊召唤。那之后，可以只用自己场上的「征龙」怪兽为素材进行1只「征龙」超量怪兽的超量召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己的除外状态的「征龙」怪兽任意数量为对象才能发动（相同属性最多1只）。那些怪兽回到墓地。
local s,id,o=GetID()
-- 注册两个效果：①特殊召唤并可能超量召唤；②墓地发动，回收除外的「征龙」怪兽
function s.initial_effect(c)
	-- ①：自己的手卡·墓地·除外状态的1只「征龙」怪兽特殊召唤。那之后，可以只用自己场上的「征龙」怪兽为素材进行1只「征龙」超量怪兽的超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己的除外状态的「征龙」怪兽任意数量为对象才能发动（相同属性最多1只）。那些怪兽回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收效果"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「征龙」怪兽用于特殊召唤
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1c4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌·墓地·除外状态是否存在「征龙」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置特殊召唤的卡为操作对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 过滤场上满足条件的「征龙」怪兽用于超量召唤
function s.mfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1c4) and not c:IsType(TYPE_TOKEN)
end
-- 过滤满足条件的「征龙」超量怪兽
function s.xyzfilter(c,mg)
	return c:IsSetCard(0x1c4) and c:IsXyzSummonable(mg)
end
-- 处理①效果的发动和执行：选择特殊召唤的怪兽并进行超量召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「征龙」怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 执行特殊召唤并判断是否成功
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 刷新场上信息
		Duel.AdjustAll()
		-- 获取场上满足条件的「征龙」怪兽用于超量召唤
		local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 判断是否存在满足条件的「征龙」超量怪兽
		if Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
			-- 询问玩家是否进行超量召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行超量召唤？"
			-- 获取满足条件的「征龙」超量怪兽
			local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 执行超量召唤
			Duel.XyzSummon(tp,xyz,mg,1,6)
		end
	end
end
-- 过滤满足条件的除外「征龙」怪兽
function s.tgfilter(c,e)
	return c:IsSetCard(0x1c4) and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e) and c:IsFaceup()
end
-- 处理②效果的发动和执行：选择除外的「征龙」怪兽并将其送入墓地
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取满足条件的除外「征龙」怪兽
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_REMOVED,0,nil,e)
	if chk==0 then return #tg>0 end
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 设置额外检查函数用于属性判断
	aux.GCheckAdditional=aux.dabcheck
	-- 选择满足条件的除外「征龙」怪兽
	local g=tg:SelectSubGroup(tp,aux.TRUE,false,1,7)
	-- 清除额外检查函数
	aux.GCheckAdditional=nil
	-- 设置操作对象为选中的除外「征龙」怪兽
	Duel.SetTargetCard(g)
	-- 设置将选中怪兽送入墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 处理②效果的最终处理：将选中的除外怪兽送入墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的目标卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡送入墓地
		Duel.SendtoGrave(tg,REASON_EFFECT+REASON_RETURN)
	end
end
