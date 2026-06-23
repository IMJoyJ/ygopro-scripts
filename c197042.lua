--エクソシスター・リタニア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的怪兽只有「救祓少女」怪兽的场合，支付800基本分，以对方的场上·墓地1张卡为对象才能发动。那张卡除外。那之后，可以从以下效果选1个适用。
-- ●进行1只「救祓少女」超量怪兽的超量召唤。
-- ●这个回合自己是已把怪兽超量召唤的场合，对方场上1张卡除外。
function c197042.initial_effect(c)
	-- 注册此卡的发动效果，包括分类、类型、时点、属性、限制次数、条件、费用、目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,197042+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c197042.condition)
	e1:SetCost(c197042.cost)
	e1:SetTarget(c197042.target)
	e1:SetOperation(c197042.activate)
	c:RegisterEffect(e1)
	if not c197042.global_check then
		c197042.global_check=true
		-- 注册一个全局持续效果，用于检测超量召唤成功事件并记录玩家是否已进行过超量召唤
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetCondition(c197042.checkcon)
		ge1:SetOperation(c197042.checkop)
		-- 将全局持续效果ge1注册给玩家0（通常为游戏环境）
		Duel.RegisterEffect(ge1,0)
	end
end
-- 判断是否为超量召唤的怪兽被特殊召唤成功
function c197042.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_XYZ)
end
-- 遍历所有成功召唤的怪兽，若该玩家未注册过超量召唤标记，则注册一个标记，当双方都注册过标记时跳出循环
function c197042.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsSummonType,nil,SUMMON_TYPE_XYZ)
	local tc=g:GetFirst()
	while tc do
		-- 检查该玩家是否已注册过超量召唤标记
		if Duel.GetFlagEffect(tc:GetSummonPlayer(),197042)==0 then
			-- 为该玩家注册一个超量召唤标记，标记将在结束阶段重置
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),197042,RESET_PHASE+PHASE_END,0,1)
		end
		-- 检查双方是否都已注册过超量召唤标记，若都已注册则跳出循环
		if Duel.GetFlagEffect(0,197042)>0 and Duel.GetFlagEffect(1,197042)>0 then
			break
		end
		tc=g:GetNext()
	end
end
-- 过滤函数，用于判断是否为正面表示的救祓少女卡
function c197042.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x172)
end
-- 判断自己场上是否只有救祓少女怪兽（即场上怪兽数量等于救祓少女怪兽数量）
function c197042.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 判断场上怪兽数量大于0且等于救祓少女怪兽数量
	return ct>0 and ct==Duel.GetMatchingGroupCount(c197042.cfilter,tp,LOCATION_MZONE,0,nil)
end
-- 支付800基本分作为发动费用
function c197042.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 让玩家支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 设置效果目标，选择对方场上或墓地一张可除外的卡
function c197042.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方场上或墓地是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从场上选择目标卡，若无法满足则使用普通选择方式
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息，记录将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 过滤函数，用于判断是否为救祓少女超量怪兽
function c197042.xyzfilter(c)
	return c:IsSetCard(0x172) and c:IsXyzSummonable(nil)
end
-- 效果处理函数，将目标卡除外后选择一个效果进行处理
function c197042.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然有效且成功除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 刷新场上状态
		Duel.AdjustAll()
		-- 检查自己额外卡组是否存在可超量召唤的救祓少女怪兽
		local b1=Duel.IsExistingMatchingCard(c197042.xyzfilter,tp,LOCATION_EXTRA,0,1,nil)
		-- 检查自己是否已进行过超量召唤且对方场上存在可除外的卡
		local b2=Duel.GetFlagEffect(tp,197042)>0 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		-- 让玩家从两个选项中选择一个
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(197042,0)},  --"超量召唤"
			{b2,aux.Stringid(197042,1)},  --"选卡除外"
			{true,aux.Stringid(197042,2)})  --"什么都不做"
		if op==1 then
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择一张救祓少女超量怪兽
			local g=Duel.SelectMatchingCard(tp,c197042.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			-- 进行超量召唤
			Duel.XyzSummon(tp,g:GetFirst(),nil)
		elseif op==2 then
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 选择对方场上一张可除外的卡
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
			-- 显示所选卡被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将所选卡除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
