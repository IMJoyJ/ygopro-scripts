--レイダーズ・ナイト
-- 效果：
-- 暗属性4星怪兽×2
-- 这个卡名在规则上也当作「幻影骑士团」卡、「急袭猛禽」卡使用。这个卡名的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。比这张卡阶级高1阶或低1阶的「幻影骑士团」、「急袭猛禽」、「超量龙」超量怪兽之内任意1只在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽在下次的对方结束阶段破坏。
function c28781003.initial_effect(c)
	-- 为卡片添加暗属性4星怪兽×2的超量召唤手续
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。比这张卡阶级高1阶或低1阶的「幻影骑士团」、「急袭猛禽」、「超量龙」超量怪兽之内任意1只在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽在下次的对方结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28781003,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,28781003)
	e1:SetCost(c28781003.cost)
	e1:SetTarget(c28781003.target)
	e1:SetOperation(c28781003.operation)
	c:RegisterEffect(e1)
end
-- 检查并移除1个超量素材作为发动代价
function c28781003.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足阶级条件、种族条件、类型为超量、可作为素材、可特殊召唤且场上存在召唤空间的额外卡组怪兽
function c28781003.filter(c,e,tp,mc)
	return c:IsRank(mc:GetRank()+1,mc:GetRank()-1) and c:IsSetCard(0x10db,0xba,0x2073) and c:IsType(TYPE_XYZ)
		and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查目标怪兽是否满足特殊召唤的场地条件
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 检查是否满足发动条件，包括必须有超量素材且额外卡组存在符合条件的怪兽
function c28781003.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足发动条件，包括必须有超量素材
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c28781003.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果发动后的操作，包括选择怪兽、叠放素材、特殊召唤并设置破坏效果
function c28781003.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查发动条件，包括卡片正面表示、与效果相关、控制权归属、未免疫效果且有超量素材
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c28781003.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local tc=g:GetFirst()
		if tc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()>0 then
				-- 将原卡的叠放卡叠放到目标怪兽上
				Duel.Overlay(tc,mg)
			end
			tc:SetMaterial(Group.FromCards(c))
			-- 将原卡叠放到目标怪兽上
			Duel.Overlay(tc,Group.FromCards(c))
			-- 将目标怪兽以超量召唤方式特殊召唤到场上
			if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
				tc:CompleteProcedure()
				-- 创建一个在对方结束阶段触发的破坏效果
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetCountLimit(1)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetLabelObject(tc)
				e1:SetCondition(c28781003.descon)
				e1:SetOperation(c28781003.desop)
				-- 判断是否为对方回合且处于结束阶段
				if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_END then
					e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
					-- 记录当前回合数用于条件判断
					e1:SetLabel(Duel.GetTurnCount())
					tc:RegisterFlagEffect(28781003,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,2)
				else
					e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
					e1:SetLabel(0)
					tc:RegisterFlagEffect(28781003,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
				end
				-- 将破坏效果注册到游戏环境
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 判断破坏效果是否满足触发条件
function c28781003.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前玩家回合或已触发过效果
	if Duel.GetTurnPlayer()==tp or Duel.GetTurnCount()==e:GetLabel() then return false end
	return e:GetLabelObject():GetFlagEffect(28781003)>0
end
-- 执行破坏操作
function c28781003.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽因效果破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
