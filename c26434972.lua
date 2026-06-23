--刻まれし魔の憐歌
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这个回合中，自己的恶魔族·光属性怪兽不会被战斗破坏，自己受到的战斗伤害变成一半。
-- ②：把墓地的这张卡除外才能发动。自己场上的怪兽作为融合素材，把1只「刻魔」融合怪兽融合召唤。那个时候，「刻魔」怪兽装备的自己的魔法与陷阱区域的当作装备魔法卡使用的融合素材怪兽也能作为融合素材使用。
local s,id,o=GetID()
-- 注册卡牌的两个效果：①永续效果（战斗破坏保护与伤害减半）和②诱发效果（墓地发动融合召唤）
function s.initial_effect(c)
	-- ①：这个回合中，自己的恶魔族·光属性怪兽不会被战斗破坏，自己受到的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不会被战斗破坏"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 效果发动条件：当前处于可以进行战斗相关操作的时点或阶段
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己场上的怪兽作为融合素材，把1只「刻魔」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	-- 效果发动费用：将此卡从墓地除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.fstg)
	e2:SetOperation(s.fsop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 效果发动时点检查：确认此卡在本回合未发动过②效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时点检查：确认此卡在本回合未发动过②效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- 效果处理：为玩家场上的恶魔族·光属性怪兽赋予战斗破坏保护和伤害减半效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：这个回合中，自己的恶魔族·光属性怪兽不会被战斗破坏，自己受到的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.ptfilter)
	e1:SetValue(1)
	-- 将战斗破坏保护效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
	-- ①：这个回合中，自己的恶魔族·光属性怪兽不会被战斗破坏，自己受到的战斗伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(HALF_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将伤害减半效果注册给全局环境
	Duel.RegisterEffect(e2,tp)
	-- 为玩家注册标识效果，防止此卡在本回合再次发动②效果
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数：判断目标怪兽是否为恶魔族·光属性
function s.ptfilter(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND)
end
-- 过滤函数：判断目标装备怪兽是否为刻魔族且处于正面表示
function s.mttg(e,c)
	local tc=c:GetEquipTarget()
	return tc and tc:IsFaceup() and tc:IsSetCard(0x1b0) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 融合召唤限制函数：判断目标融合怪兽是否为该卡的控制者
function s.fuslimit(e,c,sumtype)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
-- 过滤函数：判断目标融合怪兽是否为刻魔族且为融合怪兽
function s.filter(c,e,tp,m,f,chkf)
	return c:IsSetCard(0x1b0) and c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤函数：判断目标卡是否未被该效果免疫
function s.filter2(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 效果发动时点检查：确认是否有满足条件的融合怪兽可特殊召唤
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- ②：把墓地的这张卡除外才能发动。自己场上的怪兽作为融合素材，把1只「刻魔」融合怪兽融合召唤。
		local me=Effect.CreateEffect(e:GetHandler())
		me:SetType(EFFECT_TYPE_FIELD)
		me:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		me:SetTargetRange(LOCATION_SZONE,0)
		me:SetTarget(s.mttg)
		me:SetValue(s.fuslimit)
		-- 将额外融合素材效果注册给全局环境
		Duel.RegisterEffect(me,tp)
		local chkf=tp
		-- 获取玩家当前可用的融合素材组，并过滤掉被免疫的卡
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(s.filter2,nil,e)
		-- 检查是否有满足条件的融合怪兽可特殊召唤
		local res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否有满足条件的融合怪兽可特殊召唤（使用连锁素材）
				res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		me:Reset()
		return res
	end
	-- 设置连锁操作信息：准备特殊召唤一只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：选择并特殊召唤一只融合怪兽
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：把墓地的这张卡除外才能发动。自己场上的怪兽作为融合素材，把1只「刻魔」融合怪兽融合召唤。
	local me=Effect.CreateEffect(e:GetHandler())
	me:SetType(EFFECT_TYPE_FIELD)
	me:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	me:SetTargetRange(LOCATION_SZONE,0)
	me:SetTarget(s.mttg)
	me:SetValue(s.fuslimit)
	-- 将额外融合素材效果注册给全局环境
	Duel.RegisterEffect(me,tp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材组，并过滤掉被免疫的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(s.filter2,nil,e)
	-- 获取满足条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足条件的融合怪兽组（使用连锁素材）
		sg2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用普通融合素材进行召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat1==0 then goto cancel end
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 选择融合召唤所需的素材（使用连锁素材）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			if #mat2==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	me:Reset()
end
