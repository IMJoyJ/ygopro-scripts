--No.69 紋章神コート・オブ・アームズ－ゴッド・シャーター
-- 效果：
-- 4星怪兽×4
-- 这张卡也能在原本卡名是「No.69 纹章神 盾徽」的自己场上的怪兽上面重叠来超量召唤。这个卡名的效果1回合只能使用1次。
-- ①：对方场上的怪兽把效果发动时或者对方怪兽的攻击宣言时才能发动。把1只「No.69 纹章神 盾徽-神之愤怒」在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。那之后，那1只对方怪兽破坏。
local s,id,o=GetID()
-- 初始化效果函数，注册卡名代码列表、添加超量召唤手续、启用复活限制并创建攻击宣言时触发的效果和连锁时触发的效果
function s.initial_effect(c)
	-- 记录该卡上记载着「No.69 纹章神 盾徽」和「No.69 纹章神 盾徽-神之愤怒」的卡名
	aux.AddCodeList(c,2407234,77571454)
	aux.AddXyzProcedure(c,nil,4,4,s.ovfilter,aux.Stringid(id,0))  --"是否在「No.69 纹章神 盾徽」上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：对方场上的怪兽把效果发动时或者对方怪兽的攻击宣言时才能发动。
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
-- 设置该卡的超量编号为69
aux.xyz_number[id]=69
-- 判断是否在「No.69 纹章神 盾徽」上面重叠来超量召唤
function s.ovfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(2407234)
end
-- 攻击宣言时触发效果的条件函数，检查攻击怪兽是否在场上
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否在场上
	if not Duel.GetAttacker():IsOnField() then return false end
	-- 将攻击怪兽设置为效果标签对象
	e:SetLabelObject(Duel.GetAttacker())
	-- 检查攻击怪兽是否为对方控制
	return Duel.GetAttacker():GetControler()~=tp
end
-- 筛选可特殊召唤的「No.69 纹章神 盾徽-神之愤怒」卡片
function s.spfilter(c,e,tp,mc)
	return c:IsCode(77571454) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否可以被特殊召唤且有足够召唤位置
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置特殊召唤和破坏的处理目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ac=e:GetLabelObject()
	-- 检查是否满足超量素材条件
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置破坏的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ac,1,0,0)
end
-- 执行特殊召唤和破坏效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=e:GetLabelObject()
	-- 检查是否满足超量素材条件
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将原卡的叠放卡叠放到新召唤的怪兽上
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将原卡叠放到新召唤的怪兽上
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将怪兽特殊召唤到场上
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
		if ac:IsRelateToBattle() and ac:IsControler(1-tp) and ac:IsType(TYPE_MONSTER) then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 破坏攻击怪兽
			Duel.Destroy(ac,REASON_EFFECT)
		end
	end
end
-- 连锁发动时触发效果的条件函数
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep==1-tp and re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
end
-- 设置特殊召唤和破坏的处理目标
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足超量素材条件
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置破坏的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 执行特殊召唤和破坏效果
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否满足超量素材条件
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将原卡的叠放卡叠放到新召唤的怪兽上
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将原卡叠放到新召唤的怪兽上
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将怪兽特殊召唤到场上
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
		if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsFaceup() and re:GetHandler():IsControler(1-tp) then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 破坏对方发动效果的怪兽
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
