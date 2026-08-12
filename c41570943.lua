--蒼海竜神－ネオダイダロス・レイジ
-- 效果：
-- 怪兽4只
-- ①：这张卡连接召唤的场合才能发动。从自己墓地把有「龙都 亚特兰蒂斯」的卡名记述的最多3只怪兽在作为这张卡所连接区的自己场上特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
-- ②：这张卡只要在怪兽区域存在，卡名当作「海」使用。
-- ③：自己·对方回合1次，把自己场上1张表侧表示的「海」送去墓地才能发动。除「海」外的场上的卡全部送去墓地。
local s,id,o=GetID()
-- 初始化函数：注册卡名记载信息、卡名变更效果与苏生限制，并依次注册连接召唤手续效果、连接召唤成功时的特殊召唤诱发效果、以及把场上的卡送去墓地的诱发即时效果
function s.initial_effect(c)
	-- 记录这张卡的效果文本上记载着「龙都 亚特兰蒂斯」(38391684）和「海」(22702055）的卡名
	aux.AddCodeList(c,38391684,22702055)
	-- 为这张卡注册永续效果：在怪兽区域存在期间卡名当作「海」(22702055）使用
	aux.EnableChangeCode(c,22702055)
	c:EnableReviveLimit()
	-- 连接召唤手续效果（效果外文本）：这张卡也可以用3只怪兽作为连接素材进行连接召唤（适用「龙都 亚特兰蒂斯」的卡名记载规则）
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))  --"适用作为连接3进行连接召唤（龙都 亚特兰蒂斯）"
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.LinkCondition(nil,3,4,s.glcheck))
	e0:SetTarget(s.LinkTarget(nil,3,4,s.glcheck))
	e0:SetOperation(s.LinkOperation(nil,3,4,s.glcheck))
	e0:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e0)
	-- ①：这张卡连接召唤的场合才能发动。从自己墓地把有「龙都 亚特兰蒂斯」的卡名记述的最多3只怪兽在作为这张卡所连接区的自己场上特殊召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ③：自己·对方回合1次，把自己场上1张表侧表示的「海」送去墓地才能发动。除「海」外的场上的卡全部送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"送去墓地"
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
-- 连接召唤手续的额外条件函数：判断是否适用「龙都 亚特兰蒂斯」的连接3规则，或使用4只怪兽进行连接召唤
function s.glcheck(g,c,tp)
	-- 若玩家受到「龙都 亚特兰蒂斯」(38391684）的效果影响则可以用3只怪兽连接召唤，否则必须使用4只怪兽作为素材
	return Duel.IsPlayerAffectedByEffect(tp,38391684) or g:GetCount()==4
end
-- 连接素材的通常过滤函数：卡须为表侧表示（或不在场上、或适用里侧也能作素材的效果），且可以作为这张卡的连接素材，并满足额外过滤条件
function s.LConditionFilter(c,f,lc,e)
	return (c:IsFaceup() or not c:IsOnField() or e:IsHasProperty(EFFECT_FLAG_SET_AVAILABLE))
		and c:IsCanBeLinkMaterial(lc) and (not f or f(c))
end
-- 额外连接素材的过滤函数：排除场上的里侧表示卡与不能作连接素材的卡，仅当卡持有「额外连接素材」(EFFECT_EXTRA_LINK_MATERIAL）效果且判定相关时返回真
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
-- 计算连接素材数量的函数：连接2以上的连接怪兽可同时当作1只或与其连接标记数相等数量的素材使用（以0x10000编码标记）
function s.GetLinkCount(c)
	if c:IsLinkType(TYPE_LINK) and c:GetLink()>1 then
		return 1+0x10000*c:GetLink()
	else return 1 end
end
-- 收集这张卡连接召唤可用的全部素材：包括自己怪兽区域的通常素材，以及手卡·魔陷区和对方场上因额外素材效果可用的卡
function s.GetLinkMaterials(tp,f,lc,e)
	-- 检索自己怪兽区域满足条件的通常连接素材卡
	local mg=Duel.GetMatchingGroup(s.LConditionFilter,tp,LOCATION_MZONE,0,nil,f,lc,e)
	-- 检索自己手卡·魔陷区以及对方场上因「额外连接素材」效果而可以作为连接素材的卡
	local mg2=Duel.GetMatchingGroup(s.LExtraFilter,tp,LOCATION_HAND+LOCATION_SZONE,LOCATION_ONFIELD,nil,f,lc,tp)
	if mg2:GetCount()>0 then mg:Merge(mg2) end
	return mg
end
-- 检查当素材组中除这张卡外还有其他卡时，这张卡的「额外连接素材」效果是否关联且有效，以判断素材组合的兼容性
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
-- 构造排除自身的素材组后，检查这张卡的额外素材效果是否与之兼容，不兼容的卡将被过滤掉
function s.LUncompatibilityFilter(c,sg,lc,tp)
	-- 从素材组sg中取出除卡c以外的所有卡，作为判定c的额外素材效果时的其余素材
	local mg=sg:Filter(aux.TRUE,c)
	return not s.LCheckOtherMaterial(c,mg,lc,tp)
end
-- 连接素材组的达成判定：满足「龙都 亚特兰蒂斯」时素材连接数合计为3（否则等于这张卡的连接标记数）、素材离场后有可用的额外卡组出场空格、满足额外条件、素材组合兼容且包含必须素材
function s.LCheckGoal(sg,tp,lc,gf,lmat)
	-- 若玩家受到「龙都 亚特兰蒂斯」(38391684）的效果影响，则素材连接数合计只需等于3即可
	return (Duel.IsPlayerAffectedByEffect(tp,38391684)
		and sg:CheckWithSumEqual(s.GetLinkCount,3,#sg,#sg)
		or sg:CheckWithSumEqual(s.GetLinkCount,lc:GetLink(),#sg,#sg))
		-- 并且要求这组素材离场后有能让额外卡组怪兽出场的空格，同时满足传入的额外条件函数gf
		and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0 and (not gf or gf(sg,lc,tp))
		and not sg:IsExists(s.LUncompatibilityFilter,1,nil,sg,lc,tp)
		and (not lmat or sg:IsContains(lmat))
end
-- 遍历素材组，对实际使用了「额外连接素材」效果且判定有效的卡，消耗该效果的1回合1次使用次数
function s.LExtraMaterialCount(mg,lc,tp)
	-- 用迭代器依次遍历素材组mg中的每一张卡
	for tc in aux.Next(mg) do
		local le={tc:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
		for _,te in pairs(le) do
			-- 从素材组mg中取出除当前卡tc以外的所有卡，作为判定tc的额外素材效果时的其余素材
			local sg=mg:Filter(aux.TRUE,tc)
			local f=te:GetValue()
			local related,valid=f(te,lc,sg,tc,tp)
			if related and valid then
				te:UseCountLimit(tp)
			end
		end
	end
end
-- 连接召唤条件判定：排除表侧灵摆怪兽，确定素材数量上下限，收集可用素材与必须素材，并检查是否存在满足连接召唤条件的素材组合
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
				-- 取得因其他卡的效果而必须作为连接素材的卡组
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				-- 若必须作为连接素材的卡不在可用素材组中，则无法进行连接召唤，返回假
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				-- 将必须作为连接素材的卡设置为已选择，使后续的组合检查强制包含这些卡
				Duel.SetSelectedCard(fg)
				return mg:CheckSubGroup(s.LCheckGoal,minc,maxc,tp,c,gf,lmat)
			end
end
-- 连接召唤目标处理：确定素材数量范围，收集素材，提示玩家选择满足条件的连接素材组合，选择成功则保存该素材组
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
				-- 取得因其他卡的效果而必须作为连接素材的卡组
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				-- 将必须作为连接素材的卡设置为已选择，使后续的组合选择强制包含这些卡
				Duel.SetSelectedCard(fg)
				-- 向玩家发送选择提示：请选择要作为连接素材的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)  --"请选择要作为连接素材的卡"
				-- 检查当前的连接召唤行为是否可以取消（允许玩家在选择素材时撤销召唤）
				local cancel=Duel.IsSummonCancelable()
				local sg=mg:SelectSubGroup(tp,s.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
				if sg then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
-- 连接召唤实际操作：取出已选的素材组设定为这张卡的素材，消耗额外素材效果的使用次数，然后把素材作为连接素材送去墓地
function s.LinkOperation(f,minct,maxct,gf)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				s.LExtraMaterialCount(g,c,tp)
				-- 把作为连接素材的卡组以「素材·连接」的原因送去墓地
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
			end
end
-- ①效果的发动条件：这张卡是连接召唤成功的场合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 特殊召唤对象的过滤函数：卡的效果文本记载着「龙都 亚特兰蒂斯」的卡名，且可以特殊召唤到这张卡所连接区的自己场上
function s.spfilter1(c,e,tp,zone)
	-- 返回真当且仅当这张卡记载着「龙都 亚特兰蒂斯」(38391684）的卡名，并且能以表侧表示特殊召唤到指定连接区域
	return aux.IsCodeListed(c,38391684) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- ①效果的目标设定：取这张卡所连接区中自己主要怪兽区域的可用区域，检查自己场上是否有空格且墓地存在可特殊召唤的对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	-- 发动条件检查：自己怪兽区域须有空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地须存在至少1只满足条件的、可特殊召唤到连接区域的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 设置操作信息：这个效果预计从自己墓地把1只怪兽特殊召唤（供星尘龙等效果的连锁检测）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果的实际操作：计算连接区域与可特殊召唤数量（受「青眼精灵龙」影响时最多1只，上限3只），从自己墓地选择并特殊召唤最多3只记载「龙都 亚特兰蒂斯」卡名的怪兽到连接区，然后注册直到回合结束自己不能特殊召唤怪兽的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	-- 计算这张卡所连接区中自己怪兽区域可用于出场怪兽的空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if c:IsRelateToChain() and zone~=0 or ft>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		if ft>3 then ft=3 end
		-- 从自己墓地检索满足条件且不受「王家长眠之谷」影响的可特殊召唤怪兽
		local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_GRAVE,0,nil,e,tp,zone)
		-- 向玩家发送选择提示：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local g=tg:Select(tp,1,ft,nil)
		if g:GetCount()>0 then
			-- 把选择的怪兽以表侧表示特殊召唤到这张卡所连接区的自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。③：自己·对方回合1次，把自己场上1张表侧表示的「海」送去墓地才能发动。除「海」外的场上的卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 把「直到回合结束自己不能特殊召唤怪兽」的限制作为玩家效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- ③效果的代价过滤函数：自己场上表侧表示的、可以送去墓地作为代价的「海」(22702055)
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(22702055) and c:IsAbleToGraveAsCost()
end
-- ③效果的代价处理：检查自己场上存在表侧表示的「海」，让玩家选择其中1张并作为代价送去墓地
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己场上须存在1张表侧表示的、可以送去墓地作为代价的「海」
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家发送选择提示：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1张表侧表示的「海」
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 把选择的「海」作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 送去墓地对象的过滤函数：场上除「海」以外的卡（里侧表示的卡一律包含在内）
function s.cfilter(c)
	return c:IsFacedown() or not c:IsCode(22702055)
end
-- ③效果的目标设定：检索双方场上除「海」外的全部卡，存在这些卡才能发动，并设置操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索双方场上除「海」以外的全部卡
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息：这个效果预计把检索到的全部卡送去墓地（供其他效果的连锁检测）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- ③效果的实际操作：重新检索双方场上除「海」以外的全部卡，并把它们全部送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索双方场上除「海」以外的全部卡
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 把检索到的卡以效果原因全部送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
