--獄神機Doom－Z
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：以自己场上1只其他的效果怪兽为对象才能发动。把持有和那只自己怪兽的等级相同数值的阶级的1只「终刻」超量怪兽或「坏狱神 朱庇特」在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把自己场上的这张卡当作装备魔法卡使用来装备。
-- ③：这张卡被破坏的场合才能发动。从卡组把1张「终刻」卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①的额外卡组特召限制、②的重叠超量召唤并装备自身、③的被破坏时检索「终刻」卡的效果。
function s.initial_effect(c)
	-- 将「坏狱神 朱庇特」(68231287)注册为此卡的效果相关卡片密码，以便于其他卡片进行关联检索或确认。
	aux.AddCodeList(c,68231287)
	-- ①：自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只其他的效果怪兽为对象才能发动。把持有和那只自己怪兽的等级相同数值的阶级的1只「终刻」超量怪兽或「坏狱神 朱庇特」在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把自己场上的这张卡当作装备魔法卡使用来装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合才能发动。从卡组把1张「终刻」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 限制特召的过滤函数，若特召的怪兽不是超量怪兽且从额外卡组特召，则不能特殊召唤。
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤自己场上表侧表示、有等级且是效果怪兽，并且额外卡组存在可重叠超量召唤的怪兽，且满足超量素材限制的怪兽。
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsType(TYPE_EFFECT)
		-- 检查额外卡组是否存在至少1只满足特召条件的「终刻」超量怪兽或「坏狱神 朱庇特」。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 检查该怪兽是否满足必须作为超量素材的规则限制。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤额外卡组中阶级与作为素材的怪兽等级相同、属于「终刻」或卡名为「坏狱神 朱庇特」的超量怪兽，且该怪兽可以被特召，且素材怪兽可以作为其超量素材，且额外怪兽区域有空位。
function s.spfilter(c,e,tp,mc)
	return c:IsRank(mc:GetLevel()) and (c:IsSetCard(0x1d2) or c:IsCode(68231287)) and c:IsAllTypes(TYPE_XYZ+TYPE_MONSTER)
		and mc:IsCanBeXyzMaterial(c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查在将作为素材的怪兽送去叠放后，额外卡组怪兽特召到场上是否有可用的位置。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的发动准备与合法性检测函数，包括检查魔法与陷阱区域是否有空位，以及场上是否存在可作为对象的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动效果的检测阶段，检查自己场上的魔法与陷阱区域是否有空位（用于装备自身）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在除自身以外的、可作为此效果对象的合法效果怪兽。
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e,tp) end
	-- 给玩家发送提示信息，要求选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只除自身以外的合法效果怪兽作为效果对象。
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),e,tp)
	-- 设置连锁的操作信息，表明此效果包含从额外卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 向对方玩家提示当前发动的效果（显示效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果②的效果处理函数，处理重叠超量召唤以及将自身作为装备卡装备给该超量怪兽的过程。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 再次检查该对象怪兽在效果处理时是否仍满足必须作为超量素材的规则限制。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToChain() or not tc:IsType(TYPE_MONSTER)
		or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 给玩家发送提示信息，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1只满足条件的「终刻」超量怪兽或「坏狱神 朱庇特」。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将作为素材的怪兽原本拥有的超量素材全部重叠到新召唤的超量怪兽下面。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的怪兽重叠到新召唤的超量怪兽下面作为其超量素材。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选择的超量怪兽以超量召唤的形式在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		if c:IsRelateToChain() and c:IsControler(tp) and c:IsFaceup() then
			-- 检查自己场上的魔法与陷阱区域是否已无空位。
			if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then
				-- 因规则原因将此卡送去墓地（无法装备时）。
				Duel.SendtoGrave(c,REASON_RULE)
				return
			end
			-- 将此卡作为装备卡装备给特殊召唤的超量怪兽，若装备失败则结束处理。
			if not Duel.Equip(tp,c,sc) then return end
			-- 把自己场上的这张卡当作装备魔法卡使用来装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(sc)
			e1:SetValue(s.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end
-- 装备限制函数，规定此卡只能装备给通过该效果特殊召唤的那只超量怪兽。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤卡组中属于「终刻」且可以加入手牌的卡片。
function s.thfilter(c)
	return c:IsSetCard(0x1d2) and c:IsAbleToHand()
end
-- 效果③的发动准备与合法性检测函数，检查卡组中是否存在可检索的「终刻」卡，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的检测阶段，检查自己卡组中是否存在至少1张可加入手牌的「终刻」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表明此效果包含从卡组将1张卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理函数，从卡组选择1张「终刻」卡加入手牌并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张满足条件的「终刻」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片通过效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方玩家进行确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
