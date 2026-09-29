--光器還魂の儀
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·卡组·场上（表侧表示）的通常怪兽卡送去墓地（同名卡最多1张），从自己的手卡·墓地把1只「塞尼特」仪式怪兽仪式召唤。那之后，可以让那只怪兽从自己墓地把1只通常怪兽当作装备魔法卡使用来装备。
-- ②：自己场上的通常怪兽卡被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
local s,id,o=GetID()
-- 注册卡片初始效果：①以卡组·手卡·场上通常怪兽为素材仪式召唤手卡·墓地「塞尼特」仪式怪兽并可选墓地通常怪兽装备；②墓地除外代替场上通常怪兽破坏
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·卡组·场上（表侧表示）的通常怪兽卡送去墓地（同名卡最多1张），从自己的手卡·墓地把1只「塞尼特」仪式怪兽仪式召唤。那之后，可以让那只怪兽从自己墓地把1只通常怪兽当作装备魔法卡使用来装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"仪式召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的通常怪兽卡被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
-- 获取卡片用于仪式召唤的等级
function s.getrlv(c,rc)
	if c:IsType(TYPE_MONSTER) then
		return c:GetRitualLevel(rc)
	else
		return c:GetOriginalLevel()
	end
end
-- 仪式素材的辅助检查函数：卡名必须不同且避免溢出多选素材
function s.gcheckf(tc,lv)
	return function(sg,ec)
		-- 检查所选素材卡片是否卡名互不相同
		if not aux.dncheck(sg) then return false end
		if ec then
			return sg:GetSum(s.getrlv,tc)-s.getrlv(ec,tc)<=lv
		else
			return true
		end
	end
end
-- 检查素材送墓后怪兽区是否有空位且等级合计达到仪式怪兽等级以上
function s.RitualCheckGreater(g,c,lv,tp)
	-- 检查将选中的素材送去墓地后是否有可用的主要怪兽区空格
	if Duel.GetMZoneCount(tp,g)<=0 then return false end
	-- 设置当前已选中的卡片组供求和函数检查
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(s.getrlv,lv,c)
end
-- 过滤手卡·墓地可仪式召唤的「塞尼特」仪式怪兽
function s.spfilter(c,e,tp,m)
	if bit.band(c:GetType(),0x81)~=0x81 or not c:IsSetCard(0x1eb)
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	if c.mat_filter then
		m=m:Filter(c.mat_filter,nil,tp)
	end
	local lv=c:GetLevel()
	-- 设置子组选择的额外检查函数（同名卡最多1张且等级不超额选卡）
	aux.GCheckAdditional=s.gcheckf(c,lv)
	local res=m:CheckSubGroup(s.RitualCheckGreater,1,lv,c,lv,tp)
	-- 重置子组选择的额外检查函数
	aux.GCheckAdditional=nil
	return res
end
-- 过滤可用作仪式素材的表侧表示通常怪兽卡（可送去墓地）
function s.matfilter(c)
	return c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
		and c:IsFaceupEx() and c:IsAbleToGrave()
end
-- 魔法卡发动的目标：检查是否存在合法的仪式怪兽与素材并设置特殊召唤操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组、手卡及场上所有可作为素材的通常怪兽卡
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,nil)
		-- 检查手卡·墓地是否存在可以仪式召唤的「塞尼特」仪式怪兽
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,mg)
	end
	-- 设置从手卡·墓地特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤墓地中可作为装备卡装备的通常怪兽
function s.eqfilter(c,tp)
	return c:IsType(TYPE_NORMAL) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 魔法卡发动的处理：把通常怪兽送去墓地仪式召唤「塞尼特」仪式怪兽，之后可选墓地通常怪兽给其装备
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取卡组、手卡及场上所有可作为素材的通常怪兽卡
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	-- 提示选择要特殊召唤的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只「塞尼特」仪式怪兽
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,mg)
	if tg:GetCount()>0 then
		local tc=tg:GetFirst()
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,nil,tp)
		end
		local lv=tc:GetLevel()
		-- 提示选择要送去墓地的仪式素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 设置素材选择的附加检查函数（同名卡最多1张）
		aux.GCheckAdditional=s.gcheckf(tc,lv)
		local mat=mg:SelectSubGroup(tp,s.RitualCheckGreater,true,1,lv,tc,lv,tp)
		-- 重置素材选择的附加检查函数
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 将选中的素材送去墓地
		Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断当前效果，使之后的处理不同时进行
		Duel.BreakEffect()
		-- 将仪式怪兽以表侧表示仪式召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
		-- 检查魔法与陷阱区是否有空位
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 检查墓地是否存在可以装备的通常怪兽
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,nil,tp)
			-- 询问玩家是否将墓地的通常怪兽装备
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否装备？"
			-- 提示选择要作为装备卡的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 从墓地选择1只通常怪兽
			local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
			if ec then
				-- 中断当前效果，使装备处理不同时进行
				Duel.BreakEffect()
				-- 将选中的怪兽作为装备卡装备给仪式召唤的怪兽
				if not Duel.Equip(tp,ec,tc) then return end
				-- 那之后，可以让那只怪兽从自己墓地把1只通常怪兽当作装备魔法卡使用来装备。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetLabelObject(tc)
				e1:SetValue(s.eqlimit)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				ec:RegisterEffect(e1)
			end
		end
	end
end
-- 限制该装备卡只能装备给该仪式怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤场上表侧表示被战斗或效果破坏的自身通常怪兽卡
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
		and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- ②效果的目标：自身可除外且存在被破坏的通常怪兽时，询问玩家是否代替破坏
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	-- 询问玩家是否除外墓地的这张卡作破坏代替
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确认被破坏的怪兽符合代替破坏条件
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- ②效果的处理：将墓地的这张卡除外代替破坏
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡以表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
