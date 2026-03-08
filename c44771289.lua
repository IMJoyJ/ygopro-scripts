--旅人の結彼岸
-- 效果：
-- ①：从自己的手卡·场上把「彼岸」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以场上1只「彼岸」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到下次的对方回合结束时上升800。这个效果在这张卡送去墓地的回合不能发动。
function c44771289.initial_effect(c)
	-- ①：从自己的手卡·场上把「彼岸」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44771289,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c44771289.target)
	e1:SetOperation(c44771289.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以场上1只「彼岸」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到下次的对方回合结束时上升800。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44771289,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 效果发动的条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 效果发动的费用：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44771289.atktg)
	e2:SetOperation(c44771289.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否免疫当前效果
function c44771289.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：判断怪兽是否为融合族、彼岸卡组、可特殊召唤、且满足融合素材条件
function c44771289.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xb1) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果的发动判断：检查是否存在满足条件的融合怪兽
function c44771289.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查是否存在满足融合条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c44771289.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c44771289.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息：准备特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果的处理函数：执行融合召唤流程
function c44771289.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 过滤融合素材，排除免疫效果的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c44771289.filter1,nil,e)
	-- 获取满足融合条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c44771289.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁融合条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c44771289.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
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
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合怪兽的连锁融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数：判断怪兽是否为正面表示且为彼岸卡组
function c44771289.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb1)
end
-- 效果的发动判断：选择目标怪兽
function c44771289.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c44771289.atkfilter(chkc) end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c44771289.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c44771289.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果的处理函数：提升目标怪兽的攻击力与守备力
function c44771289.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为对象怪兽增加攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
