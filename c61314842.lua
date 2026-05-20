--高等紋章術
-- 效果：
-- ①：以自己墓地2只「纹章兽」怪兽为对象才能发动。那2只怪兽特殊召唤，只用那2只为素材进行超量召唤。
function c61314842.initial_effect(c)
	-- ①：以自己墓地2只「纹章兽」怪兽为对象才能发动。那2只怪兽特殊召唤，只用那2只为素材进行超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c61314842.target)
	e1:SetOperation(c61314842.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以作为效果对象且可以特殊召唤的「纹章兽」怪兽
function c61314842.filter(c,e,tp)
	return c:IsSetCard(0x76) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤额外卡组中可以使用指定素材组进行超量召唤的超量怪兽
function c61314842.xyzfilter(c,mg)
	return c:IsXyzSummonable(mg,2,2)
end
-- 过滤第一只素材怪兽，要求墓地中存在另一只怪兽能与它一起作为素材进行超量召唤
function c61314842.mfilter1(c,mg,exg)
	return mg:IsExists(c61314842.mfilter2,1,c,c,exg)
end
-- 过滤第二只素材怪兽，要求这两只怪兽作为素材时，额外卡组存在可超量召唤的怪兽
function c61314842.mfilter2(c,mc,exg)
	return exg:IsExists(Card.IsXyzSummonable,1,nil,Group.FromCards(c,mc))
end
-- 效果发动时的对象选择与可行性检测
function c61314842.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中所有符合条件的「纹章兽」怪兽
	local mg=Duel.GetMatchingGroup(c61314842.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取额外卡组中可以使用墓地「纹章兽」作为素材进行超量召唤的怪兽
	local exg=Duel.GetMatchingGroup(c61314842.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	-- 在发动阶段，检测玩家是否能进行2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测玩家场上是否有2个及以上的空余怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and mg:IsExists(c61314842.mfilter1,1,nil,mg,exg) end
	-- 提示玩家选择第一只作为特殊召唤对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=mg:FilterSelect(tp,c61314842.mfilter1,1,1,nil,mg,exg)
	local tc1=sg1:GetFirst()
	-- 提示玩家选择第二只作为特殊召唤对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg2=mg:FilterSelect(tp,c61314842.mfilter2,1,1,tc1,tc1,exg)
	sg1:Merge(sg2)
	-- 将选中的2只怪兽设为效果处理的对象
	Duel.SetTargetCard(sg1)
	-- 设置效果处理信息，包含特殊召唤2只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg1,2,0,0)
end
-- 过滤仍与此效果相关且可以特殊召唤的对象怪兽
function c61314842.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的执行函数
function c61314842.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若空余怪兽区域不足2个，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取当前连锁中仍符合特殊召唤条件的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c61314842.filter2,nil,e,tp)
	if g:GetCount()<2 then return end
	-- 将符合条件的2只怪兽以表侧表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	-- 立即刷新场上信息，确保特殊召唤的怪兽状态正确
	Duel.AdjustAll()
	if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取额外卡组中可以使用这2只怪兽作为素材进行超量召唤的怪兽
	local xyzg=Duel.GetMatchingGroup(c61314842.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	if xyzg:GetCount()>0 then
		-- 提示玩家选择要进行超量召唤的超量怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 使用这2只怪兽作为素材，对选定的超量怪兽进行超量召唤
		Duel.XyzSummon(tp,xyz,g)
	end
end
