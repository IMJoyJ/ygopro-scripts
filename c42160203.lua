--覇王眷竜ダーク・リベリオン
-- 效果：
-- 暗属性4星灵摆怪兽×2
-- ①：1回合1次，这张卡和对方怪兽进行战斗的伤害计算前，把这张卡1个超量素材取除才能发动。直到回合结束时，那只对方怪兽的攻击力变成0，这张卡的攻击力上升那个原本攻击力数值。
-- ②：自己·对方的战斗阶段，让这张卡回到额外卡组才能发动。从自己的额外卡组（表侧）把「霸王眷龙」灵摆怪兽或「霸王门」灵摆怪兽合计最多2只守备表示特殊召唤。
function c42160203.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：以2只暗属性灵摆·4星怪兽为素材进行超量召唤。
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
-- 定义超量素材过滤器：素材必须是暗属性且为灵摆怪兽（可用作超量素材）。
function c42160203.matfilter(c)
	return c:IsXyzType(TYPE_PENDULUM) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果①的发动条件：这张卡与对方怪兽进行战斗且双方与战斗相关，对方怪兽表侧表示且攻击力大于0。
function c42160203.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:GetAttack()>0
end
-- 效果①的发动代价：取除这张卡的1个超量素材。
function c42160203.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①处理：将战斗对象的攻击力变成0，然后使这张卡的攻击力上升该对象原本攻击力的数值，直到回合结束。
function c42160203.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc:IsFaceup() and tc:IsRelateToBattle() and not tc:IsImmuneToEffect(e) then
		local atk=tc:GetBaseAttack()
		-- 那只对方怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 这张卡的攻击力上升那个原本攻击力数值。
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
-- 效果②的发动条件：当前阶段处于战斗阶段（从战斗阶段开始到战斗阶段结束）。
function c42160203.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否在战斗阶段开始和战斗阶段结束之间。
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- 效果②的发动代价：将这张卡返回额外卡组。
function c42160203.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	-- 以代价方式将这张卡送回持有者的额外卡组。
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
-- 定义特殊召唤对象过滤器：选择额外卡组表侧存在的「霸王眷龙」或「霸王门」灵摆怪兽，且可以表侧守备表示特殊召唤。
function c42160203.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10f8,0x20f8)
		and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动目标条件：额外卡组区域有空位，且额外卡组存在至少1只符合条件的表侧灵摆怪兽。
function c42160203.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查从额外卡组特殊召唤是否有可用区域（空格数大于0）。
	if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),TYPE_PENDULUM)>0
		-- 检查自己的额外卡组是否存在至少1张满足条件的灵摆怪兽。
		and Duel.IsExistingMatchingCard(c42160203.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 登记本次操作含有特殊召唤效果，预定从额外卡组特殊召唤1只怪兽（实际数量处理时根据限制调整）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②处理：计算可特殊召唤数量（受额外卡组区域空格、青眼精灵龙和召唤之门限制），然后从额外卡组选择符合条件的灵摆怪兽，以表侧守备表示特殊召唤。
function c42160203.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取从额外卡组特殊召唤可用的空格数，作为本次特殊召唤数量的上限基准。
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	if ft==0 then return end
	ft=math.min(ft,2)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		ft=1
	end
	-- 若适用「召唤之门」，获取其记录的本回合已允许的额外特殊召唤剩余次数，并作为上限限制。
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	if ect~=nil then ft=math.min(ft,ect) end
	-- 弹出选择提示，引导玩家选择要特殊召唤的卡片（提示语：请选择要特殊召唤的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己额外卡组选择1至ft张满足条件的表侧灵摆怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c42160203.spfilter,tp,LOCATION_EXTRA,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择成功的怪兽以表侧守备表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
