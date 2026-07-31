--新世竜ダニアン
-- 效果：
-- 这张卡用怪兽的效果特殊召唤的场合：可以从卡组把1只「GMX」怪兽加入手卡。
-- 自己主要阶段：可以把自己手卡·场上的怪兽作为融合素材，把1只恐龙族融合怪兽融合召唤。
-- 这张卡被送去墓地的场合：可以让自己场上的全部的恐龙族怪兽的攻击力上升400。
-- 「返祖小龙 丹宁」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果（检索、融合召唤、攻击力上升）
function s.initial_effect(c)
	-- 效果1：这张卡用怪兽的效果特殊召唤的场合：可以从卡组把1只「GMX」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 效果2：自己主要阶段：可以把自己手卡·场上的怪兽作为融合素材，把1只恐龙族融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
	-- 效果3：这张卡被送去墓地的场合：可以让自己场上的全部的恐龙族怪兽的攻击力上升400。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"攻击力上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- 设置触发条件：这张卡必须是通过怪兽效果特殊召唤成功的场合
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 定义检索过滤器：卡组中「GMX」怪兽（系列号0x1dd）、怪兽类型、能够加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果1的Target函数：检测是否存在符合条件的「GMX」怪兽并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组是否存在符合条件的检索卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示对方玩家选择了检索效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：将1张卡从卡组加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果1的Operation函数：执行检索操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的「GMX」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤器1：筛选不受效果影响的怪兽用于融合素材
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤器2：筛选符合条件的恐龙族融合怪兽并检查融合素材是否足够
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DINOSAUR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果2的Target函数：检测是否可以进行融合召唤
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用融合素材并过滤不受效果影响的卡
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检测额外卡组是否存在符合条件的恐龙族融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取连锁融合素材效果（用于融合魔法卡）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材时再次检测融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 提示对方玩家选择了融合召唤效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：特殊召唤1只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果2的Operation函数：执行融合召唤
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取玩家额外卡组中符合条件的恐龙族融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取使用连锁素材时的融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断使用普通融合素材还是连锁融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家选择普通融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送墓（原因包含效果、素材、融合）
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果以进行特殊召唤
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 玩家选择连锁融合素材并执行
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 攻击力上升过滤器：场上表侧表示的恐龙族怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- 效果3的Target函数：检测是否存在恐龙族怪兽
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测场上是否存在恐龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果3的Operation函数：执行攻击力上升
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有恐龙族怪兽
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历所有恐龙族怪兽
	for tc in aux.Next(g) do
		-- 让自己的恐龙族怪兽的攻击力上升400
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
