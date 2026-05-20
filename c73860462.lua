--ワンダー・エクシーズ
-- 效果：
-- ①：用自己场上的怪兽为素材把1只超量怪兽超量召唤。
function c73860462.initial_effect(c)
	-- ①：用自己场上的怪兽为素材把1只超量怪兽超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c73860462.xyztg)
	e1:SetOperation(c73860462.xyzop)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否可以进行超量召唤
function c73860462.xyzfilter(c)
	return c:IsXyzSummonable(nil)
end
-- 效果发动的目标过滤与操作信息设置
function c73860462.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以进行超量召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c73860462.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息，表示该效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：选择1只可以超量召唤的怪兽并进行超量召唤
function c73860462.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中所有可以进行超量召唤的怪兽组
	local g=Duel.GetMatchingGroup(c73860462.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 让玩家对选定的怪兽进行超量召唤
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end
