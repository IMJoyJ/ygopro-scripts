--トリックスター・マンジュシカ
-- 效果：
-- ①：自己·对方回合，把手卡的这张卡给对方观看，以「淘气仙星·曼珠诗华」以外的自己场上1只「淘气仙星」怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽回到手卡。
-- ②：只要这张卡在怪兽区域存在，每次对方手卡有卡加入，给与对方加入的卡数量×200伤害。
function c35199656.initial_effect(c)
	-- ①：自己·对方回合，把手卡的这张卡给对方观看，以「淘气仙星·曼珠诗华」以外的自己场上1只「淘气仙星」怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35199656,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCost(c35199656.cost)
	e1:SetTarget(c35199656.target)
	e1:SetOperation(c35199656.operation)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次对方手卡有卡加入，给与对方加入的卡数量×200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c35199656.damcon1)
	e2:SetOperation(c35199656.damop1)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，每次对方手卡有卡加入，给与对方加入的卡数量×200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c35199656.regcon)
	e3:SetOperation(c35199656.regop)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，每次对方手卡有卡加入，给与对方加入的卡数量×200伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c35199656.damcon2)
	e4:SetOperation(c35199656.damop2)
	c:RegisterEffect(e4)
end
-- 检查手卡的这张卡是否已经公开
function c35199656.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
end
-- 筛选场上正面表示的「淘气仙星」怪兽，且该怪兽不是曼珠诗华本身
function c35199656.filter(c)
	return c:IsSetCard(0xfb) and c:IsFaceup() and c:IsAbleToHand() and not c:IsCode(35199656)
end
-- 设置效果的目标为满足条件的场上怪兽
function c35199656.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c35199656.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认场上是否存在满足条件的怪兽作为效果对象
		and Duel.IsExistingTarget(c35199656.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c35199656.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理时将目标怪兽送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果处理时将自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行效果处理，将自身特殊召唤并让目标怪兽返回手牌
function c35199656.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取效果的目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将目标怪兽送回手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- 判断是否为对方手牌加入的场合且当前不在连锁处理中
function c35199656.damcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方手牌加入的场合且当前不在连锁处理中
	return eg:IsExists(Card.IsControler,1,nil,1-tp) and not Duel.IsChainSolving()
end
-- 发动效果，对对方造成伤害
function c35199656.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 显示曼珠诗华的发动动画
	Duel.Hint(HINT_CARD,0,35199656)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	-- 对对方造成伤害，伤害值为对方加入手牌数量乘以200
	Duel.Damage(1-tp,ct*200,REASON_EFFECT)
end
-- 判断是否为对方手牌加入的场合且当前正在连锁处理中
function c35199656.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方手牌加入的场合且当前正在连锁处理中
	return eg:IsExists(Card.IsControler,1,nil,1-tp) and Duel.IsChainSolving()
end
-- 记录对方加入手牌的数量到标记中
function c35199656.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	e:GetHandler():RegisterFlagEffect(35199657,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1,ct)
end
-- 判断是否已记录对方加入手牌的数量
function c35199656.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(35199657)>0
end
-- 处理连锁结束后的伤害计算
function c35199656.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示曼珠诗华的发动动画
	Duel.Hint(HINT_CARD,0,35199656)
	local labels={e:GetHandler():GetFlagEffectLabel(35199657)}
	local ct=0
	for i=1,#labels do ct=ct+labels[i] end
	e:GetHandler():ResetFlagEffect(35199657)
	-- 对对方造成伤害，伤害值为累计的加入手牌数量乘以200
	Duel.Damage(1-tp,ct*200,REASON_EFFECT)
end
