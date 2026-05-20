--輝望道
-- 效果：
-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽特殊召唤。
-- ①：以自己墓地3只怪兽为对象才能发动。那3只怪兽效果无效特殊召唤，只用那3只为素材把1只「霍普」超量怪兽超量召唤。
function c62829077.initial_effect(c)
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽特殊召唤。①：以自己墓地3只怪兽为对象才能发动。那3只怪兽效果无效特殊召唤，只用那3只为素材把1只「霍普」超量怪兽超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c62829077.cost)
	e1:SetTarget(c62829077.target)
	e1:SetOperation(c62829077.activate)
	c:RegisterEffect(e1)
end
-- 定义发动的代价，检查本回合是否进行过特殊召唤，并注册整回合不能用这张卡以外的效果特殊召唤的限制
function c62829077.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查玩家本回合是否进行过特殊召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽特殊召唤。①：以自己墓地3只怪兽为对象才能发动。那3只怪兽效果无效特殊召唤，只用那3只为素材把1只「霍普」超量怪兽超量召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c62829077.splimit)
	e1:SetLabelObject(e)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤的限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义特殊召唤限制的过滤函数，允许本卡效果以及带有特定Flag的怪兽特殊召唤
function c62829077.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return se~=e:GetLabelObject() and c:GetFlagEffect(62829077)==0
end
-- 过滤自己墓地中可以作为效果对象且可以特殊召唤的怪兽
function c62829077.filter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤额外卡组中可以用指定素材进行超量召唤的「霍普」超量怪兽
function c62829077.xyzfilter(c,mg)
	return c:IsSetCard(0x7f) and c:IsXyzSummonable(mg,3,3)
end
-- 检测是否存在第1只怪兽，使得墓地中存在能与它及另外1只怪兽一起作为素材超量召唤「霍普」怪兽的组合
function c62829077.mfilter1(c,mg,exg)
	return mg:IsExists(c62829077.mfilter2,1,c,c,mg,exg)
end
-- 检测是否存在第2只怪兽，使得墓地中存在能与前两只怪兽一起作为素材超量召唤「霍普」怪兽的组合
function c62829077.mfilter2(c,mc,mg,exg)
	return mg:IsExists(c62829077.mfilter3,1,c,c,mc,exg)
end
-- 检测是否存在第3只怪兽，使得这3只怪兽可以作为素材超量召唤额外卡组的「霍普」怪兽
function c62829077.mfilter3(c,mc1,mc2,exg)
	return c~=mc2 and exg:IsExists(Card.IsXyzSummonable,1,nil,Group.FromCards(c,mc1,mc2),3,3)
end
-- 定义效果发动的对象选择与合法性检测，确保能特殊召唤3只怪兽并进行超量召唤
function c62829077.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中所有可以特殊召唤的怪兽
	local mg=Duel.GetMatchingGroup(c62829077.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取额外卡组中可以用墓地怪兽作为素材超量召唤的「霍普」超量怪兽
	local exg=Duel.GetMatchingGroup(c62829077.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	-- 在发动时，检查玩家是否能进行至少2次特殊召唤（特召素材和超量怪兽）
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域空位是否大于2个（需要特召3只怪兽）
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and mg:IsExists(c62829077.mfilter1,1,nil,mg,exg) end
	-- 提示玩家选择第1只用于特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=mg:FilterSelect(tp,c62829077.mfilter1,1,1,nil,mg,exg)
	local tc1=sg1:GetFirst()
	-- 提示玩家选择第2只用于特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg2=mg:FilterSelect(tp,c62829077.mfilter2,1,1,tc1,tc1,mg,exg)
	local tc2=sg2:GetFirst()
	-- 提示玩家选择第3只用于特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg3=mg:FilterSelect(tp,c62829077.mfilter3,1,1,tc2,tc2,tc1,exg)
	sg1:Merge(sg2)
	sg1:Merge(sg3)
	-- 将选中的3只怪兽作为效果的对象
	Duel.SetTargetCard(sg1)
	-- 设置连锁的操作信息，表明此效果将特殊召唤这3只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg1,3,0,0)
end
-- 过滤在效果处理时仍与该效果相关且可以特殊召唤的对象怪兽
function c62829077.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果处理，将3只对象怪兽效果无效特殊召唤，并用它们作为素材超量召唤1只「霍普」超量怪兽
function c62829077.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 如果自己场上的怪兽区域空位不足3个，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	-- 获取当前连锁的对象中，在效果处理时仍合法的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c62829077.filter2,nil,e,tp)
	if g:GetCount()<3 then return end
	local tc=g:GetFirst()
	while tc do
		-- 将对象怪兽以表侧表示特殊召唤（分步处理）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 那3只怪兽效果无效特殊召唤
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 完成所有分步特殊召唤的处理
	Duel.SpecialSummonComplete()
	-- 刷新场上卡片信息，确保特殊召唤的怪兽状态正确
	Duel.AdjustAll()
	if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<3 then return end
	-- 获取额外卡组中可以用这3只怪兽作为素材超量召唤的「霍普」超量怪兽
	local xyzg=Duel.GetMatchingGroup(c62829077.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	if xyzg:GetCount()>0 then
		-- 提示玩家选择要进行超量召唤的「霍普」超量怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		xyz:RegisterFlagEffect(62829077,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 使用这3只怪兽作为素材，对选定的「霍普」超量怪兽进行超量召唤
		Duel.XyzSummon(tp,xyz,g)
	end
end
