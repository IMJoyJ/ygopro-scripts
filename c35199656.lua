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
-- 发动代价判定：要求此卡在手牌且未公开，即满足“把手卡的这张卡给对方观看”的展示条件；实际展示动作在发动时由游戏系统处理。
function c35199656.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
end
-- 筛选对象：自己场上表侧表示、属于「淘气仙星」系列、能够返回手卡、且卡名不是「淘气仙星·曼珠诗华」的怪兽。
function c35199656.filter(c)
	return c:IsSetCard(0xfb) and c:IsFaceup() and c:IsAbleToHand() and not c:IsCode(35199656)
end
-- 效果发动目标的合法性与选择处理：若在连锁处理中指定对象，则校验该对象是否为自己场上的合法淘气仙星；初次发动时检查此卡能否特殊召唤、自己场上是否有空位以及是否存在可选对象。
function c35199656.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c35199656.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己怪兽区域是否有可用空格，以确保此卡可以特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只满足条件的淘气仙星怪兽，可被选择为效果对象。
		and Duel.IsExistingTarget(c35199656.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作者显示选择提示，要求选择要返回手卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上的合法候选中选择1只淘气仙星怪兽，将其锁定为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c35199656.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记“将对象卡返回手卡”的操作信息，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 登记“将此卡特殊召唤”的操作信息，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：如果此卡仍与效果关联，则将此卡特殊召唤；召唤成功后将之前选择的对象返回持有者手卡。
function c35199656.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到自己的怪兽区域，并判断是否成功。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取效果发动时选择的对象怪兽。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 把对象怪兽返回其持有者的手卡，返回原因是效果。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- 不入连锁的伤害效果触发条件判定：当有卡加入对方手卡且当前不在连锁处理中时，立即发动伤害。
function c35199656.damcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 条件成立条件：加入手卡的卡中存在对方玩家的卡，并且当前没有正在处理的连锁。
	return eg:IsExists(Card.IsControler,1,nil,1-tp) and not Duel.IsChainSolving()
end
-- 不入连锁的伤害处理：按对方本次加入手卡的数量乘以200，给予对方伤害。
function c35199656.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 播放此卡的效果动画，向双方展示伤害来源。
	Duel.Hint(HINT_CARD,0,35199656)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	-- 给予对方玩家（本次加入手卡数量）×200的效果伤害。
	Duel.Damage(1-tp,ct*200,REASON_EFFECT)
end
-- 连锁处理中加入手卡时的登记效果条件判定：若当前在连锁处理中且对方手卡有卡加入，则转为延迟登记。
function c35199656.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件成立：加入手卡的卡中存在对方玩家的卡，且当前正在连锁处理中。
	return eg:IsExists(Card.IsControler,1,nil,1-tp) and Duel.IsChainSolving()
end
-- 登记处理：统计在连锁处理中对方加入手卡的卡数，并以该数值作为标记记录在此卡上，供连锁结束后统一计算伤害。
function c35199656.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	e:GetHandler():RegisterFlagEffect(35199657,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1,ct)
end
-- 延迟伤害处理的条件：此卡上存在已登记的待处理数量，说明前面有连锁中登记过对方加入手卡。
function c35199656.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(35199657)>0
end
-- 连锁结束后的伤害处理准备：读取所有登记的待处理数量并累加，用于随后给予伤害。
function c35199656.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 播放此卡的效果动画，提示伤害来源。
	Duel.Hint(HINT_CARD,0,35199656)
	local labels={e:GetHandler():GetFlagEffectLabel(35199657)}
	local ct=0
	for i=1,#labels do ct=ct+labels[i] end
	e:GetHandler():ResetFlagEffect(35199657)
	-- 给予对方玩家（累计加入手卡数量）×200的效果伤害。
	Duel.Damage(1-tp,ct*200,REASON_EFFECT)
end
