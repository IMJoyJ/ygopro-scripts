--ギアギアチェンジ
-- 效果：
-- 「齿轮齿轮变形」在1回合只能发动1张。
-- ①：以自己墓地的「齿轮齿轮人」怪兽2只以上为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤，只用那些怪兽为素材把1只超量怪兽超量召唤。
function c29087919.initial_effect(c)
	-- 效果原文内容：「齿轮齿轮变形」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,29087919+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c29087919.target)
	e1:SetOperation(c29087919.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选满足条件的墓地齿轮齿轮人怪兽
function c29087919.filter(c,e,tp)
	return c:IsSetCard(0x1072) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：检查额外怪兽区的超量怪兽是否可以使用指定素材进行XYZ召唤
function c29087919.xyzfilter(c,mg,ct)
	return c:IsXyzSummonable(mg,2,ct)
end
-- 效果作用：检查所选怪兽组是否满足卡名各不相同且能用于XYZ召唤的条件
function c29087919.fgoal(sg,exg)
	-- 效果作用：检查所选怪兽组是否满足卡名各不相同且能用于XYZ召唤的条件
	return aux.dncheck(sg) and exg:IsExists(Card.IsXyzSummonable,1,nil,sg,#sg,#sg)
end
-- 效果作用：判断是否满足发动条件，包括玩家能特殊召唤2次、未受青眼精灵龙影响、场上空位足够、满足子组选择条件
function c29087919.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果作用：获取玩家墓地所有齿轮齿轮人怪兽
	local mg=Duel.GetMatchingGroup(c29087919.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 效果作用：获取玩家场上可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 效果作用：获取玩家额外怪兽区中可使用指定素材进行XYZ召唤的超量怪兽
	local exg=Duel.GetMatchingGroup(c29087919.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg,ct)
	-- 效果作用：判断玩家是否可以特殊召唤2次
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and ct>1 and mg:CheckSubGroup(c29087919.fgoal,2,ct,exg) end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=mg:SelectSubGroup(tp,c29087919.fgoal,false,2,ct,exg)
	-- 效果作用：设置当前连锁的目标卡片为所选怪兽组
	Duel.SetTargetCard(sg1)
	-- 效果作用：设置操作信息为特殊召唤所选怪兽组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg1,sg1:GetCount(),0,0)
end
-- 效果作用：筛选与效果相关的怪兽并判断是否可以特殊召唤
function c29087919.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：检查额外怪兽区的超量怪兽是否可以使用指定素材进行XYZ召唤
function c29087919.spfilter(c,mg,ct)
	return c:IsXyzSummonable(mg,ct,ct)
end
-- 效果原文内容：①：以自己墓地的「齿轮齿轮人」怪兽2只以上为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤，只用那些怪兽为素材把1只超量怪兽超量召唤。
function c29087919.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果作用：获取当前连锁的目标卡片并筛选出与效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c29087919.filter2,nil,e,tp)
	-- 效果作用：将目标怪兽特殊召唤到场上
	local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	-- 效果作用：刷新场上信息
	Duel.AdjustAll()
	if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<ct then return end
	-- 效果作用：获取玩家额外怪兽区中可使用指定素材进行XYZ召唤的超量怪兽
	local xyzg=Duel.GetMatchingGroup(c29087919.spfilter,tp,LOCATION_EXTRA,0,nil,g,ct)
	if ct>=2 and xyzg:GetCount()>0 then
		-- 效果作用：提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 效果作用：使用指定素材对目标超量怪兽进行XYZ召唤
		Duel.XyzSummon(tp,xyz,g)
	end
end
