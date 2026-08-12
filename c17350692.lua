--Yomagna the Fire Phantom
-- 效果：
-- 这张卡不能通常召唤。从自己墓地让种类（怪兽·魔法·陷阱）相同的3张卡回到卡组·额外卡组的场合可以从手卡特殊召唤。
-- 这张卡特殊召唤的场合：可以宣言1个种族；这张卡直到回合结束时变成那个种族。
-- 自己主要阶段：可以把包含这张卡的自己·对方场上的怪兽作为融合素材，把1只融合怪兽从额外卡组融合召唤。
-- 「幻影火精 约马格努」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化这张卡的三个效果：e1为手卡中的特殊召唤规则效果（不能通常召唤，以墓地3张同种类卡回卡组为条件），e2为特殊召唤成功时触发的宣言种族并变更种族的效果（同名卡1回合1次），e3为自己主要阶段发动的融合召唤效果（同名卡1回合1次）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地让种类（怪兽·魔法·陷阱）相同的3张卡回到卡组·额外卡组的场合可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤的场合：可以宣言1个种族；这张卡直到回合结束时变成那个种族。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变种族"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.racetg)
	e2:SetOperation(s.raceop)
	c:RegisterEffect(e2)
	-- 自己主要阶段：可以把包含这张卡的自己·对方场上的怪兽作为融合素材，把1只融合怪兽从额外卡组融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"融合效果"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.fsptg)
	e3:SetOperation(s.fspop)
	c:RegisterEffect(e3)
end
-- 过滤器：判断墓地的卡是否可以作为代价回到卡组或额外卡组
function s.sprfilter(c)
	return c:IsAbleToDeckAsCost() or c:IsAbleToExtraAsCost()
end
-- 子组检查：判断选出的卡组中是否存在3张种类相同（怪兽·魔法·陷阱之一）的卡
function s.gcheck(g)
	return g:IsExists(Card.IsType,3,nil,TYPE_MONSTER)
		or g:IsExists(Card.IsType,3,nil,TYPE_SPELL)
		or g:IsExists(Card.IsType,3,nil,TYPE_TRAP)
end
-- 特殊召唤规则的条件判断：自己场上怪兽区域有空位，且墓地存在3张种类相同的可以回到卡组·额外卡组的卡
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检索自己墓地中可以作为代价回到卡组或额外卡组的卡（这张卡除外）
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	-- 确认自己的主要怪兽区域有空位可以特殊召唤这张卡
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and g:CheckSubGroup(s.gcheck,3,3)
end
-- 特殊召唤规则的对象选择处理：从自己墓地中选择3张种类相同的卡作为回到卡组的对象，并保存到LabelObject供后续处理使用
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 检索自己墓地中可以作为代价回到卡组或额外卡组的卡（这张卡除外）
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	-- 向玩家提示：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,true,3,3)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的处理：将之前选定的3张墓地卡作为特殊召唤的代价回到持有者卡组并洗切，之后特殊召唤这张卡
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 为选定的3张卡显示被选择的动画，并记录它们被选为对象
	Duel.HintSelection(g)
	-- 把选定的3张卡作为特殊召唤的代价回到持有者的卡组并洗切卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 宣言种族效果的对象处理：让发动玩家从全部种族中宣言1个这张卡当前不是（按位排除当前种族）的种族，并保存到Label
function s.racetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家提示：请选择要宣言的种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从全种族中宣言1个这张卡当前种族以外的种族
	local race=Duel.AnnounceRace(tp,1,RACE_ALL&~e:GetHandler():GetRace())
	e:SetLabel(race)
end
-- 宣言种族效果的处理：若这张卡仍在场上表侧表示且与宣言的种族不同，则给这张卡注册一个直到回合结束时种族变为宣言种族的永续效果
function s.raceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race=e:GetLabel()
	if c:IsRelateToChain() and c:IsFaceup() and bit.band(c:GetRace(),race)==0 then
		-- 这张卡直到回合结束时变成那个种族。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(race)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤器：判断对方场上的卡是否表侧表示、可以作为融合素材且不受这张卡效果影响（用于把对方场上的怪兽也纳入融合素材）
function s.filter0(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 过滤器：判断卡是否在场上且不受这张卡效果影响（从己方融合素材中筛选场上的怪兽）
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsOnField()
end
-- 过滤器：判断额外卡组的融合怪兽是否可以以现有素材被融合召唤
function s.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 融合召唤效果的对象处理：汇集自己场上可用的融合素材和对方场上可作融合素材的怪兽，检查额外卡组是否存在能以这些素材融合召唤的融合怪兽（若不行再考虑连锁素材），并设置特殊召唤的操作信息
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 取得自己可用的融合素材并筛选其中在场上且不受本效果影响的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检索对方场上表侧表示、可作为融合素材且不受本效果影响的怪兽
		local mg2=Duel.GetMatchingGroup(s.filter0,tp,0,LOCATION_MZONE,nil,e)
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
		end
		-- 检查额外卡组是否存在能以当前素材融合召唤的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 取得玩家受到的连锁素材的效果（若有则考虑用其素材进行融合召唤）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在存在连锁素材效果时，检查额外卡组是否存在能以连锁素材指定的素材融合召唤的融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：声明本效果处理中将从额外卡组特殊召唤1只怪兽（用于星尘龙、王家长眠之谷等的检测）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的处理：汇集双方场上可作融合素材的怪兽和连锁素材素材，让玩家选择1只可融合召唤的融合怪兽，选择包含这张卡的融合素材送去墓地后，把该融合怪兽从额外卡组融合召唤
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 若当前处于伤害步骤或伤害计算阶段则中断处理
	if Duel.GetCurrentPhase()&(PHASE_DAMAGE+PHASE_DAMAGE_CAL)~=0 then return end
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) then return end
	-- 取得自己可用的融合素材并筛选其中在场上且不受本效果影响的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 检索对方场上表侧表示、可作为融合素材且不受本效果影响的怪兽
	local mg2=Duel.GetMatchingGroup(s.filter0,tp,0,LOCATION_MZONE,nil,e)
	if mg2:GetCount()>0 then
		mg1:Merge(mg2)
	end
	-- 检索额外卡组中能以当前素材融合召唤的全部融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg3=nil
	local sg2=nil
	-- 取得玩家受到的连锁素材的效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 在存在连锁素材效果时，检索额外卡组中能以连锁素材指定的素材融合召唤的全部融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家提示：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选中的融合怪兽是否用普通素材融合召唤：若其只能用普通素材召唤，或玩家对是否使用连锁素材效果选择了“否”，则走普通融合召唤分支
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从素材中选择一组必须包含这张卡在内的融合怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 把选定的融合素材作为效果·融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使之后的特殊召唤与素材送墓视为不同时处理（避免连锁时点问题）
			Duel.BreakEffect()
			-- 将选定的融合怪兽以融合召唤方式表侧攻击表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 在连锁素材分支中，让玩家从连锁素材指定的素材中选择一组必须包含这张卡在内的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
