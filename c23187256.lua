--No.93 希望皇ホープ・カイザー
-- 效果：
-- 持有超量素材的相同阶级的「No.」超量怪兽×2只以上
-- ①：1回合1次，自己主要阶段才能发动。把最多有这张卡的超量素材种类数量的9阶以下而攻击力3000以下的「No.」怪兽从额外卡组效果无效特殊召唤（相同阶级最多1只）。那之后，这张卡1个超量素材取除。这个回合，对方受到的战斗伤害变成一半，自己不能把怪兽特殊召唤。
-- ②：只要自己场上有其他的「No.」超量怪兽存在，这张卡不会被战斗·效果破坏。
function c23187256.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加XYZ召唤手续，要求满足mfilter条件的怪兽作为素材，且xyzcheck函数验证素材阶级唯一性，最少需要2个素材，最多99个
	aux.AddXyzProcedureLevelFree(c,c23187256.mfilter,c23187256.xyzcheck,2,99)
	-- ①：1回合1次，自己主要阶段才能发动。把最多有这张卡的超量素材种类数量的9阶以下而攻击力3000以下的「No.」怪兽从额外卡组效果无效特殊召唤（相同阶级最多1只）。那之后，这张卡1个超量素材取除。这个回合，对方受到的战斗伤害变成一半，自己不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23187256,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c23187256.target)
	e2:SetOperation(c23187256.operation)
	c:RegisterEffect(e2)
	-- 只要自己场上有其他的「No.」超量怪兽存在，这张卡不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(c23187256.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
end
-- 设置该卡的超量编号为93
aux.xyz_number[23187256]=93
-- 过滤函数，用于筛选满足XYZ类型、属于No.卡组且拥有超量素材的怪兽
function c23187256.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_XYZ) and c:IsSetCard(0x48) and c:GetOverlayCount()>0
end
-- 检查组内所有怪兽是否具有相同的阶级
function c23187256.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
-- 过滤函数，用于筛选满足阶级不超过9、攻击力不超过3000、属于No.卡组且可以特殊召唤的怪兽
function c23187256.filter(c,e,tp)
	return c:IsRankBelow(9) and c:IsAttackBelow(3000) and c:IsSetCard(0x48)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的判定条件，检查是否满足发动条件
function c23187256.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该卡是否拥有超量素材
	if chk==0 then return e:GetHandler():GetOverlayCount()>0 and Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)>0
		-- 检查额外卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c23187256.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，提示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤函数，用于筛选指定阶级的怪兽
function c23187256.gfilter(c,rank)
	return c:IsRank(rank)
end
-- 效果处理函数，执行特殊召唤和相关效果
function c23187256.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用于特殊召唤额外怪兽的空位数量
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 检测是否受到【青眼精灵龙】效果影响，限制特殊召唤数量
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	if ect~=nil then ft=math.min(ft,ect) end
	local c=e:GetHandler()
	-- 获取满足条件的额外怪兽组
	local g1=Duel.GetMatchingGroup(c23187256.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local ct=c:GetOverlayGroup():GetClassCount(Card.GetCode)
	if ct>ft then ct=ft end
	if g1:GetCount()>0 and ct>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 设置额外筛选条件为阶级唯一性检测函数
		aux.GCheckAdditional=aux.drkcheck
		-- 从满足条件的怪兽组中选择满足条件的子组
		local g2=g1:SelectSubGroup(tp,aux.TRUE,false,1,ct)
		-- 取消额外筛选条件
		aux.GCheckAdditional=nil
		-- 遍历选择的怪兽组
		for tc in aux.Next(g2) do
			-- 将怪兽特殊召唤到场上
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 使被特殊召唤的怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使被特殊召唤的怪兽效果无效（持续到回合结束）
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		-- 中断当前效果处理
		Duel.BreakEffect()
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
	-- 设置对方受到的战斗伤害减半的效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetValue(HALF_DAMAGE)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册战斗伤害减半效果
	Duel.RegisterEffect(e3,tp)
	-- 设置自己不能特殊召唤怪兽的效果
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetTargetRange(1,0)
	-- 注册不能特殊召唤怪兽的效果
	Duel.RegisterEffect(e4,tp)
end
-- 过滤函数，用于筛选场上正面表示的No.超量怪兽
function c23187256.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x48)
end
-- 条件函数，判断是否满足效果发动条件
function c23187256.indcon(e)
	-- 检查场上是否存在满足条件的No.超量怪兽
	return Duel.IsExistingMatchingCard(c23187256.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
