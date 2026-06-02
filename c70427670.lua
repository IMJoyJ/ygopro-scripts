--捕食植物ブフォリキュラ
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只暗属性融合怪兽融合召唤。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡成为融合召唤的素材，被送去墓地的场合或者表侧加入额外卡组的场合才能发动。从自己的额外卡组（表侧）把「捕食植物 土瓶草蟾蜍」以外的1只暗属性灵摆怪兽加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果
function c70427670.initial_effect(c)
	-- 注册灵摆怪兽属性及效果
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只暗属性融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70427670,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,70427670)
	e1:SetTarget(c70427670.fustg)
	e1:SetOperation(c70427670.fusop)
	c:RegisterEffect(e1)
	-- ①：这张卡成为融合召唤的素材，被送去墓地的场合或者表侧加入额外卡组的场合才能发动。从自己的额外卡组（表侧）把「捕食植物 土瓶草蟾蜍」以外的1只暗属性灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70427670,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,70427670+o)
	e2:SetCondition(c70427670.thcon)
	e2:SetTarget(c70427670.thtg)
	e2:SetOperation(c70427670.thop)
	c:RegisterEffect(e2)
end
-- 过滤不受当前效果影响的融合素材怪兽
function c70427670.fusfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤可进行融合召唤的暗属性融合怪兽
function c70427670.fusfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 灵摆效果①的发动检测与效果目标声明
function c70427670.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己手卡·场上可用的融合素材怪兽组
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查自己额外卡组是否存在可以融合召唤的暗属性融合怪兽
		local res=Duel.IsExistingMatchingCard(c70427670.fusfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前受其他连锁素材效果影响的融合素材
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果影响下额外卡组是否存在可以融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c70427670.fusfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理时融合特殊召唤额外卡组怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 灵摆效果①的效果处理：融合召唤暗属性融合怪兽
function c70427670.fusop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取并过滤自己可作为该融合效果素材的怪兽组
	local mg1=Duel.GetFusionMaterial(tp):Filter(c70427670.fusfilter1,nil,e)
	-- 获取额外卡组中可以通过常规素材进行融合召唤的暗属性融合怪兽
	local sg1=Duel.GetMatchingGroup(c70427670.fusfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取是否存在连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下可以通过其他素材融合召唤的暗属性融合怪兽
		sg2=Duel.GetMatchingGroup(c70427670.fusfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的一组常规融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使特殊召唤与送墓视为不同时处理
			Duel.BreakEffect()
			-- 以融合召唤表侧表示特殊召唤该融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择使用连锁素材效果进行融合召唤的素材组
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 判断这张卡是否作为融合素材送去墓地或表侧加入额外卡组
function c70427670.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup() and c:IsLocation(LOCATION_EXTRA)) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤自己额外卡组中表侧表示且非同名的暗属性灵摆怪兽
function c70427670.thfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_PENDULUM) and not c:IsCode(70427670) and c:IsAbleToHand()
end
-- 怪兽效果①的发动检测与效果目标声明
function c70427670.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在符合检索条件的表侧表示暗属性灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c70427670.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置效果处理时将额外卡组表侧怪兽加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果①的效果处理：从额外卡组将暗属性灵摆怪兽加入手牌
function c70427670.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1只符合检索条件的额外表侧表示灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c70427670.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选取的怪兽因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
