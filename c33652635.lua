--剣闘獣ドミティアノス
-- 效果：
-- 「剑斗兽 维斯帕西亚努斯」＋「剑斗兽」怪兽×2
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：1回合1次，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ②：只要这张卡在怪兽区域存在，对方怪兽的攻击对象由自己选择。
-- ③：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把1只「剑斗兽」怪兽特殊召唤。
function c33652635.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为88996322的怪兽和2个满足过滤条件的「剑斗兽」怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,88996322,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1019),2,true,true)
	-- 添加接触融合特殊召唤规则，通过将自己场上的符合条件的怪兽送回卡组来特殊召唤此卡
	aux.AddContactFusionProcedure(c,c33652635.cfilter,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 只要这张卡在怪兽区域存在，对方怪兽的攻击对象由自己选择
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c33652635.splimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，对方把怪兽的效果发动时才能发动。那个发动无效并破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33652635,0))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c33652635.condition)
	e2:SetTarget(c33652635.target)
	e2:SetOperation(c33652635.operation)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，对方怪兽的攻击对象由自己选择
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
	-- ③：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把1只「剑斗兽」怪兽特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(33652635,1))  --"回到卡组并特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c33652635.spcon)
	e4:SetCost(c33652635.spcost)
	e4:SetTarget(c33652635.sptg)
	e4:SetOperation(c33652635.spop)
	c:RegisterEffect(e4)
end
-- 限制此卡不能从额外卡组特殊召唤，只能通过接触融合方式特殊召唤
function c33652635.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 接触融合的素材过滤函数，筛选「剑斗兽 维斯帕西亚努斯」或「剑斗兽」怪兽且能送回卡组
function c33652635.cfilter(c)
	return (c:IsFusionCode(88996322) or c:IsFusionSetCard(0x1019) and c:IsType(TYPE_MONSTER)) and c:IsAbleToDeckOrExtraAsCost()
end
-- 诱发效果的发动条件，对方怪兽发动效果且此卡未在战斗中被破坏且该连锁可被无效
function c33652635.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽发动效果且此卡未在战斗中被破坏且该连锁可被无效
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 设置连锁处理时的操作信息，包括使发动无效和破坏目标怪兽
function c33652635.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理时的操作信息，使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁处理时的操作信息，破坏目标怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行连锁无效并破坏目标怪兽的操作
function c33652635.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否成功无效且目标怪兽是否有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 战斗结束时的特殊召唤条件，此卡必须参与过战斗
function c33652635.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 特殊召唤的费用，将此卡送回卡组
function c33652635.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	-- 将此卡送回卡组作为费用
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
-- 筛选卡组中可特殊召唤的「剑斗兽」怪兽
function c33652635.filter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的条件，检查场上是否有空怪兽区且卡组中存在符合条件的怪兽
function c33652635.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c33652635.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作，从卡组选择一只「剑斗兽」怪兽特殊召唤
function c33652635.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c33652635.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
