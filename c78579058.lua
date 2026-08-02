--真海竜騎－ダイダロス
local s,id,o=GetID()
-- 初始化效果：注册代码列表、更改卡名效果、连接召唤条件及各效果
function s.initial_effect(c)
	-- 记录这张卡上记载着卡名卡号为38391684和22702055的卡
	aux.AddCodeList(c,38391684,22702055)
	-- 在场上或墓地时卡名当作22702055（海）使用
	aux.EnableChangeCode(c,22702055)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续和条件
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
	-- 效果①：连接召唤成功时发动的诱发效果
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
	-- 效果②：双方主要阶段可以发动的诱发即时效果
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
-- 连接素材过滤条件：水属性连接怪兽
function s.mfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_WATER)
end
-- 连接素材数量检查：玩家受到38391684效果影响或者素材数量为3只
function s.glcheck(g,c,tp)
	-- 检查玩家是否受到特定卡效果影响或连接素材数量是否为3只
	return Duel.IsPlayerAffectedByEffect(tp,38391684) or g:GetCount()==3
end
-- 连接素材基础条件检查：必须是表侧表示或在手卡等，并且可以作为连接素材
function s.LConditionFilter(c,f,lc,e)
	return (c:IsFaceup() or not c:IsOnField() or e:IsHasProperty(EFFECT_FLAG_SET_AVAILABLE))
		and c:IsCanBeLinkMaterial(lc) and (not f or f(c))
end
-- 检查手卡或魔陷区作为额外连接素材的合法性
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
-- 获取卡片作为连接素材时的连接值（Link数或1）
function s.GetLinkCount(c)
	if c:IsLinkType(TYPE_LINK) and c:GetLink()>1 then
		return 1+0x10000*c:GetLink()
	else return 1 end
end
-- 获取可以作为连接素材的卡片组，包括场上怪兽和通过额外效果允许的魔陷或手卡
function s.GetLinkMaterials(tp,f,lc,e)
	-- 获取我方主要怪兽区满足条件的可以作为连接素材的怪兽
	local mg=Duel.GetMatchingGroup(s.LConditionFilter,tp,LOCATION_MZONE,0,nil,f,lc,e)
	-- 获取我方手卡或魔陷区满足额外连接素材条件的卡片
	local mg2=Duel.GetMatchingGroup(s.LExtraFilter,tp,LOCATION_HAND+LOCATION_SZONE,LOCATION_ONFIELD,nil,f,lc,tp)
	if mg2:GetCount()>0 then mg:Merge(mg2) end
	return mg
end
-- 检查额外连接素材效果是否存在冲突或不兼容
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
-- 过滤不能同时作为连接素材的卡片
function s.LUncompatibilityFilter(c,sg,lc,tp)
	-- 获取当前候选连接素材组中除去目标卡之外的其他卡
	local mg=sg:Filter(aux.TRUE,c)
	return not s.LCheckOtherMaterial(c,mg,lc,tp)
end
-- 检查选定的素材组是否满足连接召唤的所有条件
function s.LCheckGoal(sg,tp,lc,gf,lmat)
	-- 判断玩家是否受到特定效果影响以决定所需的连接值总和
	return (Duel.IsPlayerAffectedByEffect(tp,38391684)
		and sg:CheckWithSumEqual(s.GetLinkCount,2,#sg,#sg)
		or sg:CheckWithSumEqual(s.GetLinkCount,lc:GetLink(),#sg,#sg))
		-- 检查召唤该连接怪兽后是否有可用的额外怪兽区空格并满足其他自定义条件
		and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0 and (not gf or gf(sg,lc,tp))
		and not sg:IsExists(s.LUncompatibilityFilter,1,nil,sg,lc,tp)
		and (not lmat or sg:IsContains(lmat))
end
-- 处理作为额外连接素材卡片的次数限制（如1回合1次等）
function s.LExtraMaterialCount(mg,lc,tp)
	-- 遍历作为连接素材的卡片组
	for tc in aux.Next(mg) do
		local le={tc:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
		for _,te in pairs(le) do
			-- 获取除去当前检查的卡之外的其他连接素材
			local sg=mg:Filter(aux.TRUE,tc)
			local f=te:GetValue()
			local related,valid=f(te,lc,sg,tc,tp)
			if related and valid then
				te:UseCountLimit(tp)
			end
		end
	end
end
-- 返回用于检查是否满足连接召唤条件的函数
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
				-- 获取必须作为连接素材的卡片组
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				-- 如果存在不能被作为当前连接素材的必须素材卡，则条件不满足
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				-- 设置已选择的卡片，供后续条件检查使用
				Duel.SetSelectedCard(fg)
				return mg:CheckSubGroup(s.LCheckGoal,minc,maxc,tp,c,gf,lmat)
			end
end
-- 返回用于在连接召唤时选择连接素材的函数
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
				-- 获取必须作为连接素材的卡片组
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				-- 设置当前已经选定的卡片组，准备进行合法性检查
				Duel.SetSelectedCard(fg)
				-- 向玩家发送选择连接素材的提示
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)  --"请选择要作为连接素材的卡"
				-- 判断当前连接召唤行为是否可以被取消
				local cancel=Duel.IsSummonCancelable()
				local sg=mg:SelectSubGroup(tp,s.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
				if sg then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
-- 返回用于在连接召唤时处理连接素材送墓等操作的函数
function s.LinkOperation(f,minct,maxct,gf)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				s.LExtraMaterialCount(g,c,tp)
				-- 将选定的连接素材卡送去墓地
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
			end
end
-- 效果①的发动条件：此卡必须是连接召唤出场的
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的特殊召唤过滤函数：记载有38391684卡名且能被特殊召唤的卡
function s.spfilter(c,e,tp)
	-- 检查卡片文本是否记载了指定卡名并且能够被特殊召唤
	return aux.IsCodeListed(c,38391684) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的目标：检查是否有空位和可特殊召唤的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：包含从卡组特殊召唤怪兽的效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：从卡组选1只怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果我方主要怪兽区没有空位，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择要特殊召唤的怪兽的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选定的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的代价过滤函数：表侧表示、卡名为22702055（海）、能送去墓地
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(22702055) and c:IsAbleToGraveAsCost()
end
-- 效果②的发动条件：必须在主要阶段
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否在主要阶段
	return Duel.IsMainPhase()
end
-- 效果②的代价：将场上1张符合条件的卡送去墓地
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可以作为代价送墓的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家发送选择要送去墓地的卡的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从场上选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的目标：检查对方手卡数量以及我方是否能让对方抽卡
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取对方手卡的数量
		local h=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
		-- 检查对方是否有手卡且能进行抽卡操作
		return h>0 and Duel.IsPlayerCanDraw(1-tp,h)
	end
	-- 设置操作信息：包含对方手卡送去墓地的效果
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
	-- 设置操作信息：包含对方抽卡的效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	-- 设置此效果的发动不能被连锁
	Duel.SetChainLimit(aux.FALSE)
end
-- 效果②的处理：将对方手卡全部送去墓地，然后对方抽相同数量的卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 记录当前对方手卡的数量
	local h=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 获取对方手卡的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 如果成功将对方手卡送去墓地，则继续下一步处理
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)>0 then
		-- 中断当前效果，使前后效果处理视为不同时点
		Duel.BreakEffect()
		-- 让对方抽出之前送去墓地的手卡数量的卡
		Duel.Draw(1-tp,h,REASON_EFFECT)
	end
end
