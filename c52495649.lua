--バラムニエル・ド・ヌーベルズ
-- 效果：
-- 「食谱」卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。把1张「新式魔厨」卡或者「食谱」卡从卡组加入手卡。
-- ②：以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽解放，从手卡·卡组把1只6星「新式魔厨」仪式怪兽特殊召唤。这张卡是已用「新式魔厨」怪兽的效果特殊召唤的场合，这个效果在对方回合也能发动。
local s,id,o=GetID()
-- 为卡添加苏生限制；注册①特殊召唤成功时检索「新式魔厨」/「食谱」的诱发效果；注册②以对方攻击表示怪兽为对象解放并从手卡·卡组特招6星新式魔厨仪式怪兽的起动效果；再将该效果克隆为快速效果，仅当本卡用「新式魔厨」怪兽效果特殊召唤时可在对方回合发动（①②分别1回合1次）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应①效果：“①：这张卡特殊召唤成功的场合才能发动。把1张「新式魔厨」卡或者「食谱」卡从卡组加入手卡。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 对应②效果：“②：以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽解放，从手卡·卡组把1只6星「新式魔厨」仪式怪兽特殊召唤。这张卡是已用「新式魔厨」怪兽的效果特殊召唤的场合，这个效果在对方回合也能发动。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡·卡组特殊召唤"
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(s.spcon2)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e3)
end
-- 检索过滤器：卡名属于「新式魔厨」或「食谱」字段，且该卡能够被加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x196,0x197) and c:IsAbleToHand()
end
-- ①效果发动条件与操作信息：检查卡组存在可加入手卡的「新式魔厨」/「食谱」卡，并设定效果处理时要从卡组将1张加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：卡组中是否存在至少1张满足s.thfilter的卡（即「新式魔厨」或「食谱」且能加入手卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：本次效果为“从卡组将1张卡加入手卡”（不取对象，数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：玩家选择1张满足条件的「新式魔厨」/「食谱」卡，将其加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家从卡组中选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选择1张满足s.thfilter的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡（原因：效果）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的起动版发动条件：这张卡不是用「新式魔厨」怪兽的效果特殊召唤的场合才能作为起动效果发动（即只能在自己主要阶段发动）。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER==0 or not c:IsSpecialSummonSetCard(0x196)
end
-- ②效果的快速版发动条件：这张卡是用「新式魔厨」怪兽的效果特殊召唤的场合，才能在对方回合也作为快速效果发动。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x196)
end
-- 解放对象过滤器：对方场上的攻击表示怪兽，并且可以被效果解放。
function s.relfilter(c)
	return c:IsReleasableByEffect() and c:IsAttackPos()
end
-- 特招对象过滤器：6星、属于「新式魔厨」字段的仪式怪兽（类型含仪式+怪兽），且能够被效果特殊召唤（不检查召唤条件，检查苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x196) and c:IsLevel(6) and c:GetType()&0x81==0x81
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果发动与目标选择：确认对象为对方怪兽区可解放的攻击表示怪兽，确认己方怪兽区有空位、存在可解放对象及可特招的仪式怪兽；选择解放对象，并设定“解放”和“特殊召唤”的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.relfilter(chkc) end
	-- 发动条件之一：己方主要怪兽区有空位，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：对方场上有1只满足s.relfilter（攻击表示且可被效果解放）的怪兽可以作为对象。
		and Duel.IsExistingTarget(s.relfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 发动条件之三：手卡·卡组中存在1只满足s.spfilter的6星「新式魔厨」仪式怪兽可以特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要解放的对方怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从对方场上选择1只攻击表示且可被效果解放的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.relfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设定操作信息：将解放所选择的对象。
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
	-- 设定操作信息：将从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：对象仍与效果关联时将其解放，成功且己方怪兽区有空位则从手卡·卡组选择1只6星「新式魔厨」仪式怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果的对象（被选为解放对象的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与此效果关联，用效果将其解放且解放成功，同时己方怪兽区仍有空位，才继续特殊召唤处理。
	if tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组选择1只满足s.spfilter的6星「新式魔厨」仪式怪兽并取出。
		local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
		if tc then
			-- 将选择的仪式怪兽正面表示特殊召唤到己方场上（不检查召唤条件，检查苏生限制）。
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
