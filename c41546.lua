--DD魔導賢者トーマス
-- 效果：
-- ←6 【灵摆】 6→
-- 「DD 魔导贤者 托马斯」的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从自己的额外卡组把1只表侧表示的「DD」灵摆怪兽加入手卡。
-- 【怪兽效果】
-- 「DD 魔导贤者 托马斯」的怪兽效果1回合只能使用1次。
-- ①：以自己的灵摆区域1张「DD」卡为对象才能发动。那张卡破坏，从卡组把1只8星「DDD」怪兽守备表示特殊召唤。这个回合，这个效果特殊召唤的怪兽的效果无效化，对方受到的战斗伤害变成一半。
function c41546.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。从自己的额外卡组把1只表侧表示的「DD」灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41546,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,41546)
	e1:SetTarget(c41546.thtg)
	e1:SetOperation(c41546.thop)
	c:RegisterEffect(e1)
	-- ①：以自己的灵摆区域1张「DD」卡为对象才能发动。那张卡破坏，从卡组把1只8星「DDD」怪兽守备表示特殊召唤。这个回合，这个效果特殊召唤的怪兽的效果无效化，对方受到的战斗伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41546,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,41547)
	e2:SetTarget(c41546.destg)
	e2:SetOperation(c41546.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的灵摆怪兽（表侧表示、属于DD系列、类型为灵摆、可以加入手牌）
function c41546.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 设置连锁处理时的提示信息，表示将从额外卡组选择1只灵摆怪兽加入手牌
function c41546.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：自己额外卡组是否存在至少1只符合条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41546.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁处理时的提示信息，表示将从额外卡组选择1只灵摆怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果发动时的执行操作，提示玩家选择要加入手牌的灵摆怪兽并执行加入手牌和确认卡片的操作
function c41546.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组中选择1只符合条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c41546.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的灵摆怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于筛选属于DD系列的灵摆卡
function c41546.desfilter(c)
	return c:IsSetCard(0xaf)
end
-- 过滤函数，用于筛选属于DDD系列、等级为8、可以特殊召唤的怪兽
function c41546.spfilter(c,e,tp)
	return c:IsSetCard(0x10af) and c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置连锁处理时的提示信息，表示将从灵摆区选择1张DD卡破坏，并从卡组特殊召唤1只DDD怪兽
function c41546.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c41546.desfilter(chkc) end
	-- 检查是否满足发动条件：自己灵摆区是否存在至少1张DD卡
	if chk==0 then return Duel.IsExistingTarget(c41546.desfilter,tp,LOCATION_PZONE,0,1,nil)
		-- 检查自己场上是否有足够的空间进行特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足发动条件：自己卡组是否存在至少1只符合条件的DDD怪兽
		and Duel.IsExistingMatchingCard(c41546.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的灵摆卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1张自己灵摆区的DD卡作为效果对象
	local g=Duel.SelectTarget(tp,c41546.desfilter,tp,LOCATION_PZONE,0,1,1,nil)
	-- 设置连锁处理时的提示信息，表示将破坏选中的灵摆卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁处理时的提示信息，表示将从卡组特殊召唤1只DDD怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动时的执行操作，先破坏选中的灵摆卡，再从卡组特殊召唤DDD怪兽，并设置其效果无效化和战斗伤害减半
function c41546.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效并执行破坏操作
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查场上是否有足够的空间进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的DDD怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只符合条件的DDD怪兽
		local g=Duel.SelectMatchingCard(tp,c41546.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 执行特殊召唤操作，将选中的怪兽以守备表示特殊召唤到场上
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 使特殊召唤的怪兽效果无效化
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使特殊召唤的怪兽效果在回合结束时失效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
	-- 使对方受到的战斗伤害减半
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetValue(HALF_DAMAGE)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册战斗伤害减半效果
	Duel.RegisterEffect(e3,tp)
end
