--覇王眷竜ダーク・リベリオン
-- 效果：
-- 暗属性4星灵摆怪兽×2
-- ①：1回合1次，这张卡和对方怪兽进行战斗的伤害计算前，把这张卡1个超量素材取除才能发动。直到回合结束时，那只对方怪兽的攻击力变成0，这张卡的攻击力上升那个原本攻击力数值。
-- ②：自己·对方的战斗阶段，让这张卡回到额外卡组才能发动。从自己的额外卡组（表侧）把「霸王眷龙」灵摆怪兽或「霸王门」灵摆怪兽合计最多2只守备表示特殊召唤。
function c42160203.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加XYZ召唤手续，要求满足条件的怪兽等级为4，需要2只怪兽进行叠放
	aux.AddXyzProcedure(c,c42160203.matfilter,4,2)
	-- ①：1回合1次，这张卡和对方怪兽进行战斗的伤害计算前，把这张卡1个超量素材取除才能发动。直到回合结束时，那只对方怪兽的攻击力变成0，这张卡的攻击力上升那个原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42160203,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCountLimit(1)
	e1:SetCondition(c42160203.atkcon)
	e1:SetCost(c42160203.atkcost)
	e1:SetOperation(c42160203.atkop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段，让这张卡回到额外卡组才能发动。从自己的额外卡组（表侧）把「霸王眷龙」灵摆怪兽或「霸王门」灵摆怪兽合计最多2只守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(42160203,1))  --"回到卡组并特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_BATTLE_START)
	e4:SetCondition(c42160203.spcon)
	e4:SetCost(c42160203.spcost)
	e4:SetTarget(c42160203.sptg)
	e4:SetOperation(c42160203.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断用于XYZ召唤的怪兽是否为灵摆怪兽且属性为暗
function c42160203.matfilter(c)
	return c:IsXyzType(TYPE_PENDULUM) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 判断效果发动条件，确保自身和对方怪兽都处于战斗状态且对方怪兽攻击力大于0
function c42160203.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:GetAttack()>0
end
-- 支付效果代价，检查并移除自身1个超量素材作为代价
function c42160203.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 执行效果操作，将对方怪兽攻击力设为0，并使自身攻击力上升对方怪兽原本攻击力数值
function c42160203.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc:IsFaceup() and tc:IsRelateToBattle() and not tc:IsImmuneToEffect(e) then
		local atk=tc:GetBaseAttack()
		-- 将对方怪兽的攻击力设为0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 使自身攻击力上升对方怪兽原本攻击力数值
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e2:SetValue(atk)
			c:RegisterEffect(e2)
		end
	end
end
-- 判断效果发动条件，确保当前处于战斗阶段
function c42160203.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段在战斗阶段开始到战斗阶段结束之间
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- 支付效果代价，将自身送入额外卡组作为代价
function c42160203.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	-- 将自身送入额外卡组
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
-- 过滤函数，用于筛选可特殊召唤的「霸王眷龙」或「霸王门」灵摆怪兽
function c42160203.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10f8,0x20f8)
		and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果目标，检查是否有满足条件的怪兽可特殊召唤
function c42160203.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否有可用召唤位置
	if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),TYPE_PENDULUM)>0
		-- 检查额外卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c42160203.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行效果操作，选择并特殊召唤满足条件的怪兽
function c42160203.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中可用于特殊召唤的空位数量
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	if ft==0 then return end
	ft=math.min(ft,2)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		ft=1
	end
	-- 检测是否受到【青眼精灵龙】效果影响，限制同时特殊召唤数量
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	if ect~=nil then ft=math.min(ft,ect) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c42160203.spfilter,tp,LOCATION_EXTRA,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
