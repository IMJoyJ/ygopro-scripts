--剣闘獣ネロキウス
-- 效果：
-- 「剑斗兽」怪兽×3
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：这张卡不会被战斗破坏，这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到额外卡组才能发动。从卡组把2只「剑斗兽」怪兽特殊召唤。
function c29357956.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用3个「剑斗兽」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1019),3,true)
	-- 添加接触融合特殊召唤规则，允许将自己场上的怪兽送回卡组来特殊召唤此卡
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_MZONE,0,aux.ContactFusionSendToDeck(c))
	-- 特殊召唤条件：此卡只能从额外卡组特殊召唤，且必须满足接触融合条件
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c29357956.splimit)
	c:RegisterEffect(e1)
	-- 效果①：此卡不会被战斗破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 效果①：此卡进行战斗时，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(1)
	e4:SetCondition(c29357956.actcon)
	c:RegisterEffect(e4)
	-- 效果②：战斗阶段结束时，将此卡送回额外卡组才能发动。从卡组将2只「剑斗兽」怪兽特殊召唤
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(29357956,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c29357956.spcon)
	e6:SetCost(c29357956.spcost)
	e6:SetTarget(c29357956.sptg)
	e6:SetOperation(c29357956.spop)
	c:RegisterEffect(e6)
end
-- 限制此卡不能从额外卡组以外的位置特殊召唤
function c29357956.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 判断是否为攻击或被攻击状态
function c29357956.actcon(e)
	-- 判断是否为攻击或被攻击状态
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- 判断此卡是否参与过战斗
function c29357956.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 支付特殊召唤费用：将此卡送回卡组
function c29357956.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	-- 将此卡送回卡组作为费用
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
-- 过滤满足条件的「剑斗兽」怪兽
function c29357956.filter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件：场地上有足够空间且卡组中有2只「剑斗兽」怪兽
function c29357956.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家场上的可用怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ft>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检测卡组中是否存在2只满足条件的「剑斗兽」怪兽
			and Duel.IsExistingMatchingCard(c29357956.filter,tp,LOCATION_DECK,0,2,nil,e,tp)
	end
	-- 设置操作信息，表示将特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作：从卡组选择2只「剑斗兽」怪兽特殊召唤
function c29357956.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检测场上是否还有足够的召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有满足条件的「剑斗兽」怪兽
	local g=Duel.GetMatchingGroup(c29357956.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		local tc=sg:GetFirst()
		-- 将第一只选中的怪兽特殊召唤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		tc=sg:GetNext()
		-- 将第二只选中的怪兽特殊召唤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
