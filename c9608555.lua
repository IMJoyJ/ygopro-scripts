--転生炎獣ブレイズ・ドラゴン
-- 效果：
-- 4星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡被战斗·效果破坏的场合，作为代替把这张卡1个超量素材取除。
-- ②：这张卡没有超量素材的场合，自己·对方的战斗阶段才能发动。把1只「转生炎兽」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
-- ③：这张卡用「转生炎兽 烈焰龙」为素材作超量召唤成功的场合才能发动。选对方场上1只怪兽破坏。
function c9608555.initial_effect(c)
	-- 添加超量召唤手续：4星怪兽×2。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡被战斗·效果破坏的场合，作为代替把这张卡1个超量素材取除。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c9608555.reptg)
	c:RegisterEffect(e1)
	-- ②：这张卡没有超量素材的场合，自己·对方的战斗阶段才能发动。把1只「转生炎兽」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9608555,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,9608555)
	e2:SetCondition(c9608555.spcon)
	e2:SetTarget(c9608555.sptg)
	e2:SetOperation(c9608555.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡用「转生炎兽 烈焰龙」为素材作超量召唤成功的场合才能发动。选对方场上1只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9608555,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c9608555.descon)
	e3:SetTarget(c9608555.destg)
	e3:SetOperation(c9608555.desop)
	c:RegisterEffect(e3)
	-- ③：这张卡用「转生炎兽 烈焰龙」为素材作超量召唤成功的场合才能发动。（素材检查）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c9608555.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 代替破坏效果的检测与处理函数：检查自身是否因战斗或效果破坏，并尝试通过取除1个超量素材来代替破坏。
function c9608555.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	return true
end
-- 特殊召唤效果的发动条件：自身没有超量素材，且当前处于自己或对方的战斗阶段。
function c9608555.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return e:GetHandler():GetOverlayCount()==0 and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤额外卡组中可以重叠超量召唤的「转生炎兽」超量怪兽。
function c9608555.spfilter(c,e,tp,mc)
	return c:IsSetCard(0x119) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检查目标怪兽是否可以当作超量召唤特殊召唤，且额外怪兽区域或有连接端指向的区域有足够的空位。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 特殊召唤效果的发动准备（Target函数）：检查是否有必须作为素材的限制，以及额外卡组是否存在可特殊召唤的怪兽。
function c9608555.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查在进行超量召唤时，场上是否存在必须作为素材的卡片限制。
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在至少1只满足条件的「转生炎兽」超量怪兽。
		and Duel.IsExistingMatchingCard(c9608555.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置连锁运营信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤效果的执行函数：将额外卡组的「转生炎兽」超量怪兽重叠在自身上方当作超量召唤特殊召唤，并继承素材。
function c9608555.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次检查必须作为超量素材的限制。
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足条件的「转生炎兽」超量怪兽。
		local g=Duel.SelectMatchingCard(tp,c9608555.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将这张卡原本持有的超量素材转移重叠到新特殊召唤的怪兽下面。
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将这张卡自身作为超量素材重叠在新特殊召唤的怪兽下面。
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将目标怪兽以表侧表示当作超量召唤特殊召唤到场上。
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
-- 破坏效果的发动条件：这张卡超量召唤成功，且使用了「转生炎兽 烈焰龙」作为素材。
function c9608555.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 破坏效果的发动准备（Target函数）：检查对方场上是否存在怪兽，并设置破坏的操作信息。
function c9608555.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁运营信息：破坏对方场上的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行函数：选对方场上1只怪兽破坏。
function c9608555.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上的1只怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 选中目标怪兽并向双方玩家展示（显示选中光晕）。
		Duel.HintSelection(g)
		-- 因效果破坏选中的怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 素材检查函数：检查超量召唤的素材中是否包含「转生炎兽 烈焰龙」，并为效果3设置对应的标记值。
function c9608555.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsCode,1,nil,9608555) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
