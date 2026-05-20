--ペンデュラム・リボーン
-- 效果：
-- ①：选1只自己的额外卡组的表侧表示的灵摆怪兽或者自己墓地的灵摆怪兽特殊召唤。
function c77826734.initial_effect(c)
	-- ①：选1只自己的额外卡组的表侧表示的灵摆怪兽或者自己墓地的灵摆怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c77826734.target)
	e1:SetOperation(c77826734.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为可特殊召唤的、自己墓地的灵摆怪兽或额外卡组表侧表示的灵摆怪兽，且场上有可用的怪兽区域
function c77826734.filter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若卡片在墓地，则需要自己场上有空余的怪兽区域
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 若卡片在额外卡组，则需要自己场上有能让额外卡组怪兽出场的空余怪兽区域
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果发动时的目标过滤与操作信息设置
function c77826734.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己墓地或额外卡组是否存在至少1只满足特殊召唤条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77826734.filter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示此效果包含从墓地或额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 效果处理的执行函数
function c77826734.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地（受王家长眠之谷影响）或额外卡组中选择1只满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c77826734.filter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
