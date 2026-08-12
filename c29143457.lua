--炎舞－「隠元」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，以下效果可以适用。
-- ●从自己的手卡·场上把兽战士族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：魔法与陷阱区域的表侧表示的这张卡被送去墓地的场合，以自己墓地1只「炎星」怪兽为对象才能发动。那只怪兽加入手卡。
function c29143457.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，以下效果可以适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,29143457+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c29143457.activate)
	c:RegisterEffect(e1)
	-- ②：魔法与陷阱区域的表侧表示的这张卡被送去墓地的场合，以自己墓地1只「炎星」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29143457,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,29143458)
	e2:SetCondition(c29143457.thcon)
	e2:SetTarget(c29143457.thtg)
	e2:SetOperation(c29143457.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选不受效果影响的卡片
function c29143457.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于筛选满足融合召唤条件的兽战士族融合怪兽
function c29143457.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_BEASTWARRIOR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动时处理效果，检索满足条件的融合怪兽并进行融合召唤
function c29143457.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材卡片组，并过滤掉受效果影响的卡片
	local mg1=Duel.GetFusionMaterial(tp):Filter(c29143457.filter1,nil,e)
	-- 检索满足融合召唤条件的额外卡组中的融合怪兽
	local sg1=Duel.GetMatchingGroup(c29143457.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 根据连锁效果获取额外的融合怪兽
		sg2=Duel.GetMatchingGroup(c29143457.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	-- 判断是否有满足条件的融合怪兽并询问玩家是否进行融合召唤
	if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(29143457,1)) then  --"是否融合召唤？"
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选择的融合怪兽是否来自基础融合素材组
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合怪兽的融合素材（来自连锁效果）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 判断该卡是否从魔法与陷阱区域表侧表示被送去墓地
function c29143457.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤函数，用于筛选「炎星」族的怪兽
function c29143457.thfilter(c)
	return c:IsSetCard(0x79) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标，选择墓地中的「炎星」怪兽
function c29143457.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c29143457.thfilter(chkc) end
	-- 判断是否有满足条件的墓地「炎星」怪兽
	if chk==0 then return Duel.IsExistingTarget(c29143457.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地中的「炎星」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c29143457.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，指定将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果，将目标怪兽加入手牌
function c29143457.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
