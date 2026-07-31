--真海竜騎－ダイダロス
local s,id,o=GetID()
-- 初始化效果注册
function s.initial_effect(c)
	-- 关联卡密码声明：潜海奇袭、海
	aux.AddCodeList(c,38391684,22702055)
	-- 规则上当作「海」使用
	aux.EnableChangeCode(c,22702055)
	c:EnableReviveLimit()
	-- 水属性怪兽2只以上（或「海」存在时为2只）
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.LinkCondition(s.mfilter,2,3,s.glcheck))
	e0:SetTarget(s.LinkTarget(s.mfilter,2,3,s.glcheck))
	e0:SetOperation(s.LinkOperation(s.mfilter,2,3,s.glcheck))
	e0:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e0)
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1只有「海」的卡名记载的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：双方的主要阶段，以自己场上1张表侧表示的「海」为对象才能发动（对方不能对应这个效果的发动把效果发动）。那张卡送去墓地，对方手卡全部送去墓地。那之后，对方从卡组抽那个数量的卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_OPPO)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.drcon)
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤：水属性怪兽
function s.mfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_WATER)
end
-- 连接素材数量检查：场上有潜海奇袭或素材为3只
function s.glcheck(g,c,tp)
	-- 检查是否适用潜海奇袭的效果（只需2只素材）或素材达到3只
	return Duel.IsPlayerAffectedByEffect(tp,38391684) or g:GetCount()==3
end
-- 常规连接素材过滤条件
function s.LConditionFilter(c,f,lc,e)
	return (c:IsFaceup() or not c:IsOnField() or e:IsHasProperty(EFFECT_FLAG_SET_AVAILABLE))
		and c:IsCanBeLinkMaterial(lc) and (not f or f(c))
end
-- 额外连接素材过滤条件
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
-- 获取怪兽作连接素材时的连接数
function s.GetLinkCount(c)
	if c:IsLinkType(TYPE_LINK) and c:GetLink()>1 then
		return 1+0x10000*c:GetLink()
	else return 1 end
end
-- 获取可作为连接素材的卡片组
function s.GetLinkMaterials(tp,f,lc,e)
	-- 获取场上合法的连接素材
	local mg=Duel.GetMatchingGroup(s.LConditionFilter,tp,LOCATION_MZONE,0,nil,f,lc,e)
	-- 获取手牌或魔陷区等可作为额外连接素材的卡
	local mg2=Duel.GetMatchingGroup(s.LExtraFilter,tp,LOCATION_HAND+LOCATION_SZONE,LOCATION_ONFIELD,nil,f,lc,tp)
	if mg2:GetCount()>0 then mg:Merge(mg2) end
	return mg
end
-- 检查其他额外连接素材的相容性
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
-- 检查素材组合中是否存在不兼容的额外连接素材
function s.LUncompatibilityFilter(c,sg,lc,tp)
	-- 获取当前素材组中除当前卡以外的其他卡
	local mg=sg:Filter(aux.TRUE,c)
	return not s.LCheckOtherMaterial(c,mg,lc,tp)
end
-- 检查连接素材组合是否满足召唤要求
function s.LCheckGoal(sg,tp,lc,gf,lmat)
	-- 检查素材连接数合计是否符合召唤要求
	return (Duel.IsPlayerAffectedByEffect(tp,38391684)
		and sg:CheckWithSumEqual(s.GetLinkCount,2,#sg,#sg)
		or sg:CheckWithSumEqual(s.GetLinkCount,lc:GetLink(),#sg,#sg))
		-- 检查额外卡组怪兽区域空位及额外连接要求
		and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0 and (not gf or gf(sg,lc,tp))
		and not sg:IsExists(s.LUncompatibilityFilter,1,nil,sg,lc,tp)
		and (not lmat or sg:IsContains(lmat))
end
-- 扣除额外连接素材的使用次数
function s.LExtraMaterialCount(mg,lc,tp)
	-- 遍历连接素材组中的每一张卡
	for tc in aux.Next(mg) do
		local le={tc:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
		for _,te in pairs(le) do
			-- 获取素材组中除当前卡外的其余卡
			local sg=mg:Filter(aux.TRUE,tc)
			local f=te:GetValue()
			local related,valid=f(te,lc,sg,tc,tp)
			if related and valid then
				te:UseCountLimit(tp)
			end
		end
	end
end
-- 连接召唤条件判断
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
				-- 获取必须作为连接素材的卡
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				-- 检查素材组中是否包含所有必须使用的连接素材
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				-- 设定必须使用的连接素材
				Duel.SetSelectedCard(fg)
				return mg:CheckSubGroup(s.LCheckGoal,minc,maxc,tp,c,gf,lmat)
			end
end
-- 连接召唤素材选择
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
				-- 获取必须作为连接素材的卡
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				-- 设定必须使用的连接素材
				Duel.SetSelectedCard(fg)
				-- 提示玩家选择要作为连接素材的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)  --"请选择要作为连接素材的卡"
				-- 检查连接召唤是否可取消
				local cancel=Duel.IsSummonCancelable()
				local sg=mg:SelectSubGroup(tp,s.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
				if sg then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
-- 执行连接召唤操作
function s.LinkOperation(f,minct,maxct,gf)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				s.LExtraMaterialCount(g,c,tp)
				-- 将连接素材送去墓地
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
			end
end
-- 发动条件：这张卡连接召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 特召对象过滤：卡名有「海」记载的怪兽
function s.spfilter(c,e,tp)
	-- 过滤记载有「海」且可以特殊召唤的怪兽
	return aux.IsCodeListed(c,38391684) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特召效果的发动准备与目标选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且卡组存在记载有「海」的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特召效果处理：从卡组把1只有「海」记载的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认怪兽区域有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择卡组1只有「海」记载的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 代价卡片过滤：场上表侧表示的「海」
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(22702055) and c:IsAbleToGraveAsCost()
end
-- 发动条件：双方主要阶段
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前为主要阶段
	return Duel.IsMainPhase()
end
-- 效果发动代价：将场上1张表侧表示的「海」送去墓地
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己场上是否存在表侧表示的「海」
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1张表侧表示的「海」
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 手牌送墓及抽卡效果的发动准备
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取对方手牌数量
		local h=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
		-- 发动条件检查：对方有手牌且对方可以抽卡
		return h>0 and Duel.IsPlayerCanDraw(1-tp,h)
	end
	-- 设置连锁操作信息：对方手牌送去墓地
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
	-- 设置连锁操作信息：对方抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	-- 封闭连锁：对方不能对应这个效果的发动把效果发动
	Duel.SetChainLimit(aux.FALSE)
end
-- 效果处理：对方手牌全部送去墓地，那之后对方抽等量数量的卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌张数
	local h=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 获取对方手牌卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 将对方手牌全部丢弃送去墓地
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)>0 then
		-- 中断效果处理（非同时处理）
		Duel.BreakEffect()
		-- 让对方从卡组抽送去墓地数量的卡
		Duel.Draw(1-tp,h,REASON_EFFECT)
	end
end
