--エクソシスター・イレーヌ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡让1张「救祓少女」卡回到卡组最下面才能发动。自己抽1张。自己场上有「救祓少女·索菲娅」存在的场合，再让自己回复800基本分。
-- ②：对方让自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
function c79858629.initial_effect(c)
	-- 注册卡片关联代码，表示这张卡的效果中记载了「救祓少女·索菲娅」
	aux.AddCodeList(c,5352328)
	-- ①：从手卡让1张「救祓少女」卡回到卡组最下面才能发动。自己抽1张。自己场上有「救祓少女·索菲娅」存在的场合，再让自己回复800基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79858629,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,79858629)
	e1:SetCost(c79858629.effcost)
	e1:SetTarget(c79858629.efftg)
	e1:SetOperation(c79858629.effop)
	c:RegisterEffect(e1)
	-- ②：对方让自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79858629,1))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,79858630)
	e2:SetCondition(c79858629.spcon)
	e2:SetTarget(c79858629.sptg)
	e2:SetOperation(c79858629.spop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可以作为发动代价返回卡组的「救祓少女」卡片
function c79858629.costfilter(c)
	return c:IsSetCard(0x172) and c:IsAbleToDeckAsCost()
end
-- 效果①的发动代价处理函数
function c79858629.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以作为发动代价返回卡组的「救祓少女」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c79858629.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手牌选择1张满足条件的「救祓少女」卡
	local g=Duel.SelectMatchingCard(tp,c79858629.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 给对方玩家确认选择的卡片
	Duel.ConfirmCards(1-tp,g)
	-- 将选择的卡作为发动代价送回持有者卡组的最下方
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 效果①的发动目标处理函数
function c79858629.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前效果处理的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前效果处理的目标参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为“自己抽1张卡”
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 过滤场上表侧表示存在的「救祓少女·索菲娅」
function c79858629.cfilter(c)
	return c:IsFaceup() and c:IsCode(5352328)
end
-- 效果①的效果处理函数
function c79858629.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡处理，若成功抽卡则继续判断
	if Duel.Draw(p,d,REASON_EFFECT)>0
		-- 检查自己场上是否存在表侧表示的「救祓少女·索菲娅」
		and Duel.IsExistingMatchingCard(c79858629.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		-- 中断当前效果处理，使后续的回复生命值处理与抽卡不视为同时进行
		Duel.BreakEffect()
		-- 让自己回复800基本分
		Duel.Recover(tp,800,REASON_EFFECT)
	end
end
-- 效果②的发动条件函数，判断是否为对方玩家的操作导致卡片离开墓地
function c79858629.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤额外卡组中可以以当前怪兽为素材进行超量召唤特殊召唤的「救祓少女」超量怪兽
function c79858629.spfilter(c,e,tp,mc)
	return c:IsSetCard(0x172) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检查该超量怪兽是否可以被特殊召唤，以及额外怪兽区域或可用怪兽区域是否有足够的空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的发动目标处理函数
function c79858629.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否存在必须作为超量素材的限制
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在可以重叠在自身上方进行超量召唤的「救祓少女」超量怪兽
		and Duel.IsExistingMatchingCard(c79858629.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置当前连锁的操作信息为“从额外卡组特殊召唤1只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理函数
function c79858629.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查是否存在必须作为超量素材的限制，若不满足则结束处理
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足条件的「救祓少女」超量怪兽
		local g=Duel.SelectMatchingCard(tp,c79858629.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将这张卡原本持有的超量素材转移给新特殊召唤的超量怪兽
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将这张卡重叠作为新特殊召唤的超量怪兽的超量素材
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将该超量怪兽以表侧表示特殊召唤（当作超量召唤）
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
