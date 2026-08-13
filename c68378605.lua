--還流の精ヴォドニカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「还流之精 水老爹」以外的10星怪兽被送去墓地的场合才能发动。这张卡从手卡·墓地守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：以自己墓地1只10星怪兽为对象才能发动。那只怪兽效果无效在对方场上特殊召唤。那之后，自己抽1张。
local s,id,o=GetID()
-- 初始化效果：注册①效果（10星怪兽被送去墓地的场合从手卡·墓地特殊召唤的诱发选发效果）和②效果（以墓地10星怪兽为对象在对方场上特殊召唤并抽卡的起动效果），两个效果各1回合1次。
function s.initial_effect(c)
	-- ①：「还流之精 水老爹」以外的10星怪兽被送去墓地的场合才能发动。这张卡从手卡·墓地守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以自己墓地1只10星怪兽为对象才能发动。那只怪兽效果无效在对方场上特殊召唤。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤器：等级10且不是「还流之精 水老爹」自身的怪兽。
function s.cfilter(c,tp)
	return c:IsLevel(10) and not c:IsCode(id)
end
-- ①效果的发动条件：本次送去墓地的卡中至少存在1只满足条件的10星怪兽（本卡以外）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ①效果的发动可行性检查：自己主要怪兽区有空格，且这张卡可以守备表示特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤的操作信息：确定处理的是这张卡自身1张。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：确认这张卡仍与连锁相关且不受王家长眠之谷影响后，将其守备表示特殊召唤，成功后赋予离场时除外的永续效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡仍与当前连锁相关，且不受王家长眠之谷的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 将这张卡以表侧守备表示特殊召唤到自己场上，特殊召唤成功则继续处理。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：以自己墓地1只10星怪兽为对象才能发动。那只怪兽效果无效在对方场上特殊召唤。那之后，自己抽1张。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤器：自己墓地中可以特殊召唤到对方场上的10星怪兽。
function s.spfilter(c,e,tp)
	return c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- ②效果的目标合法性检查：连锁对象确认时要求对象在自己墓地且满足条件；发动可行性检查时要求自己墓地有可作为对象的10星怪兽、对方场上有空格且自己可以抽卡。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 确认自己墓地存在1只可作为效果对象的满足条件的10星怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 确认对方主要怪兽区有可用的空格。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 确认自己可以抽1张卡。
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 向玩家提示「请选择要特殊召唤的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 以自己墓地1只满足条件的10星怪兽为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息：确定处理的是作为对象的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置抽卡的操作信息：自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理：取得对象怪兽，确认其仍与连锁相关且不受王家长眠之谷影响后，将其效果无效以表侧表示特殊召唤到对方场上，完成特殊召唤后错开时点让自己抽1张卡。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain()
		-- 检查对象卡不受王家长眠之谷的影响。
		and aux.NecroValleyFilter()(tc)
		-- 将对象怪兽以表侧表示分步特殊召唤到对方场上，成功则继续处理。
		and Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP) then
		-- 那只怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成分步特殊召唤（与SpecialSummonStep配对）。
		Duel.SpecialSummonComplete()
		-- 中断当前效果，使之后的抽卡处理视为不同时处理，对应「那之后」。
		Duel.BreakEffect()
		-- 自己以效果原因抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
