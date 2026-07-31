--蒼海竜神－ネオダイダロス・レイジ
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果
function s.initial_effect(c)
	-- 为卡片添加卡号列表，包含38391684和22702055
	aux.AddCodeList(c,38391684,22702055)
	-- 启用卡片变更为22702055的效果
	aux.EnableChangeCode(c,22702055)
	c:EnableReviveLimit()
	-- 连接召唤效果，允许从额外卡组特殊召唤，条件为3~4个连接素材
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.LinkCondition(nil,3,4,s.glcheck))
	e0:SetTarget(s.LinkTarget(nil,3,4,s.glcheck))
	e0:SetOperation(s.LinkOperation(nil,3,4,s.glcheck))
	e0:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e0)
	-- 触发效果，当此卡连接召唤成功时发动，可以特殊召唤墓地的青眼精灵龙
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 速攻效果，可以在任意时刻发动，将场上非22702055的里侧表示卡送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(s.tgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 连接素材检查函数，若玩家受38391684影响或连接素材数量为4则返回真
function s.glcheck(g,c,tp)
	-- 判断玩家是否受38391684影响或当前连接素材组数量为4
	return Duel.IsPlayerAffectedByEffect(tp,38391684) or g:GetCount()==4
end
-- 过滤条件函数，用于筛选可以作为连接素材的怪兽
function s.LConditionFilter(c,f,lc,e)
	return (c:IsFaceup() or not c:IsOnField() or e:IsHasProperty(EFFECT_FLAG_SET_AVAILABLE))
		and c:IsCanBeLinkMaterial(lc) and (not f or f(c))
end
-- 额外连接素材过滤函数，检查卡是否具有额外连接素材效果且满足条件
function s.LExtraFilter(c,f,lc,tp)
	if c:IsOnField() and c:IsFacedown() then return false end
	if not c:IsCanBeLinkMaterial(lc) or f and not f(c) then return false end
	local le={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
	for _,te in pairs(le) do
		local tf=te:GetValue()
		local related,valid=tf(te,lc,nil,c,tp)
		if related then return true end
	end
	return false
end
-- 获取连接怪兽的链接值，用于计算连接素材总和
function s.GetLinkCount(c)
	if c:IsLinkType(TYPE_LINK) and c:GetLink()>1 then
		return 1+0x10000*c:GetLink()
	else return 1 end
end
-- 获取可用于连接召唤的素材组，包括场上、手牌和魔陷区的连接素材
function s.GetLinkMaterials(tp,f,lc,e)
	-- 从场上获取满足条件的连接素材
	local mg=Duel.GetMatchingGroup(s.LConditionFilter,tp,LOCATION_MZONE,0,nil,f,lc,e)
	-- 从手牌和魔陷区获取满足条件的额外连接素材
	local mg2=Duel.GetMatchingGroup(s.LExtraFilter,tp,LOCATION_HAND+LOCATION_SZONE,LOCATION_ONFIELD,nil,f,lc,tp)
	if mg2:GetCount()>0 then mg:Merge(mg2) end
	return mg
end
-- 检查单张卡是否与其他连接素材冲突
function s.LCheckOtherMaterial(c,mg,lc,tp)
	local le={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
	local res1=false
	local res2=true
	for _,te in pairs(le) do
		local f=te:GetValue()
		local related,valid=f(te,lc,mg,c,tp)
		if related then res2=false end
		if related and valid then res1=true end
	end
	return res1 or res2
end
-- 不兼容过滤函数，用于检测连接素材是否互相冲突
function s.LUncompatibilityFilter(c,sg,lc,tp)
	-- 创建一个只包含当前卡的过滤组
	local mg=sg:Filter(aux.TRUE,c)
	return not s.LCheckOtherMaterial(c,mg,lc,tp)
end
-- 检查连接召唤是否满足所有条件，包括链接值、位置数量和不兼容性等
function s.LCheckGoal(sg,tp,lc,gf,lmat)
	-- 判断玩家是否受38391684影响以决定使用哪种链接值计算方式
	return (Duel.IsPlayerAffectedByEffect(tp,38391684)
		and sg:CheckWithSumEqual(s.GetLinkCount,3,#sg,#sg)
		or sg:CheckWithSumEqual(s.GetLinkCount,lc:GetLink(),#sg,#sg))
		-- 检查连接召唤所需位置是否足够，并验证额外条件
		and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0 and (not gf or gf(sg,lc,tp))
		and not sg:IsExists(s.LUncompatibilityFilter,1,nil,sg,lc,tp)
		and (not lmat or sg:IsContains(lmat))
end
-- 处理额外连接素材的计数限制
function s.LExtraMaterialCount(mg,lc,tp)
	-- 遍历连接素材组中的每张卡
	for tc in aux.Next(mg) do
		local le={tc:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
		for _,te in pairs(le) do
			-- 创建一个只包含当前卡的过滤组
			local sg=mg:Filter(aux.TRUE,tc)
			local f=te:GetValue()
			local related,valid=f(te,lc,sg,tc,tp)
			if related and valid then
				te:UseCountLimit(tp)
			end
		end
	end
end
-- 创建连接召唤条件函数，用于判断是否满足连接召唤条件
function s.LinkCondition(f,minct,maxct,gf)
	return  function(e,c,og,lmat,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local minc=minct
				local maxc=maxct
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local tp=c:GetControler()
				local mg=nil
				if og then
					mg=og:Filter(s.LConditionFilter,nil,f,c,e)
				else
					mg=s.GetLinkMaterials(tp,f,c,e)
				end
				if lmat~=nil then
					if not s.LConditionFilter(lmat,f,c,e) then return false end
					mg:AddCard(lmat)
				end
				-- 获取必须使用的连接素材组
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				-- 检查必须使用的连接素材是否与当前连接素材冲突
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				-- 设置选中的连接素材组
				Duel.SetSelectedCard(fg)
				return mg:CheckSubGroup(s.LCheckGoal,minc,maxc,tp,c,gf,lmat)
			end
end
-- 创建连接召唤目标选择函数，用于选择连接素材
function s.LinkTarget(f,minct,maxct,gf)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,lmat,min,max)
				local minc=minct
				local maxc=maxct
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local mg=nil
				if og then
					mg=og:Filter(s.LConditionFilter,nil,f,c,e)
				else
					mg=s.GetLinkMaterials(tp,f,c,e)
				end
				if lmat~=nil then
					if not s.LConditionFilter(lmat,f,c,e) then return false end
					mg:AddCard(lmat)
				end
				-- 获取必须使用的连接素材组
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				-- 设置选中的连接素材组
				Duel.SetSelectedCard(fg)
				-- 提示玩家选择作为连接素材的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)  --"请选择要作为连接素材的卡"
				-- 判断当前特殊召唤是否可以撤销
				local cancel=Duel.IsSummonCancelable()
				local sg=mg:SelectSubGroup(tp,s.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
				if sg then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
-- 创建连接召唤操作函数，用于执行连接召唤操作
function s.LinkOperation(f,minct,maxct,gf)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				s.LExtraMaterialCount(g,c,tp)
				-- 将连接素材送去墓地，原因包括材料和链接
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
			end
end
-- 判断此卡是否为连接召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 特殊召唤过滤函数，筛选可特殊召唤的青眼精灵龙
function s.spfilter1(c,e,tp,zone)
	-- 判断卡是否为青眼精灵龙且可以特殊召唤
	return aux.IsCodeListed(c,38391684) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 设置特殊召唤目标，检查是否有满足条件的青眼精灵龙可召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的青眼精灵龙
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 设置操作信息，表示将要特殊召唤卡牌到场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行特殊召唤操作，选择并特殊召唤青眼精灵龙，并设置不能特殊召唤限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	-- 获取当前可召唤的位置数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if c:IsRelateToChain() and zone~=0 or ft>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		if ft>3 then ft=3 end
		-- 获取满足条件的青眼精灵龙组
		local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_GRAVE,0,nil,e,tp,zone)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local g=tg:Select(tp,1,ft,nil)
		if g:GetCount()>0 then
			-- 执行特殊召唤操作
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
		end
	end
	-- 设置效果，禁止在本回合内再次特殊召唤怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 费用过滤函数，筛选可以作为费用的22702055卡
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(22702055) and c:IsAbleToGraveAsCost()
end
-- 设置费用效果，选择一张22702055卡送去墓地作为费用
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的22702055卡可作为费用
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的22702055卡作为费用
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡送去墓地，原因包括费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标过滤函数，筛选非22702055或里侧表示的卡
function s.cfilter(c)
	return c:IsFacedown() or not c:IsCode(22702055)
end
-- 设置效果目标，检查场上是否存在非22702055或里侧表示的卡
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的卡组
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息，表示将要将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 执行效果，将场上满足条件的卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将选中的卡送去墓地，原因包括效果
	Duel.SendtoGrave(g,REASON_EFFECT)
end
