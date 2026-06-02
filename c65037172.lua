--サイバース・セイジ
-- 效果：
-- 「电脑网仪式」降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从自己的场上·墓地把融合怪兽卡决定的包含电子界族怪兽的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。
-- ②：这张卡作为同调素材送去墓地的场合，以自己墓地1只电子界族怪兽或者1张仪式魔法卡为对象才能发动。那张卡加入手卡。
function c65037172.initial_effect(c)
	aux.AddCodeList(c,34767865)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。从自己的场上·墓地把融合怪兽卡决定的包含电子界族怪兽的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65037172,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,65037172)
	e1:SetTarget(c65037172.fsptg)
	e1:SetOperation(c65037172.fspop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为同调素材送去墓地的场合，以自己墓地1只电子界族怪兽或者1张仪式魔法卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,65037173)
	e2:SetCondition(c65037172.thcon)
	e2:SetTarget(c65037172.thtg)
	e2:SetOperation(c65037172.thop)
	c:RegisterEffect(e2)
end
-- 过滤场上可以被除外且不受效果影响的融合素材怪兽
function c65037172.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的融合怪兽
function c65037172.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤墓地中可以作为融合素材且能被除外的怪兽卡
function c65037172.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 检查融合素材中是否包含至少1只电子界族怪兽
function c65037172.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsRace,1,nil,RACE_CYBERSE)
end
-- 效果①的发动准备与可行性检查，设置特殊召唤和除外的操作信息
function c65037172.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取场上可用的融合素材怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(c65037172.filter1,nil,e)
		-- 获取自己墓地中可作为融合素材除外的怪兽
		local mg2=Duel.GetMatchingGroup(c65037172.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 设定融合素材的额外检查条件（必须包含电子界族怪兽）
		aux.FCheckAdditional=c65037172.fcheck
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c65037172.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果适用下，额外卡组是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c65037172.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		-- 清空融合素材的额外检查条件
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置除外的操作信息（从场上或墓地除外卡片）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果①的处理：选择1只融合怪兽，将场上·墓地的融合素材除外，并从额外卡组融合召唤该怪兽
function c65037172.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取场上可用的融合素材怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c65037172.filter1,nil,e)
	-- 获取自己墓地中可作为融合素材除外的怪兽
	local mg2=Duel.GetMatchingGroup(c65037172.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 设定融合素材的额外检查条件（必须包含电子界族怪兽）
	aux.FCheckAdditional=c65037172.fcheck
	-- 筛选出额外卡组中可以使用当前素材融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(c65037172.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 筛选出在连锁素材效果适用下可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c65037172.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡的效果进行融合召唤（而非连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择一组满足条件的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材因效果·素材·融合原因表侧表示除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与除外同时处理
			Duel.BreakEffect()
			-- 将选定的融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果适用下，让玩家选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清空融合素材的额外检查条件
	aux.FCheckAdditional=nil
end
-- 检查这张卡是否作为同调素材送去墓地
function c65037172.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤墓地中的电子界族怪兽或仪式魔法卡
function c65037172.thfilter(c)
	local b1=c:IsRace(RACE_CYBERSE)
	local b2=c:GetType()==TYPE_SPELL+TYPE_RITUAL
	return (b1 or b2) and c:IsAbleToHand()
end
-- 效果②的发动准备，确认并选择墓地中的1只电子界族怪兽或1张仪式魔法卡作为对象，设置加入手卡的操作信息
function c65037172.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c65037172.thfilter(chkc) end
	-- 检查自己墓地是否存在满足条件的卡作为对象
	if chk==0 then return Duel.IsExistingTarget(c65037172.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地中的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,c65037172.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将选定对象加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理：将作为对象的卡加入手卡
function c65037172.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的发动对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
