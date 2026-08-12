--幻奏の歌姫ソプラノ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤时，以「幻奏的歌姬 索普拉诺」以外的自己墓地1只「幻奏」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：1回合1次，自己主要阶段才能发动。包含这张卡的自己场上的怪兽作为融合素材，把1只「幻奏」融合怪兽融合召唤。
function c62895219.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤时，以「幻奏的歌姬 索普拉诺」以外的自己墓地1只「幻奏」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,62895219)
	e1:SetTarget(c62895219.thtg)
	e1:SetOperation(c62895219.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。包含这张卡的自己场上的怪兽作为融合素材，把1只「幻奏」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c62895219.target)
	e2:SetOperation(c62895219.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地「幻奏的歌姬 索普拉诺」以外的可以加入手卡的「幻奏」怪兽
function c62895219.filter(c)
	return c:IsSetCard(0x9b) and c:IsType(TYPE_MONSTER) and not c:IsCode(62895219) and c:IsAbleToHand()
end
-- 效果①的发动准备与目标选择
function c62895219.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c62895219.filter(chkc) end
	-- 检查自己墓地是否存在满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c62895219.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息：选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择并锁定墓地中1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c62895219.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的处理：将选中的怪兽加入手牌
function c62895219.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤条件：场上不受该效果影响的卡
function c62895219.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以用指定素材进行融合召唤的「幻奏」融合怪兽
function c62895219.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9b) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 效果②的发动准备与可行性检查
function c62895219.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取自己场上可用的融合素材怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查额外卡组是否存在可以用场上素材（必须包含这张卡）进行融合召唤的「幻奏」融合怪兽
		local res=Duel.IsExistingMatchingCard(c62895219.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果时，是否存在可融合召唤的「幻奏」融合怪兽
				res=Duel.IsExistingMatchingCard(c62895219.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理：进行融合召唤
function c62895219.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 获取自己场上不受该效果影响的可用融合素材怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c62895219.filter1,nil,e)
	-- 获取额外卡组中当前可用场上素材融合召唤的「幻奏」融合怪兽组合
	local sg1=Duel.GetMatchingGroup(c62895219.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用连锁素材效果时，额外卡组中可融合召唤的「幻奏」融合怪兽组合
		sg2=Duel.GetMatchingGroup(c62895219.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 给玩家发送提示信息：选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（若不使用连锁素材效果或玩家选择不使用）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合素材（必须包含这张卡）
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送墓同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在使用连锁素材效果时，让玩家选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
