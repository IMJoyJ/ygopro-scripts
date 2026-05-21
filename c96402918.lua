--氷霊山の龍祖 ランセア
-- 效果：
-- 水属性调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合可以使用最多2次。
-- ①：对方把怪兽特殊召唤的场合才能发动（同一连锁上最多1次）。从自己的手卡·卡组·额外卡组·墓地把1只「冰结界」怪兽特殊召唤。那之后，可以把对方场上1只攻击表示怪兽变成守备表示。
-- ②：同调召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。从额外卡组把1只「冰结界」同调怪兽当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：设置同调召唤手续、①效果（对方特召时特召手卡/卡组/额外/墓地「冰结界」怪兽并可变守备表示）和②效果（同调召唤的此卡因对方离场时从额外特召「冰结界」同调怪兽）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤条件：水属性调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),aux.NonTuner(nil),1)
	-- ①：对方把怪兽特殊召唤的场合才能发动（同一连锁上最多1次）。从自己的手卡·卡组·额外卡组·墓地把1只「冰结界」怪兽特殊召唤。那之后，可以把对方场上1只攻击表示怪兽变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：同调召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。从额外卡组把1只「冰结界」同调怪兽当作同调召唤作特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤同调怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 判断对方是否特殊召唤了怪兽，作为①效果的发动条件
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp)
end
-- 过滤自身手卡、卡组、墓地、额外卡组中可以特殊召唤的「冰结界」怪兽，并根据其所在位置检查是否有可用的怪兽区域
function s.spfilter1(c,e,tp)
	if not (c:IsSetCard(0x2f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 检查从额外卡组特殊召唤该怪兽时，是否有可用的额外怪兽区域或连接端指向的区域
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 检查从手卡、卡组、墓地特殊召唤该怪兽时，自己场上是否有空余的怪兽区域
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end
-- ①效果的发动准备：检查同一连锁上是否未发动过该效果，且自己的手卡、卡组、墓地、额外卡组存在可特殊召唤的「冰结界」怪兽
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0
		-- 检查自己的手卡、卡组、墓地、额外卡组是否存在至少1只满足特殊召唤条件的「冰结界」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从手卡、卡组、墓地、额外卡组特殊召唤1只怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
-- 过滤对方场上可以改变表示形式的攻击表示怪兽
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- ①效果的处理：从手卡、卡组、墓地、额外卡组特殊召唤1只「冰结界」怪兽，之后可以选对方场上1只攻击表示怪兽变成守备表示
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡、卡组、墓地、额外卡组选择1只不受「王家长眠之谷」影响的、满足条件的「冰结界」怪兽
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 如果成功将选中的怪兽以表侧表示特殊召唤
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查对方场上是否存在可以改变表示形式的攻击表示怪兽
		and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否要将对方场上1只攻击表示怪兽变成守备表示
		and Duel.SelectYesNo(tp,aux.Stringid(id,2))then  --"是否把1只对方怪兽变成守备表示？"
		-- 中断当前效果处理，使后续的改变表示形式处理与特殊召唤处理不视为同时进行（会造成错时点）
		Duel.BreakEffect()
		-- 提示玩家选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 玩家选择对方场上1只可以改变表示形式的攻击表示怪兽
		local tg=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 选中该怪兽并显示被选为对象的动画效果
		Duel.HintSelection(tg)
		-- 将选中的怪兽变成表侧守备表示
		Duel.ChangePosition(tg:GetFirst(),POS_FACEUP_DEFENSE)
	end
end
-- 判断此卡是否为同调召唤的表侧表示怪兽且因对方从场上离开，作为②效果的发动条件
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp
end
-- 过滤额外卡组中可以当作同调召唤特殊召唤的「冰结界」同调怪兽
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查从额外卡组特殊召唤该同调怪兽时，是否有可用的额外怪兽区域或连接端指向的区域
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动准备：检查额外卡组是否存在可特殊召唤的「冰结界」同调怪兽，并设置特殊召唤的操作信息
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只满足特殊召唤条件的「冰结界」同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从额外卡组特殊召唤1只怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理：从额外卡组选择1只「冰结界」同调怪兽，当作同调召唤特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1只满足条件的「冰结界」同调怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 如果成功将选中的怪兽当作同调召唤以表侧表示特殊召唤
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
