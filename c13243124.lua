--F・HERO フレイム・ウィングマン
-- 效果：
-- 相同种族而属性不同的怪兽×2
-- 这个卡名在规则上也当作「元素英雄」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡和攻击力2200以上的怪兽进行战斗的攻击宣言时才能发动。这张卡的攻击力上升1000。那之后，可以从手卡把1只4星以下的怪兽守备表示特殊召唤。
-- ②：怪兽被战斗破坏的自己·对方回合才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册卡片的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤条件（相同种族而属性不同的怪兽×2）
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- ①：这张卡和攻击力2200以上的怪兽进行战斗的攻击宣言时才能发动。这张卡的攻击力上升1000。那之后，可以从手卡把1只4星以下的怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：怪兽被战斗破坏的自己·对方回合才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_BATTLE_END+TIMING_MAIN_END+TIMING_END_PHASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.fspcon)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 相同种族而属性不同的怪兽×2/①：这张卡和攻击力2200以上的怪兽进行战斗的攻击宣言时才能发动。这张卡的攻击力上升1000。那之后，可以从手卡把1只4星以下的怪兽守备表示特殊召唤。/②：怪兽被战斗破坏的自己·对方回合才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		-- 注册全局环境下的破坏检测事件监听器
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤被战斗破坏送去墓地或原本是怪兽但在怪兽区被战斗破坏的卡
function s.cfilter(c)
	return (c:IsPreviousLocation(LOCATION_MZONE) or c:GetOriginalType()&TYPE_MONSTER~=0)
		and c:IsReason(REASON_BATTLE)
end
-- 全局事件监听器处理函数，当有怪兽被战斗破坏时，为双方注册对应的状态标记
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.cfilter,1,nil) then
		-- 为当前回合玩家注册一个当回合有效的战斗破坏状态标记
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 为对手玩家注册一个当回合有效的战斗破坏状态标记
		Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 融合素材过滤函数，用于判定相同种族而属性不同的怪兽
function s.ffilter(c,fc,sub,mg,sg)
	-- 如果当前未选择其他融合素材，则任何怪兽皆可作为首张素材
	return not sg or sg:FilterCount(aux.TRUE,c)==0
		or (sg:IsExists(Card.IsRace,1,c,c:GetRace())
			and not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 效果①的发动条件判定（与攻击力2200以上的怪兽进行战斗的攻击宣言时）
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsFaceup() and bc:IsAttackAbove(2200)
end
-- 效果①发动的可行性检测与效果目标处理
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家展示效果的发动提示
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 过滤手卡中等级4以下且能够守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的处理逻辑，使这张卡攻击力上升1000，并可以选择从手卡特殊召唤怪兽
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToChain() then
		-- 这张卡的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 获取手卡中等级4以下且可特殊召唤的怪兽
			local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
			-- 如果自己场上有空位且存在符合特殊召唤条件的怪兽，询问玩家是否进行特殊召唤
			if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
				-- 中断效果处理，使后续特殊召唤与攻击力上升视为不同时处理
				Duel.BreakEffect()
				-- 给玩家发送提示信息以选择要特殊召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg=g:Select(tp,1,1,nil)
				-- 特殊召唤选中的怪兽并以表侧守备表示放置
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
	end
end
-- 效果②的发动条件判定（这回合有怪兽被战斗破坏）
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家当回合是否已被注册了怪兽被战斗破坏的状态标记
	return Duel.GetFlagEffect(tp,id)>0
end
-- 过滤不受当前融合召唤效果影响的怪兽
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤能够进行融合召唤的融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果②融合召唤效果发动的可行性检测与效果目标处理
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家自己可用的融合素材并过滤不合法的卡
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查额外卡组中是否存在可用当前素材融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查是否存在适用的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在有连锁素材效果存在时，使用对应素材再次检查额外卡组是否可以融合召唤
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 向对方玩家展示效果的发动提示
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置融合召唤的特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理逻辑，让玩家选择并融合召唤一只融合怪兽
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己场上和手卡的融合素材怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组中能够以当前素材融合召唤的全部怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 检查是否存在适用的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材效果的怪兽组获取额外卡组中可以融合召唤的怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 给玩家发送提示信息以选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否只通过正常的手卡·场上素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择手卡或场上的怪兽作为融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材怪兽送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使送去墓地与融合召唤的特殊召唤视为不同时处理
			Duel.BreakEffect()
			-- 特殊召唤融合召唤的怪兽并表侧表示
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 使用连锁素材效果选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
