--No.69 紋章神コート・オブ・アームズ－ゴッド・シャーター
-- 效果：
-- 4星怪兽×4
-- 这张卡也能在原本卡名是「No.69 纹章神 盾徽」的自己场上的怪兽上面重叠来超量召唤。这个卡名的效果1回合只能使用1次。
-- ①：对方场上的怪兽把效果发动时或者对方怪兽的攻击宣言时才能发动。把1只「No.69 纹章神 盾徽-神之愤怒」在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。那之后，那1只对方怪兽破坏。
local s,id,o=GetID()
-- 初始化函数：给这张卡注册记载卡名、超量召唤手续（4星×4且可在「No.69 纹章神 盾徽」上重叠）、苏生限制，以及两个效果：对方怪兽攻击宣言时和对方怪兽效果发动时从额外卡组特殊召唤「No.69 纹章神 盾徽-神之愤怒」并破坏对方怪兽。
function s.initial_effect(c)
	-- 记录此卡在规则上记载着「No.69 纹章神 盾徽」(2407234)和「No.69 纹章神 盾徽-神之愤怒」(77571454)的卡名。
	aux.AddCodeList(c,2407234,77571454)
	aux.AddXyzProcedure(c,nil,4,4,s.ovfilter,aux.Stringid(id,0))  --"是否在「No.69 纹章神 盾徽」上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：对方怪兽的攻击宣言时才能发动。把1只「No.69 纹章神 盾徽-神之愤怒」在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。那之后，那1只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 设定这张卡的编号为69，使其适用No.相关规则。
aux.xyz_number[id]=69
-- 定义超量召唤的替代素材过滤：场上表侧表示且原本卡名规则上视为「No.69 纹章神 盾徽」的怪兽，可作为在这张卡上面重叠来超量召唤的素材。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(2407234)
end
-- 攻击宣言时效果的发动条件：攻击怪兽仍在场上，且攻击怪兽为对方怪兽，并把它保存到效果中。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若攻击宣言的怪兽不在场上，则不满足发动条件。
	if not Duel.GetAttacker():IsOnField() then return false end
	-- 将攻击宣言的怪兽存入效果e的标签，供后续选择/破坏时使用。
	e:SetLabelObject(Duel.GetAttacker())
	-- 确认攻击宣言的怪兽的控制者不是这张卡的控制者，即必须是对方怪兽的攻击宣言。
	return Duel.GetAttacker():GetControler()~=tp
end
-- 额外卡组中「No.69 纹章神 盾徽-神之愤怒」的筛选条件：卡号正确、是超量怪兽、当前这张卡可以作为其超量素材、它可以超量召唤、额外区有空位。
function s.spfilter(c,e,tp,mc)
	return c:IsCode(77571454) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 确认「No.69 纹章神 盾徽-神之愤怒」可被超量召唤，并且把这张卡作为素材移走后额外卡组仍有空余怪兽区域可用。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 攻击宣言效果的发动判定：没有必须作为超量素材的限制，且额外卡组存在满足条件的「No.69 纹章神 盾徽-神之愤怒」。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ac=e:GetLabelObject()
	-- 检查这张卡（作为超量素材）没有受到‘必须作为超量素材’等不可用限制。
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在至少1张满足特殊召唤条件的目标卡，作为效果发动的前提。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置本次效果的信息：包含特殊召唤操作，从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置本次效果的信息：将攻击怪兽ac登记为将被破坏的对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ac,1,0,0)
end
-- 攻击宣言效果的处理：选择1只「No.69 纹章神 盾徽-神之愤怒」，把这张卡及其原有超量素材全部叠放到其下方，以超量召唤形式特殊召唤，然后破坏之前记录的攻击怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=e:GetLabelObject()
	-- 效果处理时再次确认这张卡仍可作素材，若因效果导致不能使用则效果中止。
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 给玩家弹出选择提示：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 由玩家从额外卡组选择1只满足条件的「No.69 纹章神 盾徽-神之愤怒」。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 把这张卡原有的超量素材组全部转移叠放到被特殊召唤的No.69怪兽下方。
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 把这张卡自身也作为超量素材叠放到新的No.69怪兽下方，完成‘在这张卡上面重叠’的规则处理。
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将「No.69 纹章神 盾徽-神之愤怒」以超量召唤形式特殊召唤到自己的场上。
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
		if ac:IsRelateToBattle() and ac:IsControler(1-tp) and ac:IsType(TYPE_MONSTER) then
			-- 中断当前效果链，使之后的破坏处理与特殊召唤分开为不同时点，符合‘那之后’的处理。
			Duel.BreakEffect()
			-- 以效果原因破坏对方那只攻击怪兽。
			Duel.Destroy(ac,REASON_EFFECT)
		end
	end
end
-- 对方效果发动时的发动条件：对方怪兽在场上发动效果且该效果为怪兽效果，并且发动怪兽仍与效果相关。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep==1-tp and re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
end
-- 对方怪兽效果发动时的发动判定：无素材限制，且额外卡组存在可特殊召唤的「No.69 纹章神 盾徽-神之愤怒」。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 同攻击宣言分支：检查这张卡没有‘必须作为超量素材’等限制。
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否有满足条件的「No.69 纹章神 盾徽-神之愤怒」可供特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置本次效果的信息：包含特殊召唤，从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置本次效果的信息：将对方发动效果的那只怪兽（eg）登记为将被破坏的对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 对方效果发动时的效果处理：特殊召唤「No.69 纹章神 盾徽-神之愤怒」，然后破坏对方发动效果的那只怪兽。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 同id=18：处理时再次确认素材可用，否则中止。
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 由玩家从额外卡组选择1只满足条件的「No.69 纹章神 盾徽-神之愤怒」。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 把这张卡原有的超量素材全部转移叠放到新的No.69怪兽下方。
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 把这张卡自身也作为超量素材叠放到新的No.69怪兽下方。
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将「No.69 纹章神 盾徽-神之愤怒」以超量召唤形式特殊召唤。
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
		if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsFaceup() and re:GetHandler():IsControler(1-tp) then
			-- 中断效果处理，使之后的破坏与特殊召唤成为独立处理的时点。
			Duel.BreakEffect()
			-- 以效果原因破坏对方发动效果的那组怪兽（eg）。
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
