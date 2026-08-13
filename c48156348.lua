--剣闘獣ガイザレス
-- 效果：
-- 「剑斗兽 枪斗」＋「剑斗兽」怪兽
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：这张卡特殊召唤成功时，以场上最多2张卡为对象才能发动。那些卡破坏。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把「剑斗兽 枪斗」以外的2只「剑斗兽」怪兽特殊召唤。
function c48156348.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册以「剑斗兽 枪斗」(41470137)与1只「剑斗兽」怪兽为融合素材的融合召唤手续。
	aux.AddFusionProcCodeFun(c,41470137,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1019),1,true,true)
	-- 注册接触融合手续：从自己场上选择满足cfilter的素材送回卡组，即可从额外卡组特殊召唤这张卡，不需要融合魔法。
	aux.AddContactFusionProcedure(c,c48156348.cfilter,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c48156348.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功时，以场上最多2张卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48156348,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c48156348.destg)
	e3:SetOperation(c48156348.desop)
	c:RegisterEffect(e3)
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把「剑斗兽 枪斗」以外的2只「剑斗兽」怪兽特殊召唤。
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
-- 特殊召唤限制条件：这张卡不在额外卡组时不允许被特殊召唤，即只能从额外卡组特殊召唤。
function c48156348.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 接触融合素材过滤：可以是「剑斗兽 枪斗」或「剑斗兽」字段怪兽，且该卡能作为代价送回卡组/额外卡组。
function c48156348.cfilter(c)
	return (c:IsFusionCode(41470137) or c:IsFusionSetCard(0x1019) and c:IsType(TYPE_MONSTER))
		and c:IsAbleToDeckOrExtraAsCost()
end
-- 破坏效果的发动目标选择：从双方场上选择1~2张卡作为对象，并设置对应的破坏操作信息。
function c48156348.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动检查：场上是否存在至少1张能够成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 令玩家选择场上1~2张卡作为对象，并把它们登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 将本次连锁的操作信息登记为破坏刚选择的对象卡，数量为选择的张数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果处理：取得连锁对象，筛选仍与效果相关的卡后将其破坏。
function c48156348.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中记录的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 以效果原因将筛选出的对象卡破坏。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 战斗阶段结束效果的发动条件：这张卡在本回合进行过战斗。
function c48156348.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- ②效果的发动代价：将这张卡自身送回持有者的额外卡组。
function c48156348.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	-- 将这张卡作为代价送回持有者卡组（此处按规则应回到额外卡组，作为发动②效果的COST）。
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
-- 特殊召唤对象过滤：不是「剑斗兽 枪斗」的「剑斗兽」怪兽，且能够被效果特殊召唤。
function c48156348.filter(c,e,tp)
	return not c:IsCode(41470137) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时点：检查自己怪兽区域是否有至少2个空位、是否不受青眼精灵龙限制、卡组是否有2只符合条件的「剑斗兽」怪兽，有则设置特殊召唤操作信息。
function c48156348.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 计算自己场上当前可用的主要怪兽区域数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ft>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 确认卡组中存在至少2只满足「剑斗兽」特殊召唤过滤条件的怪兽。
			and Duel.IsExistingMatchingCard(c48156348.filter,tp,LOCATION_DECK,0,2,nil,e,tp)
	end
	-- 设置本次连锁要特殊召唤2只卡组中的「剑斗兽」怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果处理：若青眼精灵龙效果生效则直接终止；否则从卡组选择2只符合条件的「剑斗兽」怪兽依次特殊召唤。
function c48156348.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理前再次确认自己场上有至少2个可用怪兽区域，不足则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 从卡组中获取所有符合条件的「剑斗兽」怪兽。
	local g=Duel.GetMatchingGroup(c48156348.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		local tc=sg:GetFirst()
		-- 将第一只选择的怪兽以表侧攻击表示加入特殊召唤流程。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		tc=sg:GetNext()
		-- 将第二只选择的怪兽以表侧攻击表示加入特殊召唤流程。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		-- 完成特殊召唤流程，正式处理并召唤所有通过SpecialSummonStep加入的怪兽。
		Duel.SpecialSummonComplete()
	end
end
