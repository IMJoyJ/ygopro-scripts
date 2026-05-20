--ドラコニアの海竜騎兵
-- 效果：
-- ←7 【灵摆】 7→
-- 「德拉科尼亚的海龙骑兵」的灵摆效果1回合只能使用1次。
-- ①：自己或者对方的怪兽被战斗破坏时才能发动。从手卡把1只通常怪兽特殊召唤。
-- 【怪兽描述】
-- 龙人族国家德拉科尼亚帝国所拥有的龙骑士团海兵部队。擅长从深海里无声无息地偷偷靠近的隐秘作战。跟对岸的迪隆公国兵之间处于围绕领海不断发生小冲突的状态。
function c82114013.initial_effect(c)
	-- 启用灵摆怪兽的专属属性与效果（如灵摆召唤、灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- 「德拉科尼亚的海龙骑兵」的灵摆效果1回合只能使用1次。①：自己或者对方的怪兽被战斗破坏时才能发动。从手卡把1只通常怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,82114013)
	e2:SetTarget(c82114013.sptg)
	e2:SetOperation(c82114013.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中可以被特殊召唤的通常怪兽
function c82114013.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查与操作信息设置（Target函数）
function c82114013.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只可以特殊召唤的通常怪兽
		and Duel.IsExistingMatchingCard(c82114013.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行逻辑（Operation函数）
function c82114013.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的通常怪兽
	local g=Duel.SelectMatchingCard(tp,c82114013.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
