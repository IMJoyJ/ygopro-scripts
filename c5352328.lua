--エクソシスター・ソフィア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有其他的「救祓少女」怪兽存在的场合才能发动。自己抽1张。自己场上有「救祓少女·伊雷娜」存在的场合，再让自己回复800基本分。
-- ②：对方让自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
function c5352328.initial_effect(c)
	-- 注册该卡牌与「救祓少女·伊雷娜」的关联关系
	aux.AddCodeList(c,79858629)
	-- ①：自己场上有其他的「救祓少女」怪兽存在的场合才能发动。自己抽1张。自己场上有「救祓少女·伊雷娜」存在的场合，再让自己回复800基本分。
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
	-- ②：对方让自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
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
-- 过滤函数，用于判断场上是否存在其他「救祓少女」怪兽
function c5352328.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x172)
end
-- 效果①的发动条件：检查自己场上是否存在其他「救祓少女」怪兽
function c5352328.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在其他「救祓少女」怪兽
	return Duel.IsExistingMatchingCard(c5352328.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果①的发动时点处理：判断玩家是否可以抽卡并设置抽卡目标
function c5352328.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1（表示抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 过滤函数，用于判断场上是否存在「救祓少女·伊雷娜」
function c5352328.cfilter1(c)
	return c:IsFaceup() and c:IsCode(79858629)
end
-- 效果①的处理流程：先抽卡再判断是否回复LP
function c5352328.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作并判断是否成功抽到卡
	if Duel.Draw(p,d,REASON_EFFECT)>0
		-- 检查自己场上是否存在「救祓少女·伊雷娜」
		and Duel.IsExistingMatchingCard(c5352328.cfilter1,tp,LOCATION_ONFIELD,0,1,nil) then
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 让玩家回复800基本分
		Duel.Recover(tp,800,REASON_EFFECT)
	end
end
-- 效果②的发动条件：判断对方是否让自己或对方的卡从墓地离开
function c5352328.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤函数，用于筛选可作为超量素材的「救祓少女」超量怪兽
function c5352328.spfilter(c,e,tp,mc)
	return c:IsSetCard(0x172) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检查目标怪兽是否可以被特殊召唤且场上是否有足够的位置
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的发动时点处理：判断是否满足特殊召唤条件
function c5352328.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测该卡是否满足作为超量素材的条件
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组中是否存在符合条件的「救祓少女」超量怪兽
		and Duel.IsExistingMatchingCard(c5352328.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置连锁操作信息为特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理流程：选择并特殊召唤符合条件的超量怪兽
function c5352328.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测该卡是否满足作为超量素材的条件
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组中选择一只符合条件的「救祓少女」超量怪兽
		local g=Duel.SelectMatchingCard(tp,c5352328.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将原卡上的叠放卡叠放到目标怪兽上
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将原卡叠放到目标怪兽上
			Duel.Overlay(sc,Group.FromCards(c))
			-- 以超量召唤方式将目标怪兽特殊召唤到场上
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
