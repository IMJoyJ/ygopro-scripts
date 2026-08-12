--見えざる幽獄
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●自己场上有「不可见之手」怪兽存在的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到手卡。
-- ●自己的场上·墓地的怪兽作为融合素材除外，把1只「不可见之手」融合怪兽融合召唤。把原本持有者是对方的自己场上的表侧表示怪兽作为融合素材的场合，可以当作「不可见之手」怪兽使用。
local s,id,o=GetID()
-- 注册这张卡的发动效果（包含两个可选效果）
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_FUSION_SUMMON|EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤对方场上可以回到手牌的魔法·陷阱卡
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 过滤场上可以作为融合素材除外的卡
function s.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的「不可见之手」融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1d3) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤墓地中可以作为融合素材除外的怪兽
function s.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤原本持有者是对方的自己场上的表侧表示怪兽
function s.ffilter(e,c)
	return c:IsFaceup() and c:GetOwner()==1-e:GetHandlerPlayer()
end
-- 效果发动时的目标选择与合法性检测（处理分支选择、取对象及融合召唤的准备工作）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查对方场上是否存在可以回到手牌的魔法·陷阱卡
	local b1=Duel.IsExistingTarget(s.cfilter,tp,0,LOCATION_ONFIELD,1,nil)
		and (not e:IsCostChecked()
		-- 检查本回合是否尚未选择发动过分支1的效果
		or Duel.GetFlagEffect(tp,id)==0
			-- 检查自己场上是否存在表侧表示的「不可见之手」怪兽
			and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x1d3))
	local chkf=tp
	-- 获取自己场上可用于融合召唤且能被除外的素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取自己墓地中可用于融合召唤且能被除外的怪兽
	local mg2=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- ●自己场上有「不可见之手」怪兽存在的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到手卡。●自己的场上·墓地的怪兽作为融合素材除外，把1只「不可见之手」融合怪兽融合召唤。把原本持有者是对方的自己场上的表侧表示怪兽作为融合素材的场合，可以当作「不可见之手」怪兽使用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ADD_FUSION_SETCODE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ffilter)
	e1:SetValue(0x1d3)
	-- 注册临时领域效果，使原本持有者是对方的自己场上表侧表示怪兽可以当作「不可见之手」怪兽作为融合素材
	Duel.RegisterEffect(e1,tp)
	-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的「不可见之手」融合怪兽
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		-- 获取玩家受到的连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg3=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 检查在连锁素材效果影响下，是否存在可以融合召唤的「不可见之手」融合怪兽
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
		end
	end
	local b2=res
		and (not e:IsCostChecked()
		-- 检查本回合是否尚未选择发动过分支2的效果
		or Duel.GetFlagEffect(tp,id+o)==0)
	e1:Reset()
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择发动其中一个分支效果
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"让魔陷回到手卡"
			{b2,aux.Stringid(id,2),2})  --"融合召唤"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND)
			e:SetProperty(EFFECT_FLAG_FUSION_SUMMON|EFFECT_FLAG_CARD_TARGET)
			-- 注册分支1的回合发动标识，确保同名效果一回合只能选择一次
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 玩家选择对方场上1张魔法·陷阱卡作为效果对象
		local g=Duel.SelectTarget(tp,s.cfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 设置连锁操作信息为：将选中的卡送回手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
			e:SetProperty(EFFECT_FLAG_FUSION_SUMMON)
			-- 注册分支2的回合发动标识，确保同名效果一回合只能选择一次
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置连锁操作信息为：从额外卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 设置连锁操作信息为：将场上或墓地的卡除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	end
end
-- 效果处理函数，根据玩家的选择执行对应的分支效果（弹回魔陷或进行融合召唤）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取作为效果对象的魔法·陷阱卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() then
			-- 将作为对象的卡送回持有者手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	elseif e:GetLabel()==2 then
		-- ●自己的场上·墓地的怪兽作为融合素材除外，把1只「不可见之手」融合怪兽融合召唤。把原本持有者是对方的自己场上的表侧表示怪兽作为融合素材的场合，可以当作「不可见之手」怪兽使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_ADD_FUSION_SETCODE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.ffilter)
		e1:SetValue(0x1d3)
		-- 在融合召唤处理前，注册临时领域效果，使原本持有者是对方的自己场上表侧表示怪兽可以当作「不可见之手」怪兽作为融合素材
		Duel.RegisterEffect(e1,tp)
		local chkf=tp
		-- 获取自己场上可用于融合召唤且能被除外的素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 获取自己墓地中可用于融合召唤且能被除外的怪兽
		local mg2=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 获取额外卡组中可以使用当前素材进行融合召唤的「不可见之手」融合怪兽
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg3=nil
		local sg2=nil
		-- 获取玩家受到的连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg3=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 获取在连锁素材效果影响下，可以融合召唤的「不可见之手」融合怪兽
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要特殊召唤的融合怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断是否使用本卡自身的效果进行融合召唤（而非连锁素材等其他效果）
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 让玩家选择符合条件的融合素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 将选中的融合素材表侧表示除外
				Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果处理，使后续的特殊召唤不与除外同时处理
				Duel.BreakEffect()
				-- 将融合怪兽以融合召唤的方式特殊召唤到场上
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce then
				-- 在连锁素材效果下，让玩家选择符合条件的融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
		e1:Reset()
	end
end
