--ピュアリィ
-- 效果：
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1张「纯爱妖精」魔法·陷阱卡加入手卡。剩下的卡用喜欢的顺序回到卡组下面。
-- ②：1回合1次，自己主要阶段才能发动。手卡1张「纯爱妖精」速攻魔法卡给对方观看，把有那个卡名记述的1只超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤，把给人观看的卡作为那只超量怪兽的超量素材。
local s,id,o=GetID()
-- 创建并注册本卡的效果：e1 为召唤成功时发动的诱发效果（翻卡组顶3张，选1张「纯爱妖精」魔法·陷阱卡加入手卡，其余按喜欢顺序回卡组底）；e2 为 e1 的克隆，将触发时机改为特殊召唤成功；e3 为1回合1次的起动效果（展示手卡「纯爱妖精」速攻魔法，将本卡作为素材从额外卡组超量召唤对应怪兽，并把展示卡作为超量素材）。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1张「纯爱妖精」魔法·陷阱卡加入手卡。剩下的卡用喜欢的顺序回到卡组下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。手卡1张「纯爱妖精」速攻魔法卡给对方观看，把有那个卡名记述的1只超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤，把给人观看的卡作为那只超量怪兽的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件与对象玩家设定：检查自己卡组是否有3张以上，且其中至少1张能加入手卡；满足则把当前连锁的对象玩家设为发动玩家tp，供处理时使用。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若自己卡组不足3张，则效果不能发动。
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return false end
		-- 获取自己卡组最上方的3张卡（用于确认和筛选）。
		local g=Duel.GetDecktopGroup(tp,3)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	-- 将当前连锁处理的对象玩家设置为tp（发动者），后续翻卡、选卡均以该玩家为基准。
	Duel.SetTargetPlayer(tp)
end
-- 定义过滤条件：可用于检索的「纯爱妖精」魔法·陷阱卡，且能加入手卡。
function s.tdfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x18c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①处理：确认卡组顶3张；若其中有符合条件的「纯爱妖精」魔陷且发动者选择是，则选1张加入手卡并给对方确认，之后洗手卡；剩余卡由发动者排序后按顺序置于卡组底部。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出之前保存的对象玩家p（即发动者）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 确认玩家p卡组最上方的3张卡（向双方展示）。
	Duel.ConfirmDecktop(p,3)
	-- 获取玩家p卡组最上方的3张卡，作为后续筛选和处理的对象。
	local g=Duel.GetDecktopGroup(p,3)
	if not g or #g<1 then return end
	local ct=#g
	g=g:Filter(s.tdfilter,nil)
	-- 如果翻开的三张中存在符合条件的「纯爱妖精」魔陷，且发动者选择“是”（要加入手卡），则继续处理。
	if #g>0 and Duel.SelectYesNo(p,aux.Stringid(id,2)) then  --"是否选1张「纯爱妖精」魔法·陷阱卡加入手卡？"
		-- 显示选择提示，要求发动者从符合条件的卡中选择1张加入手卡。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(p,1,1,nil)
		-- 禁用自动洗切检测，因为接下来要将选中的卡从卡组加入手卡，但不需要系统额外洗卡组。
		Duel.DisableShuffleCheck()
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家（1-p）展示加入手卡的卡片，以确认加入手卡的内容。
		Duel.ConfirmCards(1-p,sg)
		-- 洗切玩家p的手卡，使手牌顺序随机化。
		Duel.ShuffleHand(p)
		ct=ct-1
	end
	if ct<=1 then return end
	-- 让玩家p对卡组顶剩余的ct张卡进行排序（第一张在最上面，随后依次向下）。
	Duel.SortDecktop(p,p,ct)
	for i=1,ct do
		-- 获取排序后卡组顶部的1张卡。
		local mg=Duel.GetDecktopGroup(p,1)
		-- 将该卡移动到卡组底部，循环后剩余卡按玩家喜欢的顺序回到卡组下面。
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
end
-- 额外卡组超量怪兽的过滤条件：该怪兽效果文本上记载了所选速攻魔法的卡名；可以以超量召唤方式特殊召唤；本身是超量怪兽；当前场上的「纯爱妖精」可以作为其超量素材；且自己有可用的额外怪兽区域。
function s.sptgexfilter(c,e,tp,code)
	local sc=e:GetHandler()
	-- 检查该超量怪兽的卡名文本中是否记载了所选速攻魔法的卡名，并且允许以超量召唤方式被特殊召唤。
	return aux.IsCodeListed(c,code) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 确认该怪兽为超量怪兽、场上的「纯爱妖精」可作为其超量素材，且额外怪兽区有空位可以特殊召唤。
		and c:IsType(TYPE_XYZ) and sc:IsCanBeXyzMaterial(c) and Duel.GetLocationCountFromEx(tp,tp,sc,c)>0
end
-- 手卡速攻魔法的过滤条件：该卡未公开，是「纯爱妖精」速攻魔法，可作为超量素材，并且额外卡组中存在记载其卡名的超量怪兽可供特殊召唤。
function s.sptgfilter(c,e,tp)
	return not c:IsPublic() and c:IsType(TYPE_QUICKPLAY) and c:IsSetCard(0x18c) and c:IsCanOverlay()
		-- 确认额外卡组中存在至少1只符合条件（记载该速攻魔法卡名）的超量怪兽，可作为此次特殊召唤的目标。
		and Duel.IsExistingMatchingCard(s.sptgexfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode())
end
-- 效果②的发动条件检查：自己场上的「纯爱妖精」可以成为超量素材，且手卡存在满足条件的「纯爱妖精」速攻魔法。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查「纯爱妖精」没有受到“必须作为超量素材”等限制，确保能作为超量素材。
	if chk==0 then return aux.MustMaterialCheck(e:GetHandler(),tp,EFFECT_MUST_BE_XMATERIAL)
		-- 确认手卡中存在至少1张符合条件的「纯爱妖精」速攻魔法（非公开、可叠放且能对应额外超量怪兽）。
		and Duel.IsExistingMatchingCard(s.sptgfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果包含特殊召唤，目标在额外卡组，数量为1，特殊召唤玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②处理：再次确认素材合法后，从手卡选择1张「纯爱妖精」速攻魔法给对方确认；再从额外卡组选择1只记载该卡名的超量怪兽；把场上的「纯爱妖精」叠放为超量素材，以超量召唤方式特殊召唤该怪兽；若展示的速攻魔法不受本效果影响且可作为超量素材，则也将其叠放为超量素材。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理开始时再次确认「纯爱妖精」可作为超量素材（防止发动后被无效或受到不能作为素材的效果影响）。
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) or c:IsFacedown() or c:IsControler(1-tp) then return end
	-- 显示选择提示，要求玩家选择1张手卡给对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡选择1张符合sptgfilter条件的速攻魔法卡（选择结果将作为后续展示与素材）。
	local g=Duel.SelectMatchingCard(tp,s.sptgfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g<1 then return end
	-- 向对方玩家展示所选的手卡速攻魔法。
	Duel.ConfirmCards(1-tp,g)
	local sc=g:GetFirst()
	-- 显示选择提示，要求玩家选择要特殊召唤的额外卡组超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合sptgexfilter条件的超量怪兽，条件包含其所记载的卡名为所展示速攻魔法的卡名。
	local sg=Duel.SelectMatchingCard(tp,s.sptgexfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,sc:GetCode())
	local tc=sg:GetFirst()
	tc:SetMaterial(Group.FromCards(c))
	-- 将场上的「纯爱妖精」叠放在所选择的超量怪兽下方，作为其超量素材。
	Duel.Overlay(tc,Group.FromCards(c))
	-- 将选择的超量怪兽以超量召唤方式表侧表示特殊召唤到自己的场上（不检查召唤条件/苏生限制），并完成超量召唤手续。
	Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
	-- 如果展示的速攻魔法卡不受此效果影响且可以作为超量素材，则将该速攻魔法也叠放在超量怪兽下方，作为其超量素材。
	if not sc:IsImmuneToEffect(e) and sc:IsCanOverlay() then Duel.Overlay(tc,g) end
end
