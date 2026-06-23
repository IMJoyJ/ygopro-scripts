--ジェムナイト・ディスパージョン
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●自己的手卡·场上的怪兽作为融合素材，把1只「宝石骑士」融合怪兽融合召唤。自己墓地有「宝石骑士融合」存在的场合，卡组·额外卡组的岩石族以外的「宝石骑士」怪兽也能有最多2只作为融合素材。
-- ●自己的卡组·除外状态的1只「宝石」怪兽加入手卡。这个回合的主要阶段内，对方受到的效果伤害变成一半。
local s,id,o=GetID()
-- 初始化卡片效果，注册发动效果
function s.initial_effect(c)
	-- 记录该卡与「宝石骑士融合」卡名的关联
	aux.AddCodeList(c,1264319)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON|CATEGORY_SEARCH|CATEGORY_TOHAND|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足融合素材条件的卡片（宝石骑士族、非岩石族、怪兽类型、可作为融合素材、可送入墓地）
function s.filter0(c)
	return c:IsSetCard(0x1047) and not c:IsRace(RACE_ROCK)
		and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤不免疫效果的卡片
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤满足融合召唤条件的卡片（融合怪兽、宝石骑士族、可特殊召唤、可检查融合素材）
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1047) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤满足加入手牌条件的卡片（表侧表示、宝石族、怪兽类型、可加入手牌）
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x47) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检查融合素材中来自卡组或额外卡组的卡片数量是否不超过2张
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=2
end
-- 检查融合素材中来自卡组或额外卡组的卡片数量是否不超过2张
function s.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=2
end
-- 判断是否可以发动效果，包括融合召唤和加入手牌两种选项
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	-- 获取玩家可用的融合素材组（手卡和场上的怪兽）
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 检查玩家墓地是否存在「宝石骑士融合」
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,1264319) then
		-- 获取卡组和额外卡组中满足条件的融合素材
		local sg=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
		mg1:Merge(sg)
		-- 设置融合素材数量检查函数
		aux.FCheckAdditional=s.fcheck
		-- 设置融合素材数量检查函数
		aux.GCheckAdditional=s.gcheck
	end
	-- 检查是否存在满足融合召唤条件的融合怪兽
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	-- 清除融合素材数量检查函数
	aux.FCheckAdditional=nil
	-- 清除融合素材数量检查函数
	aux.GCheckAdditional=nil
	if not res then
		-- 获取当前连锁的融合素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 检查是否存在满足融合召唤条件的融合怪兽
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	-- 判断是否可以发动融合召唤效果
	local b1=res and (Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
	-- 检查是否存在满足加入手牌条件的卡片
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil)
		-- 判断是否可以发动加入手牌效果
		and (Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and not b2 then
		-- 提示对方选择了融合召唤效果
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))  --"融合召唤"
		op=1
	end
	if b2 and not b1 then
		-- 提示对方选择了加入手牌效果
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))  --"加入手卡"
		op=2
	end
	if b1 and b2 then
		-- 让玩家选择发动效果
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1)},  --"融合召唤"
			{b2,aux.Stringid(id,2)})  --"加入手卡"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON|CATEGORY_DECKDES)
			-- 注册融合召唤效果的使用标记
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置融合召唤效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND)
			-- 注册加入手牌效果的使用标记
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置加入手牌效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
	end
end
-- 处理发动效果的逻辑，包括融合召唤和加入手牌两种情况
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local chkf=tp
		-- 获取玩家可用的融合素材组（手卡和场上的怪兽）
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		local exmat=false
		-- 检查玩家墓地是否存在「宝石骑士融合」
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,1264319) then
			-- 获取卡组和额外卡组中满足条件的融合素材
			local sg=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e)
			if sg:GetCount()>0 then
				mg1:Merge(sg)
				exmat=true
			end
		end
		if exmat then
			-- 设置融合素材数量检查函数
			aux.FCheckAdditional=s.fcheck
			-- 设置融合素材数量检查函数
			aux.GCheckAdditional=s.gcheck
		end
		-- 获取满足融合召唤条件的融合怪兽
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		-- 清除融合素材数量检查函数
		aux.FCheckAdditional=nil
		-- 清除融合素材数量检查函数
		aux.GCheckAdditional=nil
		local mg2=nil
		local sg2=nil
		-- 获取当前连锁的融合素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 获取满足融合召唤条件的融合怪兽
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要特殊召唤的融合怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			mg1:RemoveCard(tc)
			-- 判断是否使用原融合素材或连锁融合素材
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				if exmat then
					-- 设置融合素材数量检查函数
					aux.FCheckAdditional=s.fcheck
					-- 设置融合素材数量检查函数
					aux.GCheckAdditional=s.gcheck
				end
				-- 选择融合召唤的融合素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				-- 清除融合素材数量检查函数
				aux.FCheckAdditional=nil
				-- 清除融合素材数量检查函数
				aux.GCheckAdditional=nil
				tc:SetMaterial(mat1)
				-- 将融合素材送入墓地
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 特殊召唤融合怪兽
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce~=nil then
				-- 选择融合召唤的融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的卡片
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将卡片送入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看卡片
			Duel.ConfirmCards(1-tp,g)
		end
		-- 检查是否已注册伤害减半效果
		if Duel.GetFlagEffect(tp,51831560)==0 then
			-- 注册伤害减半效果
			Duel.RegisterFlagEffect(tp,51831560,RESET_PHASE+PHASE_END,0,1)
			-- ●自己的卡组·除外状态的1只「宝石」怪兽加入手卡。这个回合的主要阶段内，对方受到的效果伤害变成一半。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CHANGE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(0,1)
			e1:SetCondition(s.damcon)
			e1:SetValue(s.damval)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册伤害减半效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 判断是否处于主要阶段1或主要阶段2
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 计算伤害值，若为效果伤害则减半
function s.damval(e,re,val,r,rp,rc)
	if r&REASON_EFFECT==REASON_EFFECT then
		return math.ceil(val/2)
	else return val end
end
