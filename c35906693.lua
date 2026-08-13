--シャイニング・ドロー
-- 效果：
-- ①：自己抽卡阶段通过把通常抽卡的这张卡持续公开，那个回合的主要阶段1，可以以自己场上1只「希望皇 霍普」超量怪兽为对象，从以下效果选择1个发动。
-- ●从卡组·额外卡组选卡名不同的「异热同心武器」怪兽任意数量当作装备卡使用给作为对象的怪兽装备。
-- ●和作为对象的自己怪兽卡名不同的1只「希望皇 霍普」超量怪兽在那只怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c35906693.initial_effect(c)
	-- 对应①效果的前半句：自己抽卡阶段通过把通常抽卡的这张卡持续公开。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c35906693.regcon)
	e1:SetOperation(c35906693.regop)
	c:RegisterEffect(e1)
	-- 对应●效果：从卡组·额外卡组选卡名不同的「异热同心武器」怪兽任意数量当作装备卡使用给作为对象的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35906693,1))  --"装备"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c35906693.condition)
	e2:SetCost(c35906693.cost)
	e2:SetTarget(c35906693.eqtg)
	e2:SetOperation(c35906693.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(35906693,2))  --"超量召唤"
	e3:SetTarget(c35906693.sptg)
	e3:SetOperation(c35906693.spop)
	c:RegisterEffect(e3)
end
-- 该触发效果的发动条件：当前是抽卡阶段，本回合尚未用过此卡效果，且这张卡是通过规则抽卡抽到的通常抽卡。
function c35906693.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足：本回合没有使用过闪光抽卡的标识、处于抽卡阶段、且本次抽卡的原因为规则抽卡。
	return Duel.GetFlagEffect(tp,35906693)==0 and Duel.GetCurrentPhase()==PHASE_DRAW and c:IsReason(REASON_RULE)
end
-- 抽到此卡时，询问玩家是否要持续公开；若选择是，则给此卡附加持续公开效果并设置本回合使用标识。
function c35906693.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出选择提示，让玩家决定是否公开这张卡。
	if Duel.SelectYesNo(tp,aux.Stringid(35906693,0)) then  --"是否要持续公开「闪光抽卡」？"
		-- 对应“通过把通常抽卡的这张卡持续公开”：给这张卡附加永久公开效果，持续到主要阶段1结束。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(35906693,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1,EFFECT_FLAG_CLIENT_HINT,1,0,66)
	end
end
-- 第二个效果的发动条件：当前必须处于主要阶段1，才能发动后续效果。
function c35906693.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 效果的发动代价：确认这张卡已经通过抽卡阶段的公开操作持有对应标识，即已经满足“持续公开”的前提。
function c35906693.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(35906693)~=0 end
end
-- 对象筛选：以自己场上的表侧表示「希望皇」超量怪兽作为效果对象。
function c35906693.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f) and c:IsType(TYPE_XYZ)
end
-- 装备卡筛选：从卡组·额外卡组选择「异热同心武器」怪兽，且要满足场上同名唯一、不是禁止卡。
function c35906693.eqfilter(c,tp)
	return c:IsSetCard(0x107e) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 装备效果的发动条件与对象选择：选择1只符合条件的「希望皇」超量怪兽，同时确认魔陷区有空位且卡组·额外存在可装备的「异热同心武器」怪兽。
function c35906693.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c35906693.tgfilter(chkc) end
	-- 检查场上是否存在符合条件的表侧表示「希望皇」超量怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c35906693.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己魔陷区是否有空位来放置要装备的卡。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组或额外卡组中是否存在至少1张符合条件的「异热同心武器」怪兽。
		and Duel.IsExistingMatchingCard(c35906693.eqfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,tp) end
	-- 向玩家发送选择对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只符合条件的表侧表示「希望皇」超量怪兽作为对象。
	Duel.SelectTarget(tp,c35906693.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果的处理：从卡组·额外卡组选择卡名不同的「异热同心武器」怪兽任意数量，装备到对象怪兽身上，并给每张装备卡设置仅限该对象装备的限制。
function c35906693.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己魔陷区的可用空格数，用于限制可装备的数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local c=e:GetHandler()
	-- 取得发动效果时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if ft<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 向玩家发送选择装备卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 获取卡组与额外卡组中所有符合条件的「异热同心武器」怪兽作为候选集合。
	local g=Duel.GetMatchingGroup(c35906693.eqfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,tp)
	-- 让玩家从中选择1至ft张卡名互不相同的「异热同心武器」怪兽（ft为可用魔陷区数量）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	if not sg then return end
	local ec=sg:GetFirst()
	while ec do
		-- 将选择的怪兽作为装备卡装备给对象怪兽，使用分步处理以保证装备成功时能正确触发时点。
		Duel.Equip(tp,ec,tc,true,true)
		-- 对应“当作装备卡使用给作为对象的怪兽装备”：为装备卡设置装备限制，使其只能装备给当前对象。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c35906693.eqlimit)
		e1:SetLabelObject(tc)
		ec:RegisterEffect(e1)
		ec=sg:GetNext()
	end
	-- 完成装备处理，统一触发装备相关时点。
	Duel.EquipComplete()
end
-- 装备限制的判断：只有效果设置时记录的对象怪兽才能装备这张卡。
function c35906693.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 超量召唤效果的对象筛选：对象必须是「希望皇」超量怪兽，且额外卡组中存在能够以其为素材进行超量召唤的、卡名不同的「希望皇」超量怪兽，同时对象不受“必须作为超量素材”的限制。
function c35906693.filter1(c,e,tp)
	return c35906693.tgfilter(c)
		-- 检查额外卡组中是否存在符合条件的「希望皇」超量怪兽，且其卡名与作为对象的怪兽不同，并可以作为该对象的超量素材。
		and Duel.IsExistingMatchingCard(c35906693.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 检查对象怪兽是否受到“必须作为超量素材”的效果影响，若受影响则不能作为本次超量召唤的素材。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 额外卡组超量怪兽的筛选：是「希望皇」超量怪兽、卡名与对象不同、可以以对象为超量素材、能够以超量召唤方式特殊召唤，并且有可用额外怪兽区。
function c35906693.filter2(c,e,tp,mc)
	return c:IsSetCard(0x107f) and c:IsType(TYPE_XYZ) and not c:IsCode(mc:GetCode()) and mc:IsCanBeXyzMaterial(c)
		-- 确认该额外怪兽可以以超量召唤方式特殊召唤，且从额外卡组特殊召唤时有足够的可用区域。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 超量召唤效果的目标选择与操作信息设置：选择场上1只符合条件的「希望皇」超量怪兽，并声明将要进行超量召唤。
function c35906693.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c35906693.filter1(chkc,e,tp) end
	-- 检查场上是否存在能作为超量召唤素材的合法对象。
	if chk==0 then return Duel.IsExistingTarget(c35906693.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送选择对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的「希望皇」超量怪兽作为对象。
	Duel.SelectTarget(tp,c35906693.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果处理将进行特殊召唤，范围是额外卡组的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 超量召唤效果的处理：将对象怪兽及其叠放卡全部作为素材，在对象上方重叠召唤1只卡名不同的「希望皇」超量怪兽。
function c35906693.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果对象（作为超量素材的场上怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 再次确认对象怪兽没有被“必须作为超量素材”等限制所禁止，防止处理时状态变化。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 向玩家发送选择超量召唤怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件的「希望皇」超量怪兽作为特殊召唤目标。
	local g=Duel.SelectMatchingCard(tp,c35906693.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原本的叠放卡全部移动到新超量怪兽下面作为叠放素材。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽自身叠放在新超量怪兽下面，作为超量素材。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 以超量召唤方式将选择的怪兽特殊召唤到场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
