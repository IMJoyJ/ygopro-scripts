--レイダーズ・ナイト
-- 效果：
-- 暗属性4星怪兽×2
-- 这个卡名在规则上也当作「幻影骑士团」卡、「急袭猛禽」卡使用。这个卡名的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。比这张卡阶级高1阶或低1阶的「幻影骑士团」、「急袭猛禽」、「超量龙」超量怪兽之内任意1只在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽在下次的对方结束阶段破坏。
function c28781003.initial_effect(c)
	-- 为这张卡添加超量召唤手续：以2只暗属性4星怪兽为超量素材；对应召唤条件“暗属性4星怪兽×2”。
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
-- 效果发动代价：检查并取除这张卡的1个超量素材；若无法取除则不能发动。
function c28781003.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤可用作特殊召唤对象的额外卡组超量怪兽：阶级与这张卡相差1、字段属于「幻影骑士团」「急袭猛禽」「超量龙」之一、是超量怪兽，且这张卡能作为其超量素材、该怪兽能由我方进行超量召唤，并有可用的特殊召唤区域。
function c28781003.filter(c,e,tp,mc)
	return c:IsRank(mc:GetRank()+1,mc:GetRank()-1) and c:IsSetCard(0x10db,0xba,0x2073) and c:IsType(TYPE_XYZ)
		and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 确认从额外卡组特殊召唤该怪兽时有可用的区域（计算这张卡被叠放后腾出的怪兽区空格）。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时选择对象（不取对象筛选额外卡组）：在满足素材手续合法且额外存在符合条件的怪兽时，允许进行后续特殊召唤操作。
function c28781003.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查这张卡是否可以合法地作为超量素材使用（即不存在使其不能成为素材或必须成为素材等限制，通过EFFECT_MUST_BE_XMATERIAL检测）。
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在至少1只满足特殊召唤条件的超量怪兽（阶级±1、字段相符、可超量召唤等）。
		and Duel.IsExistingMatchingCard(c28781003.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置操作信息：本次效果将进行1只额外卡组怪兽的特殊召唤，供连锁判定和后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组选择符合条件的超量怪兽，将这张卡及其原有超量素材叠放在其下方，当作超量召唤特殊召唤；若成功，再给该怪兽设置一个在下次对方结束阶段将其破坏的持续效果。
function c28781003.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时确认：这张卡仍表侧在场、与发动效果有联系、控制权属于发动者、不受无效化效果影响，且超量素材手续仍合法。
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then
		-- 弹出提示，让玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足filter条件的超量怪兽作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,c28781003.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local tc=g:GetFirst()
		if tc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()>0 then
				-- 把这张卡原本持有的全部超量素材转移给被特殊召唤的怪兽（使其继承素材）。
				Duel.Overlay(tc,mg)
			end
			tc:SetMaterial(Group.FromCards(c))
			-- 将这张卡自身作为超量素材叠放在要特殊召唤的怪兽下面（实现“在这张卡上面重叠当作超量召唤”）。
			Duel.Overlay(tc,Group.FromCards(c))
			-- 以超量召唤的方式将选择的怪兽正面表示特殊召唤到自己的额外怪兽区或主怪兽区。
			if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
				tc:CompleteProcedure()
				-- 这个效果特殊召唤的怪兽在下次的对方结束阶段破坏。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetCountLimit(1)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetLabelObject(tc)
				e1:SetCondition(c28781003.descon)
				e1:SetOperation(c28781003.desop)
				-- 若当前正处于对方结束阶段，则需要调整破坏效果的重置时间和标记次数，使其在“下次”对方结束阶段（而不是本次）才破坏，并避免重复破坏。
				if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_END then
					e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
					-- 在标签中记录当前回合数，用于区分“本次”与“下次”结束阶段。
					e1:SetLabel(Duel.GetTurnCount())
					tc:RegisterFlagEffect(28781003,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,2)
				else
					e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
					e1:SetLabel(0)
					tc:RegisterFlagEffect(28781003,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
				end
				-- 将破坏效果作为全场持续效果注册，使其能在满足条件时触发。
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 破坏效果的条件：在对方结束阶段（不能是发动当回合的对方结束阶段），且通过标记确认该怪兽仍应被破坏。
function c28781003.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 当现在是自己的回合（不是对方结束阶段），或回合数仍等于发动时的回合数（说明还没到“下次”对方结束阶段）时，不满足破坏条件。
	if Duel.GetTurnPlayer()==tp or Duel.GetTurnCount()==e:GetLabel() then return false end
	return e:GetLabelObject():GetFlagEffect(28781003)>0
end
-- 破坏处理：将特殊召唤的怪兽（标签对象）破坏。
function c28781003.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行实际破坏，将那只怪兽以效果破坏送入墓地。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
