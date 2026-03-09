--剣闘獣ガイザレス
-- 效果：
-- 「剑斗兽 枪斗」＋「剑斗兽」怪兽
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：这张卡特殊召唤成功时，以场上最多2张卡为对象才能发动。那些卡破坏。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把「剑斗兽 枪斗」以外的2只「剑斗兽」怪兽特殊召唤。
function c48156348.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为41470137的「剑斗兽 枪斗」和1个满足过滤条件的「剑斗兽」怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,41470137,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1019),1,true,true)
	-- 添加接触融合特殊召唤规则，通过将自己场上的符合条件的卡送回卡组来从额外卡组特殊召唤
	aux.AddContactFusionProcedure(c,c48156348.cfilter,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- ①：这张卡特殊召唤成功时，以场上最多2张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c48156348.splimit)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把「剑斗兽 枪斗」以外的2只「剑斗兽」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48156348,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c48156348.destg)
	e3:SetOperation(c48156348.desop)
	c:RegisterEffect(e3)
	-- 效果作用：使该卡只能从额外卡组特殊召唤，且必须满足特定条件（即自己场上的融合素材送回卡组）
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(48156348,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c48156348.spcon)
	e4:SetCost(c48156348.spcost)
	e4:SetTarget(c48156348.sptg)
	e4:SetOperation(c48156348.spop)
	c:RegisterEffect(e4)
end
-- 效果原文内容：让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）
function c48156348.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 过滤函数：判断场上是否有可以作为接触融合素材的「剑斗兽 枪斗」或「剑斗兽」怪兽
function c48156348.cfilter(c)
	return (c:IsFusionCode(41470137) or c:IsFusionSetCard(0x1019) and c:IsType(TYPE_MONSTER))
		and c:IsAbleToDeckOrExtraAsCost()
end
-- 选择目标：选择场上1~2张卡作为破坏对象
function c48156348.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否满足选择目标条件：确认场上是否存在至少1张可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1~2张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置操作信息，指定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作，对选定的卡进行破坏处理
function c48156348.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 实际执行破坏动作，原因设为效果破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 判断是否满足发动条件：该卡在战斗阶段中参与过战斗
function c48156348.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 设置发动费用：将自身送回卡组作为特殊召唤的代价
function c48156348.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	-- 将自身送回卡组作为特殊召唤的代价
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
-- 过滤函数：筛选出非「剑斗兽 枪斗」且为「剑斗兽」的怪兽，用于特殊召唤
function c48156348.filter(c,e,tp)
	return not c:IsCode(41470137) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：确认卡组中是否存在至少2只符合条件的怪兽，并检查是否有影响特殊召唤的限制效果
function c48156348.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ft>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查卡组中是否存在至少2只符合条件的怪兽
			and Duel.IsExistingMatchingCard(c48156348.filter,tp,LOCATION_DECK,0,2,nil,e,tp)
	end
	-- 设置操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作：从卡组选择2只符合条件的怪兽并特殊召唤到场上
function c48156348.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查场上是否还有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(c48156348.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		local tc=sg:GetFirst()
		-- 将第一张选中的怪兽特殊召唤到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		tc=sg:GetNext()
		-- 将第二张选中的怪兽特殊召唤到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		-- 完成一次完整的特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
