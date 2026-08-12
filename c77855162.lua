--振子特急エントレインメント
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己的手卡·额外卡组（表侧）把1只4星以下的灵摆怪兽特殊召唤。
-- ②：这张卡或者自己的灵摆怪兽和对方怪兽进行战斗，那只对方怪兽没被破坏的伤害步骤结束时才能发动。那只对方怪兽破坏。
function c77855162.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从自己的手卡·额外卡组（表侧）把1只4星以下的灵摆怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77855162,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,77855162)
	e1:SetCondition(c77855162.spcon)
	e1:SetTarget(c77855162.sptg)
	e1:SetOperation(c77855162.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡或者自己的灵摆怪兽和对方怪兽进行战斗，那只对方怪兽没被破坏的伤害步骤结束时才能发动。那只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77855162,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCountLimit(1,77855163)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c77855162.descon)
	e2:SetTarget(c77855162.destg)
	e2:SetOperation(c77855162.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetRange(LOCATION_MZONE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCondition(c77855162.descon2)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判断：这张卡同调召唤成功
function c77855162.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：手卡或额外卡组表侧表示的、4星以下的、可以特殊召唤的灵摆怪兽
function c77855162.spfilter(c,e,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_PENDULUM)
		and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		-- 检查若卡片在手卡，则自己场上是否有可用的主要怪兽区域空格
		and (c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查若卡片在额外卡组，则自己场上是否有可用于从额外卡组特殊召唤的空格
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果①的发动准备：检查是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c77855162.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或额外卡组是否存在至少1只满足特殊召唤条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77855162.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡或额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end
-- 效果①的执行：从手卡或额外卡组（表侧）选择1只满足条件的灵摆怪兽特殊召唤
function c77855162.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或额外卡组选择1只满足特殊召唤条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c77855162.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②（自身战斗时）的发动条件判断：伤害步骤结束时，自身与对方怪兽进行过战斗，且对方怪兽仍在场上并与战斗相关联
function c77855162.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	-- 检查伤害步骤结束时，对方怪兽是否未被战斗破坏（仍在场上）且仍与战斗相关联
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and bc and bc:IsRelateToBattle() and bc:IsOnField()
		and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 效果②（己方灵摆怪兽战斗时）的发动条件判断：伤害步骤结束时，自己的表侧表示灵摆怪兽与对方怪兽进行过战斗，且对方怪兽仍在场上并与战斗相关联
function c77855162.descon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上进行战斗的怪兽和对方场上进行战斗的怪兽
	local tc,bc=Duel.GetBattleMonster(tp)
	e:SetLabelObject(bc)
	return tc and bc and tc:IsStatus(STATUS_OPPO_BATTLE) and bc:IsOnField() and bc:IsRelateToBattle()
		and tc:IsFaceup() and tc:IsType(TYPE_PENDULUM)
end
-- 效果②的发动准备：设置破坏那只对方怪兽的操作信息
function c77855162.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置破坏操作信息（破坏进行战斗的那只对方怪兽）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 效果②的执行：将那只进行战斗且未被破坏的对方怪兽破坏
function c77855162.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 因效果将那只对方怪兽破坏
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
