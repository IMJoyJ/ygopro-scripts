--D－HERO デスドグマガイ
-- 效果：
-- 这张卡不能通常召唤。「命运英雄 死亡教义人」1回合1次在把战士族或暗属性的怪兽合计3只从自己墓地除外的场合才能从手卡·墓地特殊召唤。
-- ①：这个方法让这张卡特殊召唤的场合才能发动。下次的准备阶段给与对方2000伤害。
-- ②：1回合1次，对方把效果发动时才能发动。自己的手卡·场上·墓地的怪兽作为融合素材回到卡组，把1只战士族或暗属性的融合怪兽融合召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册命运英雄系列字段、苏生限制、特殊召唤条件、手卡·墓地特殊召唤规则、①特殊召唤成功时给与伤害的效果和②对方效果发动时进行融合召唤的诱发即时效果
function s.initial_effect(c)
	-- 向这张卡注册「命运英雄」系列字段（0xc008），用于「命运英雄 死亡教义人」名称的判定
	aux.AddSetNameMonsterList(c,0xc008)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 「命运英雄 死亡教义人」1回合1次在把战士族或暗属性的怪兽合计3只从自己墓地除外的场合才能从手卡·墓地特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e2)
	-- ①：这个方法让这张卡特殊召唤的场合才能发动
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"给与伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，对方把效果发动时才能发动
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"融合召唤"
	e4:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.fspcon)
	e4:SetTarget(s.fsptg)
	e4:SetOperation(s.fspop)
	c:RegisterEffect(e4)
end
-- 定义素材过滤函数：符合条件的怪兽必须是暗属性或战士族、且可以作为cost除外
function s.spfilter(c)
	return (c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_WARRIOR)) and c:IsAbleToRemoveAsCost()
end
-- 定义特殊召唤的发动条件：这张卡本身在场时不判断（c==nil直接返回true）；要求自己的怪兽区域有空格，且自己墓地存在3只以上可作为cost除外的暗属性或战士族怪兽
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认自己怪兽区域有空位，且自己墓地存在至少3只满足条件（暗属性或战士族、可除外）的怪兽
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,3,c)
end
-- 定义特殊召唤的目标处理：从自己墓地选出3只要除外的暗属性或战士族怪兽，将选出的组合保存到标签对象中以供后续处理；若玩家取消选择则返回false
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己墓地中满足条件的怪兽组（暗属性或战士族、可作为cost除外）
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,c)
	-- 向玩家发送选卡提示：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 定义特殊召唤的处理操作：取得之前选定的3只怪兽，将它们表侧表示除外作为特殊召唤的手续，然后释放卡片组
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 把选定的3只怪兽表侧表示除外，作为这张卡特殊召唤的手续
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 定义①效果的发动条件：这张卡是用自己的特殊召唤规则（SUMMON_VALUE_SELF）特殊召唤成功的场合
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 定义①效果的处理：注册一个在准备阶段触发的持续效果，仅触发1次，在该准备阶段结束时重置
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的准备阶段给与对方2000伤害
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetOperation(s.damop2)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY)
	-- 把该准备阶段触发的效果注册给玩家tp的全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 定义准备阶段触发的处理：显示这张卡的卡片动画提示，然后给与对方2000点效果伤害
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示这张卡（死亡教义人）发动效果的卡片动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 给与对方玩家2000点效果伤害
	Duel.Damage(1-tp,2000,REASON_EFFECT)
end
-- 定义②效果的发动条件：连锁发动效果的玩家是对方（rp为对方）
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 定义融合素材过滤函数：作为融合素材的卡必须是怪兽、不受此效果免疫影响、且可以回到卡组
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 定义融合怪兽过滤函数：额外卡组的融合怪兽必须是暗属性或战士族、满足融合条件、可以用这些素材进行融合召唤
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_WARRIOR)) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 定义②效果的目标处理：收集手卡·场上·墓地的可用融合素材，检查额外卡组是否存在能用这些素材融合召唤的暗属性或战士族融合怪兽（含连锁素材的替代情况）；并设置特殊召唤与回到卡组的操作信息
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得自己可用的融合素材（手卡·场上的怪兽）中可作为融合素材回到卡组的卡
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 取得自己墓地中可作为融合素材回到卡组的怪兽
		local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,e)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在至少1只可以用上述素材融合召唤的暗属性或战士族融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 取得玩家受到的「连锁素材」类效果（若有，可替代通常融合素材）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 用连锁素材提供的素材再次检查额外卡组是否存在可融合召唤的暗属性或战士族融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：预计从额外卡组把1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：预计把自己手卡·场上·墓地的1张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- 定义②效果的处理操作：汇总手卡·场上·墓地（墓地素材需不受王家长眠之谷影响）的融合素材，选出可融合召唤的暗属性或战士族融合怪兽，让玩家选择1只；根据其使用通常素材还是连锁素材分支处理，将融合素材回到卡组后把该融合怪兽融合召唤
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得自己手卡·场上可作为融合素材并回到卡组的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 取得自己墓地中可作为融合素材回到卡组且不受王家长眠之谷影响的怪兽
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,e)
	mg1:Merge(mg2)
	-- 取得额外卡组中可以用这些素材融合召唤的暗属性或战士族融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 取得玩家受到的「连锁素材」类效果（若有）
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 取得额外卡组中可以用连锁素材提供的素材融合召唤的融合怪兽组
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家发送选卡提示：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽是否使用通常融合素材处理：若在sg1中，且不在sg2中或玩家选择不使用连锁素材的效果，则走通常融合素材分支
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从可用融合素材中选择用于该融合怪兽融合召唤的一组素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(s.fdfilter,1,nil) then
				local cg=mat1:Filter(s.fdfilter,nil)
				-- 将融合素材中里侧表示的场上怪兽或手卡中的卡给对方确认
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(s.gdfilter,1,nil) then
				local gg=mat1:Filter(s.gdfilter,nil)
				-- 为融合素材中表侧表示的场上怪兽或墓地中的卡显示被选为素材的动画提示
				Duel.HintSelection(gg)
			end
			-- 把融合素材作为融合召唤的素材效果处理送回卡组并洗切卡组
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使之后的特殊召唤视为不同时处理
			Duel.BreakEffect()
			-- 把选定的融合怪兽以融合召唤方式表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让玩家从连锁素材提供的素材中选择用于该融合怪兽融合召唤的一组素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 定义过滤函数：需要向对方确认的素材——场上里侧表示的怪兽或手卡中的卡
function s.fdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 定义过滤函数：需要显示选择动画的素材——场上表侧表示的怪兽或墓地中的卡
function s.gdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
