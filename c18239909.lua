--爆竜剣士イグニスターP
-- 效果：
-- 调整＋调整以外的灵摆怪兽1只以上
-- ①：1回合1次，以场上1只灵摆怪兽或者灵摆区域1张卡为对象才能发动。那张卡破坏，选场上1张卡回到持有者卡组。
-- ②：1回合1次，自己主要阶段才能发动。从卡组把1只「龙剑士」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能作为同调素材。
function c18239909.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的灵摆怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSynchroType,TYPE_PENDULUM),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，以场上1只灵摆怪兽或者灵摆区域1张卡为对象才能发动。那张卡破坏，选场上1张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18239909,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c18239909.destg)
	e1:SetOperation(c18239909.desop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。从卡组把1只「龙剑士」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18239909,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c18239909.sptg)
	e2:SetOperation(c18239909.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断目标是否为表侧表示的灵摆怪兽且场上存在可返回卡组的卡
function c18239909.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
		-- 检查场上是否存在至少1张可返回卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 设置效果目标，选择满足条件的灵摆怪兽或灵摆区域的卡作为对象
function c18239909.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_PZONE) and c18239909.desfilter(chkc) end
	-- 检查是否满足发动条件，即场上存在满足条件的目标
	if chk==0 then return Duel.IsExistingTarget(c18239909.desfilter,tp,LOCATION_MZONE+LOCATION_PZONE,LOCATION_MZONE+LOCATION_PZONE,1,nil) end
	-- 向对方玩家提示发动了效果①
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的目标卡作为效果对象
	local g=Duel.SelectTarget(tp,c18239909.desfilter,tp,LOCATION_MZONE+LOCATION_PZONE,LOCATION_MZONE+LOCATION_PZONE,1,1,nil)
	-- 设置操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，确定要返回卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_ONFIELD)
end
-- 处理效果①的发动，破坏目标卡并选择返回卡组的卡
function c18239909.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然有效并进行破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择满足条件的卡返回卡组
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 显示被选为对象的卡的动画效果
			Duel.HintSelection(g)
			-- 将选中的卡返回卡组并洗牌
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于判断是否为「龙剑士」卡且可特殊召唤
function c18239909.spfilter(c,e,tp)
	return c:IsSetCard(0xc7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果②的目标，检查是否满足发动条件
function c18239909.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「龙剑士」怪兽
		and Duel.IsExistingMatchingCard(c18239909.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了效果②
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，确定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果②的发动，从卡组特殊召唤「龙剑士」怪兽
function c18239909.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c18239909.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 给特殊召唤的怪兽添加效果，使其不能作为同调素材
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
