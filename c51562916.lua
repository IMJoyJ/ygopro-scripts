--大波小波
-- 效果：
-- 自己场上表侧表示存在的水属性怪兽全破坏。之后，可以从手卡特殊召唤最多和破坏数同等数量的水属性怪兽上场。
function c51562916.initial_effect(c)
	-- 效果原文内容：自己场上表侧表示存在的水属性怪兽全破坏。之后，可以从手卡特殊召唤最多和破坏数同等数量的水属性怪兽上场。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c51562916.target)
	e1:SetOperation(c51562916.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选场上表侧表示的水属性怪兽
function c51562916.dfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果作用：检查是否满足发动条件并设置连锁信息
function c51562916.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否存在满足条件的场上水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c51562916.dfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 效果作用：获取所有满足条件的场上水属性怪兽组
	local g=Duel.GetMatchingGroup(c51562916.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 效果作用：设置破坏效果的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用：筛选手卡中可特殊召唤的水属性怪兽
function c51562916.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：执行大波小波的主要效果流程
function c51562916.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取所有满足条件的场上水属性怪兽组
	local g=Duel.GetMatchingGroup(c51562916.dfilter,tp,LOCATION_MZONE,0,nil)
	-- 效果作用：将满足条件的怪兽破坏
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 效果作用：获取玩家场上可用怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct==0 or ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ct>ft then ct=ft end
	-- 效果作用：获取手卡中可特殊召唤的水属性怪兽组
	local sg=Duel.GetMatchingGroup(c51562916.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 效果作用：判断是否选择特殊召唤以及是否有满足条件的怪兽
	if sg:GetCount()~=0 and Duel.SelectYesNo(tp,aux.Stringid(51562916,0)) then  --"是否要特殊召唤水属性怪兽？"
		-- 效果作用：中断当前连锁处理
		Duel.BreakEffect()
		-- 效果作用：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local spg=sg:Select(tp,1,ct,nil)
		-- 效果作用：将选中的怪兽特殊召唤上场
		Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
	end
end
