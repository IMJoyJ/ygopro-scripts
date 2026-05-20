--CX－N・As・Ch Knight
-- 效果：
-- 6星怪兽×3
-- 这张卡也能在自己场上的「伟人庇护战车骑士」上面重叠来超量召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：场上的这张卡不会被效果破坏。
-- ②：把这张卡1个超量素材取除才能发动。把1只「No.101」～「No.107」其中任意种的「No.」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽在下次的对方结束阶段破坏。
function c61374414.initial_effect(c)
	aux.AddXyzProcedure(c,nil,6,3,c61374414.ovfilter,aux.Stringid(61374414,0))  --"是否在「伟人庇护战车骑士」上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：场上的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除才能发动。把1只「No.101」～「No.107」其中任意种的「No.」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽在下次的对方结束阶段破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61374414,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,61374414)
	e2:SetCost(c61374414.spcost)
	e2:SetTarget(c61374414.sptg)
	e2:SetOperation(c61374414.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「伟人庇护战车骑士」作为重叠超量召唤的素材
function c61374414.ovfilter(c)
	return c:IsCode(34876719) and c:IsFaceup()
end
-- 效果②的COST：取除这张卡的1个超量素材
function c61374414.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤额外卡组中可以重叠在自身上方进行超量召唤的「No.101」～「No.107」超量怪兽
function c61374414.spfilter(c,e,tp,mc)
	-- 获取额外卡组怪兽的「No.」编号
	local no=aux.GetXyzNumber(c)
	return no and no>=101 and no<=107 and c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否能以超量召唤的方式特殊召唤，且额外怪兽区域有可用空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的发动准备（检查是否有必须作为超量素材的限制，以及额外卡组是否存在可特殊召唤的怪兽）
function c61374414.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在必须作为超量素材的卡片限制
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在至少1只满足条件的「No.」超量怪兽
		and Duel.IsExistingMatchingCard(c61374414.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置连锁信息，表示该效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理：将额外卡组的「No.」超量怪兽重叠在自身上方当作超量召唤特殊召唤，并注册下次对方结束阶段破坏的效果
function c61374414.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查必须作为超量素材的限制，若不满足则不处理
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从额外卡组选择1只满足条件的「No.」超量怪兽
		local g=Duel.SelectMatchingCard(tp,c61374414.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将这张卡原本持有的超量素材转移给新召唤的怪兽
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将这张卡自身作为超量素材叠放在新召唤的怪兽下面
			Duel.Overlay(sc,Group.FromCards(c))
			-- 尝试将选择的怪兽以超量召唤的形式特殊召唤
			if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
				sc:CompleteProcedure()
				-- 这个效果特殊召唤的怪兽在下次的对方结束阶段破坏。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetCountLimit(1)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetLabelObject(sc)
				e1:SetCondition(c61374414.descon)
				e1:SetOperation(c61374414.desop)
				-- 检查当前是否已经是对方回合的结束阶段（如果是，则破坏时点需要顺延到下一次对方结束阶段）
				if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_END then
					e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
					-- 将当前回合数记录在效果的Label中，用于后续判断是否在同一回合
					e1:SetLabel(Duel.GetTurnCount())
					sc:RegisterFlagEffect(61374414,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,2)
				else
					e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
					e1:SetLabel(0)
					sc:RegisterFlagEffect(61374414,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
				end
				-- 注册用于在结束阶段执行破坏的全局延迟效果
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 延迟破坏效果的发动条件：必须是对方回合的结束阶段，且不能是效果注册的当回合
function c61374414.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前是自己回合，或者当前回合数等于注册效果时的回合数（防止在对方结束阶段发动时当场被破坏），则不触发破坏
	if Duel.GetTurnPlayer()==tp or Duel.GetTurnCount()==e:GetLabel() then return false end
	return e:GetLabelObject():GetFlagEffect(61374414)>0
end
-- 延迟破坏效果的具体操作：破坏该特殊召唤的怪兽
function c61374414.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将特殊召唤的怪兽破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
