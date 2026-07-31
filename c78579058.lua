--真海竜騎－ダイダロス
local s,id,o=GetID()
-- 初始化卡片效果：注册连接召唤手续、①特召成功从卡组特召记有「海」的怪兽效果、②主要阶段送墓「海」手牌全部舍弃并抽牌效果
function s.initial_effect(c)
	-- 注册关联卡片密码：38391684（海皇）、22702055（海）
	aux.AddCodeList(c,38391684,22702055)
	-- 允许当作「海」（卡名当作22702055）使用
	aux.EnableChangeCode(c,22702055)
	c:EnableReviveLimit()
	-- 规则效果：此卡连接召唤的手续（水属性怪兽2~3只，有「海皇」关联卡在场或用3只素材时生效）
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
	-- ①：此卡连接召唤成功的场合才能发动。从卡组把1只记有「海」卡名的怪兽表侧表示特殊召唤。
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
	-- ②：双方主要阶段，把场上1张表侧表示的「海」送去墓地才能发动。对方手牌全部送去墓地，对方从卡组抽出送去墓地数量的卡。
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
-- 连接素材过滤条件：水属性怪兽
function s.mfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_WATER)
end
-- 连接召唤组检查条件：玩家受到38391684影响或素材数量为3只
function s.glcheck(g,c,tp)
	-- 判断玩家是否受指定卡片效果影响，或选取的素材数量是否为3只
	return Duel.IsPlayerAffectedByEffect(tp,38391684) or g:GetCount()==3
end
-- 检查单张卡是否符合作为连接素材的条件
function s.LConditionFilter(c,f,lc,e)
	return (c:IsFaceup() or not c:IsOnField() or e:IsHasProperty(EFFECT_FLAG_SET_AVAILABLE))
		and c:IsCanBeLinkMaterial(lc) and (not f or f(c))
end
-- 检查额外卡片（如手牌·魔陷区）是否能作为连接素材使用
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
-- 获取怪兽作为连接素材时计算的连接数
function s.GetLinkCount(c)
	if c:IsLinkType(TYPE_LINK) and c:GetLink()>1 then
		return 1+0x10000*c:GetLink()
	else return 1 end
end
-- 获取可用于连接召唤的所有素材怪兽卡片组
function s.GetLinkMaterials(tp,f,lc,e)
	-- 获取自己场上满足条件的连接素材怪兽
	local mg=Duel.GetMatchingGroup(s.LConditionFilter,tp,LOCATION_MZONE,0,nil,f,lc,e)
	-- 获取手牌或魔陷区可通过额外连接素材效果使用的素材
	local mg2=Duel.GetMatchingGroup(s.LExtraFilter,tp,LOCATION_HAND+LOCATION_SZONE,LOCATION_ONFIELD,nil,f,lc,tp)
	if mg2:GetCount()>0 then mg:Merge(mg2) end
	return mg
end
-- 检查与其他素材组合时是否存在额外连接素材规则兼容问题
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
-- 过滤素材卡片组中与其他素材不兼容的卡片
function s.LUncompatibilityFilter(c,sg,lc,tp)
	-- 从素材组中排除当前检查的卡片
	local mg=sg:Filter(aux.TRUE,c)
	return not s.LCheckOtherMaterial(c,mg,lc,tp)
end
-- 校验选定的素材卡片组是否满足连接召唤的目标条件
function s.LCheckGoal(sg,tp,lc,gf,lmat)
	-- 检查玩家是否受特定效果影响以放宽素材数量/连接数限制
	return (Duel.IsPlayerAffectedByEffect(tp,38391684)
		and sg:CheckWithSumEqual(s.GetLinkCount,2,#sg,#sg)
		or sg:CheckWithSumEqual(s.GetLinkCount,lc:GetLink(),#sg,#sg))
		-- 检查从额外卡组特殊召唤的位置空缺及组合筛选条件
		and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0 and (not gf or gf(sg,lc,tp))
		and not sg:IsExists(s.LUncompatibilityFilter,1,nil,sg,lc,tp)
		and (not lmat or sg:IsContains(lmat))
end
-- 消耗额外连接素材卡片的效果使用次数限制
function s.LExtraMaterialCount(mg,lc,tp)
	-- 遍历所有用于连接召唤的素材卡
	for tc in aux.Next(mg) do
		local le={tc:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
		for _,te in pairs(le) do
			-- 获取除当前素材卡外的其他素材集合
			local sg=mg:Filter(aux.TRUE,tc)
			local f=te:GetValue()
			local related,valid=f(te,lc,sg,tc,tp)
			if related and valid then
				te:UseCountLimit(tp)
			end
		end
	end
end
-- 生成连接召唤手续的 Condition 条件判断函数
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
				-- 获取玩家必须作为连接素材使用的卡片组
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				-- 检查必须素材是否存在于可选素材集合中
				if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
				-- 预先选中必须使用的连接素材
				Duel.SetSelectedCard(fg)
				return mg:CheckSubGroup(s.LCheckGoal,minc,maxc,tp,c,gf,lmat)
			end
end
-- 生成连接召唤手续的 Target 目标选择函数
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
				-- 获取玩家必须作为连接素材使用的卡片组
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				-- 预先选中必须使用的连接素材
				Duel.SetSelectedCard(fg)
				-- 显示选择连接素材的提示信息
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)  --"请选择要作为连接素材的卡"
				-- 判断当前召唤过程是否可以取消
				local cancel=Duel.IsSummonCancelable()
				local sg=mg:SelectSubGroup(tp,s.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
				if sg then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
-- 生成连接召唤手续的 Operation 召唤执行函数
function s.LinkOperation(f,minct,maxct,gf)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				s.LExtraMaterialCount(g,c,tp)
				-- 将选定的连接素材作为连接素材送去墓地
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
			end
end
-- ①效果发动条件：此卡连接召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果卡组特召过滤条件：记有「海」卡名且可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	-- 判断卡片是否记有指定卡名且能被特殊召唤
	return aux.IsCodeListed(c,38391684) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动准备：检查怪兽区空位及卡组是否存在合法怪兽，设置特召分类信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只记有「海」的怪兽表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，无空位则终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果Cost过滤条件：自己场上表侧表示的「海」（22702055）且能送去墓地
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(22702055) and c:IsAbleToGraveAsCost()
end
-- ②效果发动条件：处于主要阶段
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否在主要阶段
	return Duel.IsMainPhase()
end
-- ②效果发动Cost：把自己场上1张表侧表示的「海」送去墓地
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：场上是否存在可作为Cost送去墓地的「海」
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 显示选择送去墓地卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1张表侧表示的「海」
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果发动准备：检查对方手牌数及抽牌可能，设置手牌丢弃与抽牌操作信息，封锁连锁
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取对方手牌张数
		local h=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
		-- 发动条件检查：对方手牌大于0且对方能抽取等同手牌数的卡
		return h>0 and Duel.IsPlayerCanDraw(1-tp,h)
	end
	-- 设置连锁操作信息：对方丢弃手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
	-- 设置连锁操作信息：对方抽牌
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	-- 设定连锁限制：双方不能对应此效果的发动把效果发动
	Duel.SetChainLimit(aux.FALSE)
end
-- ②效果处理：对方手牌全部送去墓地，之后对方抽取送去墓地数量的卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌张数
	local h=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 将对方手牌全部因效果送去墓地，并判断是否成功送去墓地
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)>0 then
		-- 中断效果处理流程
		Duel.BreakEffect()
		-- 对方因效果抽取送墓手牌数量的卡
		Duel.Draw(1-tp,h,REASON_EFFECT)
	end
end
