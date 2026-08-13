--コンフィラス・ド・ヌーベルズ
-- 效果：
-- 「食谱」卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：场上的这张卡成为攻击·效果的对象时才能发动。这张卡和自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只3·4星的「新式魔厨」仪式怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：启用苏生限制；注册①效果（特殊召唤成功时取对象破坏魔法·陷阱卡）和②效果（成为攻击/效果对象时解放自身与1只攻击表示怪兽，从手卡·卡组特召3·4星「新式魔厨」仪式怪兽）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 「食谱」卡降临。这个卡名的①②的效果1回合各能使用1次。①：这张卡特殊召唤成功的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"魔法·陷阱卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡成为攻击·效果的对象时才能发动。这张卡和自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只3·4星的「新式魔厨」仪式怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡·卡组特殊召唤"
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e3)
end
-- ①效果的破坏对象筛选函数：筛选场上的魔法·陷阱卡。
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①效果的目标选择函数：处理对象选择和发动合法性检查，选择场上1张魔法·陷阱卡作为对象并设置破坏信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	-- 效果发动合法性检查：确认场上存在至少1张可作为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张魔法·陷阱卡作为效果对象，并自动将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：声明将破坏1张卡，对象为已选定的卡，数量为1，供其他效果响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理函数：取得对象卡，若对象仍与效果关联，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果发动条件：确认事件组中包含这张卡自身，即这张卡被选为攻击对象或效果对象。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- ②效果的解放对象筛选函数：筛选可被效果解放、攻击表示，且解放后我方场上有空余怪兽区域的怪兽（可以是己方或对方场上的怪兽）。
function s.relfilter(c,tp,ec)
	return c:IsReleasableByEffect() and c:IsAttackPos()
		-- 确认将候选怪兽与这张卡自身解放后，我方场上仍有空余的怪兽区域，用于后续特殊召唤。
		and Duel.GetMZoneCount(tp,Group.FromCards(c,ec))>0
end
-- ②效果的特殊召唤对象筛选函数：筛选手卡·卡组中卡名属于「新式魔厨」、等级为3或4、且为仪式怪兽（类型同时含怪兽与仪式），且可以被效果特殊召唤的卡。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x196) and c:IsLevel(3,4) and c:GetType()&0x81==0x81
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果发动时的目标检查：确认这张卡可被效果解放，场上存在另一只可解放的攻击表示怪兽，且手卡·卡组存在满足条件的仪式怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasableByEffect()
		-- 检查场上（己方或对方怪兽区）是否存在1只满足解放条件（可被效果解放、攻击表示、解放后有空位）的怪兽，且不能是这张卡自身。
		and Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp,c)
		-- 检查手卡·卡组是否存在1只满足特殊召唤条件（「新式魔厨」、3·4星仪式怪兽）的卡。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明将从手卡·卡组特殊召唤1只怪兽，数量为1，位置为手卡·卡组，用于发动后的响应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理函数：确认这张卡仍与效果关联后，选择1只可解放的攻击表示怪兽与自身一起解放；若解放成功，则从手卡·卡组特殊召唤1只符合条件的「新式魔厨」仪式怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 给玩家显示“请选择要解放的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只可解放的攻击表示怪兽（己方或对方怪兽区均可，不包括自身），作为解放素材。
	local g=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,tp,c)
	if g:GetCount()==0 then return end
	g:AddCard(c)
	-- 将选中的怪兽与这张卡自身同时解放；若实际解放数量不是2，则效果处理失败并终止。
	if Duel.Release(g,REASON_EFFECT)~=2 then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组选择1只符合条件的「新式魔厨」仪式怪兽，并取得该卡。
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选择的仪式怪兽以表侧攻击表示特殊召唤到己方场上，无视召唤条件（nocheck=true），但遵守苏生限制（nolimit=false）。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
