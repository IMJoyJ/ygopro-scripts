--エクソシスター・ソフィア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有其他的「救祓少女」怪兽存在的场合才能发动。自己抽1张。自己场上有「救祓少女·伊雷娜」存在的场合，再让自己回复800基本分。
-- ②：对方让自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
function c5352328.initial_effect(c)
	-- 记录本卡效果文中记载着「救祓少女·伊雷娜」（79858629），使涉及“记载卡名”的规则判定生效。
	aux.AddCodeList(c,79858629)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上有其他的「救祓少女」怪兽存在的场合才能发动。自己抽1张。自己场上有「救祓少女·伊雷娜」存在的场合，再让自己回复800基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5352328,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,5352328)
	e1:SetCondition(c5352328.effcon)
	e1:SetTarget(c5352328.efftg)
	e1:SetOperation(c5352328.effop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：对方让自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5352328,1))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,5352329)
	e2:SetCondition(c5352328.spcon)
	e2:SetTarget(c5352328.sptg)
	e2:SetOperation(c5352328.spop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数：判断怪兽是否表侧表示且属于「救祓少女」系列（0x172），用于检索自己场上的其他救祓少女怪兽。
function c5352328.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x172)
end
-- ①效果的发动条件：自己场上存在1只其他表侧表示的「救祓少女」怪兽时才能发动。
function c5352328.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（LOCATION_MZONE）是否存在至少1张满足 cfilter 且不是本卡的表侧「救祓少女」怪兽。
	return Duel.IsExistingMatchingCard(c5352328.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- ①效果的发动目标处理：确认自己可以抽1张卡，将目标玩家设为自己、抽卡数设为1，并登记抽卡操作信息。
function c5352328.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查（chk==0）时，确认自己可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的效果对象玩家设为自己（tp），即抽卡的玩家是自己。
	Duel.SetTargetPlayer(tp)
	-- 设置效果对象参数为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记效果操作信息：类别为抽卡（CATEGORY_DRAW），由玩家tp抽1张卡（处理时具体数量目标未知，目标暂设为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义过滤函数：判断怪兽是否表侧表示且卡号为79858629（「救祓少女·伊雷娜」），用于检查场上是否存在伊雷娜。
function c5352328.cfilter1(c)
	return c:IsFaceup() and c:IsCode(79858629)
end
-- ①效果的解决处理：从连锁信息中取出目标玩家和抽卡数，执行抽卡；若抽卡成功且自己场上有表侧表示的「救祓少女·伊雷娜」，则中断处理并让自己回复800基本分。
function c5352328.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的目标玩家和目标参数，即之前设定的抽卡玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p抽d张卡，并判断是否实际抽到了卡（>0）。
	if Duel.Draw(p,d,REASON_EFFECT)>0
		-- 并且自己场上存在表侧表示的「救祓少女·伊雷娜」（cfilter1，场上任意表侧区域）时，满足后续条件。
		and Duel.IsExistingMatchingCard(c5352328.cfilter1,tp,LOCATION_ONFIELD,0,1,nil) then
		-- 中断当前效果处理，使后续回复LP作为独立处理进行，避免错过时点。
		Duel.BreakEffect()
		-- 以效果原因让自己（tp）回复800基本分。
		Duel.Recover(tp,800,REASON_EFFECT)
	end
end
-- ②效果的触发条件：对方（rp为对方玩家）让自己或对方的卡从墓地离开的场合。
function c5352328.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 定义可特殊召唤的「救祓少女」超量怪兽的过滤条件：属于该系列的超量怪兽，能以此卡（mc）为超量素材，可进行超量召唤特殊召唤，且额外卡组怪兽有可用的特殊召唤区域。
function c5352328.spfilter(c,e,tp,mc)
	return c:IsSetCard(0x172) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 候选怪兽必须能由自己以超量召唤方式特殊召唤，并且在让此卡（mc）离场后仍有额外卡组怪兽可用的区域。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ②效果的发动目标处理：确认此卡可作为超量素材且额外卡组存在符合条件的「救祓少女」超量怪兽，并登记特殊召唤操作信息。
function c5352328.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动合法性检查阶段，确认此卡未受“必须作为超量素材”限制，可作为超量素材。
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 并且额外卡组中存在满足 spfilter 条件的「救祓少女」超量怪兽。
		and Duel.IsExistingMatchingCard(c5352328.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 登记效果操作信息：类别为特殊召唤（CATEGORY_SPECIAL_SUMMON），从额外卡组特殊召唤1只怪兽（具体目标处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的解决处理：确认此卡仍可作为素材后，选择1只符合条件的「救祓少女」超量怪兽，将此卡及其原有超量素材转移给该怪兽，在其上面重叠当作超量召唤特殊召唤，并完成超量召唤手续。
function c5352328.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认此卡未受“必须作为超量素材”限制，否则不进行处理。
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 向自己发送选择要特殊召唤的卡片的提示（HINTMSG_SPSUMMON）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足 spfilter 条件的「救祓少女」超量怪兽。
		local g=Duel.SelectMatchingCard(tp,c5352328.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 把此卡原本持有的超量素材（mg）全部叠放到选中的超量怪兽下面。
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 把此卡自身作为超量素材叠放到选中的超量怪兽下面，实现“在此卡上面重叠”的效果。
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将选中的超量怪兽以超量召唤方式表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
