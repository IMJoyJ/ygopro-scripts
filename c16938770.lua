--エクシーズ・ポセイドン・スプラッシュ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：有超量怪兽在作为超量素材中的超量怪兽在自己场上存在的场合，宣言场上的怪兽1个属性才能发动。除有装备魔法卡装备的怪兽外的场上的宣言属性的怪兽全部破坏。
-- ②：把墓地的这张卡除外，把自己场上1个超量素材取除才能发动。从自己墓地把1只鱼族·海龙族·水族怪兽在自己或对方的场上特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①作为魔法/陷阱卡发动的破坏效果，注册②作为墓地快速效果的特殊召唤，二者通过相同的SetCountLimit(1,id)共用1回合1次。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：有超量怪兽在作为超量素材中的超量怪兽在自己场上存在的场合，宣言场上的怪兽1个属性才能发动。除有装备魔法卡装备的怪兽外的场上的宣言属性的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏怪兽"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外，把自己场上1个超量素材取除才能发动。从自己墓地把1只鱼族·海龙族·水族怪兽在自己或对方的场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片是否为超量怪兽，用于筛选存在于超量素材中的超量怪兽。
function s.mfilter(c)
	return c:IsType(TYPE_XYZ)
end
-- 过滤函数：判断场上是否存在表侧表示的超量怪兽，并且该超量怪兽的叠放素材中存在至少1只超量怪兽，用于满足①的发动条件。
function s.ffilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(s.mfilter,1,nil)
end
-- ①效果的发动条件：检查自己场上是否存在至少1张满足s.ffilter的超量怪兽（即表侧表示且其超量素材中有超量怪兽）。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回检查结果：是否存在至少1张满足s.ffilter的超量怪兽在自己场上，以此作为①效果能否发动的条件。
	return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 破坏对象过滤器：筛选表侧表示、属性与宣言属性一致且没有装备魔法卡装备的怪兽。
function s.desfilter(c,attr)
	return c:IsFaceup() and c:IsAttribute(attr) and c:GetEquipGroup():Filter(Card.IsType,nil,TYPE_SPELL):GetCount()==0
end
-- 可宣言属性来源过滤器：筛选表侧表示且没有装备魔法卡装备的怪兽，用于计算可以宣言的属性范围。
function s.dmfilter(c)
	return c:IsFaceup() and c:GetEquipGroup():Filter(Card.IsType,nil,TYPE_SPELL):GetCount()==0
end
-- ①效果的发动时处理：先确认场上存在无装备魔法卡的怪兽，然后收集这些怪兽的属性并集，让玩家宣言1个属性，再根据该属性筛选出将被破坏的怪兽，并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：场上是否存在至少1只表侧表示且没有装备魔法卡装备的怪兽，以保证存在可宣言的属性。
	if chk==0 then return Duel.IsExistingMatchingCard(s.dmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有表侧表示且没有装备魔法卡装备的怪兽，用于后续收集可宣言的属性。
	local g=Duel.GetMatchingGroup(s.dmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local attr=0
	-- 遍历这些怪兽，通过按位或运算汇总所有可能的属性，供玩家宣言。
	for tc in aux.Next(g) do
		attr=attr|tc:GetAttribute()
	end
	-- 向玩家发送提示消息，使其选择要宣言的属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从可用属性组合中宣言1个属性，返回值为所宣言的属性。
	local at=Duel.AnnounceAttribute(tp,1,attr)
	e:SetLabel(at)
	-- 根据宣言的属性，筛选出场上对应的、无装备魔法卡且表侧表示的怪兽，作为效果处理时将被破坏的候选集合。
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,at)
	-- 将本次破坏操作的信息写入连锁，记录破坏对象集合及数量，供其他卡片与效果进行响应检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- ①效果处理时的操作：取出宣言属性，重新筛选当前符合条件的怪兽，若存在则将其全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local attr=e:GetLabel()
	-- 在效果处理时根据已宣言的属性重新获取场上应被破坏的怪兽集合（处理时可能有卡离场或状态变化）。
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,attr)
	if dg:GetCount()>0 then
		-- 以效果原因破坏该怪兽集合，完成①的破坏效果。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
-- ②效果的代价函数：把墓地的这张卡除外，并把自己场上1个超量素材取除作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认墓地的这张卡可以除外，并且自己场上存在至少1个可以移除的超量素材。
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 执行代价之一：将墓地的这张卡除外。
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 执行代价之二：移除自己场上的1个超量素材。
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 特殊召唤对象过滤器：筛选墓地中鱼族、海龙族或水族怪兽，并且该怪兽当前至少能够特殊召唤到自己或对方场上。
function s.filter(c,e,tp)
	-- 判断该怪兽能否由当前玩家表侧表示特殊召唤到自己场上，并且自己场上有可用怪兽区。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
	-- 判断该怪兽能否由当前玩家表侧表示特殊召唤到对方场上，并且对方场上有可用怪兽区。
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	return c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT) and (b1 or b2)
end
-- ②效果的发动时处理：检查墓地是否存在符合条件的怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：墓地中是否存在至少1只满足s.filter的鱼族·海龙族·水族怪兽，且能特殊召唤到任意一方场上。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 写入特殊召唤操作信息，表示效果处理时会从自己墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理时的操作：选择1只满足条件的墓地怪兽，若双方场上均可特殊召唤则由玩家选择特殊召唤到哪一方，然后进行特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若双方场上都没有可用的怪兽区域，则效果不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示消息，使其选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地中筛选满足条件且不受王家长眠之谷等墓地无效影响的鱼族·海龙族·水族怪兽，让玩家选择1张。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 显示被选择怪兽的选中动画，并将其记录为当前效果的对象。
		Duel.HintSelection(g)
		-- 判断对方场上是否有可用怪兽区，且该怪兽能否被特殊召唤到对方场上。
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
			-- 判断自己场上是否有可用怪兽区且该怪兽能否被特殊召唤到自己场上；用于决定是否必须选择对方场上。
			and (not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false))
				-- 若自己场上不能特殊召唤则直接选择对方场上；若自己场上也能特殊召唤则询问玩家“是否在对方场上特殊召唤？”并据此选择召唤位置。
				or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否在对方场上特殊召唤？"
			-- 将选中的怪兽以表侧表示特殊召唤到对方场上。
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
		else
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
