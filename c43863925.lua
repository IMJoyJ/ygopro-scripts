--エクソシスター・ステラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只「救祓少女」怪兽特殊召唤。那之后，自己场上有「救祓少女·埃莉丝」存在的场合，自己回复800基本分。
-- ②：对方让自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
function c43863925.initial_effect(c)
	-- 记录此卡与「救祓少女·埃莉丝」的关联，用于效果判定
	aux.AddCodeList(c,16474916)
	-- ①：自己主要阶段才能发动。从手卡把1只「救祓少女」怪兽特殊召唤。那之后，自己场上有「救祓少女·埃莉丝」存在的场合，自己回复800基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43863925,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,43863925)
	e1:SetTarget(c43863925.efftg)
	e1:SetOperation(c43863925.effop)
	c:RegisterEffect(e1)
	-- ②：对方让自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43863925,1))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,43863926)
	e2:SetCondition(c43863925.spcon)
	e2:SetTarget(c43863925.sptg)
	e2:SetOperation(c43863925.spop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可特殊召唤的「救祓少女」怪兽
function c43863925.effspfilter(c,e,tp)
	return c:IsSetCard(0x172) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足①效果的发动条件
function c43863925.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在满足条件的「救祓少女」怪兽
		and Duel.IsExistingMatchingCard(c43863925.effspfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡的提示信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤场上是否存在「救祓少女·埃莉丝」
function c43863925.cfilter(c)
	return c:IsFaceup() and c:IsCode(16474916)
end
-- 处理①效果的发动，选择并特殊召唤手牌中的怪兽，若场上存在「救祓少女·埃莉丝」则回复LP
function c43863925.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的手牌怪兽
	local g=Duel.SelectMatchingCard(tp,c43863925.effspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的怪兽特殊召唤到场上
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断场上是否存在「救祓少女·埃莉丝」
		and Duel.IsExistingMatchingCard(c43863925.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 使玩家回复800基本分
		Duel.Recover(tp,800,REASON_EFFECT)
	end
end
-- 判断对方让卡离开墓地的玩家是否为己方
function c43863925.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤额外卡组中可作为超量怪兽特殊召唤的「救祓少女」怪兽
function c43863925.spfilter(c,e,tp,mc)
	return c:IsSetCard(0x172) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 判断该超量怪兽是否可特殊召唤且有足够区域
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 判断是否满足②效果的发动条件
function c43863925.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查此卡是否满足作为超量素材的条件
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 判断额外卡组中是否存在满足条件的超量怪兽
		and Duel.IsExistingMatchingCard(c43863925.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置效果处理时将要特殊召唤的卡的提示信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理②效果的发动，选择并特殊召唤额外卡组中的超量怪兽
function c43863925.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否满足作为超量素材的条件
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的额外卡组超量怪兽
		local g=Duel.SelectMatchingCard(tp,c43863925.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将此卡的叠放卡叠放到目标超量怪兽上
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将此卡叠放到目标超量怪兽上
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将目标超量怪兽特殊召唤到场上
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
