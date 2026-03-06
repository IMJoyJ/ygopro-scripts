--月光舞踏会
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡发动的回合的自己主要阶段才能发动。从卡组把1只「月光」怪兽送去墓地。
-- ②：自己把「月光」怪兽融合召唤的场合才能发动。自己的墓地·除外状态的1张「融合」加入手卡。那之后，可以选自己1张手卡丢弃。那个场合，这个回合，自己把「月光」怪兽融合召唤的场合只有1次，也能把自己墓地的怪兽除外作为融合素材。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡名代码列表，创建激活效果、送去墓地效果和融合召唤效果
function s.initial_effect(c)
	-- 记录该卡的卡名代码为24094653
	aux.AddCodeList(c,24094653)
	-- ①：这张卡发动的回合的自己主要阶段才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.reg)
	c:RegisterEffect(e1)
	-- ②：自己把「月光」怪兽融合召唤的场合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- 判断是否为首次注册融合素材修改函数
	if not aux.fus_mat_hack_check then
		-- 标记融合素材修改函数已注册
		aux.fus_mat_hack_check=true
		-- 定义用于筛选额外卡组中具有额外融合素材效果的卡片的过滤函数
		function aux.fus_mat_hack_exmat_filter(c)
			return c:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL,c:GetControler())
		end
		-- 保存原Duel.GetFusionMaterial函数
		_GetFusionMaterial=Duel.GetFusionMaterial
		-- 重写Duel.GetFusionMaterial函数，使其能包含额外卡组中的融合素材
		function Duel.GetFusionMaterial(tp,loc)
			if loc==nil then loc=LOCATION_HAND+LOCATION_MZONE end
			local g=_GetFusionMaterial(tp,loc)
			-- 获取额外卡组中具有额外融合素材效果的卡片组
			local exg=Duel.GetMatchingGroup(aux.fus_mat_hack_exmat_filter,tp,LOCATION_EXTRA,0,nil)
			return g+exg
		end
		-- 保存原Duel.SendtoGrave函数
		_SendtoGrave=Duel.SendtoGrave
		-- 重写Duel.SendtoGrave函数，处理融合召唤时的特殊处理
		function Duel.SendtoGrave(tg,reason)
			-- 判断是否为融合召唤导致的送去墓地操作
			if reason~=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION or aux.GetValueType(tg)~="Group" then
				return _SendtoGrave(tg,reason)
			end
			-- 筛选出融合召唤中涉及的额外卡组中的卡片
			local tc=tg:Filter(Card.IsLocation,nil,LOCATION_EXTRA+LOCATION_GRAVE):Filter(aux.fus_mat_hack_exmat_filter,nil):GetFirst()
			if tc then
				local te=tc:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL,tc:GetControler())
				te:UseCountLimit(tc:GetControler())
			end
			local rg=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			tg:Sub(rg)
			local ct1=_SendtoGrave(tg,reason)
			-- 将符合条件的卡片从墓地移除
			local ct2=Duel.Remove(rg,POS_FACEUP,reason)
			return ct1+ct2
		end
	end
end
-- 注册效果flag，用于标记该卡已发动
function s.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 判断该卡是否已发动
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- 筛选满足条件的「月光」怪兽
function s.tgfilter(c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置送去墓地效果的目标信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「月光」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置送去墓地效果的连锁信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行送去墓地效果
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「月光」怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 筛选满足条件的融合召唤的「月光」怪兽
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xdf) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsSummonPlayer(tp)
		and c:IsAllTypes(TYPE_FUSION+TYPE_MONSTER)
end
-- 判断是否有满足条件的融合召唤
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 筛选满足条件的「月光舞蹈会」卡
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsCode(24094653) and c:IsAbleToHand()
end
-- 设置加入手牌效果的目标信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「月光舞蹈会」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置加入手牌效果的连锁信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 执行加入手牌效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「月光舞蹈会」卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的卡加入手牌
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 获取玩家手牌中可丢弃的卡
		local sg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil,REASON_EFFECT+REASON_DISCARD)
		-- 询问是否丢弃手牌
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否丢弃手卡？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示选择要丢弃的手牌
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			local dg=sg:Select(tp,1,1,nil)
			-- 洗切玩家手牌
			Duel.ShuffleHand(tp)
			-- 将选中的手牌丢弃
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
			-- 注册额外融合素材效果，使玩家可将墓地怪兽作为融合素材
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,3))  --"「月光舞蹈会」的效果适用中"
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
			e1:SetTargetRange(LOCATION_GRAVE,0)
			e1:SetTarget(s.mttg)
			e1:SetValue(s.mtval)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册额外融合素材效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 设置额外融合素材的筛选条件
function s.mttg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 设置额外融合素材的筛选条件
function s.mtval(e,c)
	if not c then return true end
	return c:IsSetCard(0xdf)
end
