--No.27 弩級戦艦－ドレッドノイド
-- 效果：
-- 4星怪兽×2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡战斗破坏对方怪兽的战斗阶段结束时才能发动。把1只10阶以上的机械族超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c8387138.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置4星怪兽2只以上的超量召唤手续
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	-- ①：这张卡战斗破坏对方怪兽的战斗阶段结束时才能发动。把1只10阶以上的机械族超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8387138,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,8387138)
	e1:SetCondition(c8387138.spcon)
	e1:SetTarget(c8387138.sptg)
	e1:SetOperation(c8387138.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡战斗破坏对方怪兽的战斗阶段结束时才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(c8387138.regop)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c8387138.reptg)
	c:RegisterEffect(e3)
end
-- 设置该卡片的No.编号为27
aux.xyz_number[8387138]=27
-- 战斗破坏怪兽时，给自身注册一个在战斗阶段结束前有效的Flag，用于记录战斗破坏过怪兽
function c8387138.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(8387138,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 检查自身是否带有战斗破坏过怪兽的Flag，作为发动条件
function c8387138.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(8387138)~=0
end
-- 过滤额外卡组中满足条件的10阶以上机械族超量怪兽
function c8387138.filter(c,e,tp,mc)
	return c:IsRankAbove(10) and c:IsRace(RACE_MACHINE)
		and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查将自身作为素材时，额外卡组怪兽特殊召唤所需的可用区域是否足够
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果①的发动准备与合法性检查（Target函数）
function c8387138.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身是否受到必须作为特定素材效果的影响
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在至少1只满足条件的机械族超量怪兽
		and Duel.IsExistingMatchingCard(c8387138.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置特殊召唤额外卡组怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的实际处理逻辑（Operation函数）
function c8387138.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e)
		-- 再次检查自身是否受到必须作为特定素材效果的影响
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足条件的机械族超量怪兽
		local g=Duel.SelectMatchingCard(tp,c8387138.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local tc=g:GetFirst()
		if tc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将自身原本持有的超量素材重叠到新召唤的怪兽下面
				Duel.Overlay(tc,mg)
			end
			tc:SetMaterial(Group.FromCards(c))
			-- 将自身重叠到新召唤的怪兽下面作为超量素材
			Duel.Overlay(tc,Group.FromCards(c))
			-- 将选中的超量怪兽以超量召唤的方式特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end
-- 效果②的代替破坏效果的合法性检查（Target函数）
function c8387138.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
