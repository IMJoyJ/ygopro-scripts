--GP－Nヘッド
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己基本分比对方少的场合才能发动。这张卡从手卡特殊召唤。
-- ②：对方准备阶段才能发动。在对方场上把1只「氮氧衍生物」（炎族·炎·8星·攻/守0）特殊召唤。这衍生物不能作为连接素材。
-- ③：对方主要阶段，以场上1只「氮氧衍生物」为对象才能发动。那衍生物以及那些前面·后面·相邻的区域（怪兽区域·魔法与陷阱区域）存在的卡全部破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特招、对方准备阶段特招衍生物、对方主要阶段破坏衍生物及相邻区域卡片三个效果。
function s.initial_effect(c)
	-- ①：自己基本分比对方少的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：对方准备阶段才能发动。在对方场上把1只「氮氧衍生物」（炎族·炎·8星·攻/守0）特殊召唤。这衍生物不能作为连接素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tkcon)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	-- ③：对方主要阶段，以场上1只「氮氧衍生物」为对象才能发动。那衍生物以及那些前面·后面·相邻的区域（怪兽区域·魔法与陷阱区域）存在的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：自己基本分比对方少。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己当前的生命值是否低于对方。
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 效果①的发动准备：检查自身是否能特殊召唤以及怪兽区域是否有空位。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用于特殊召唤怪兽的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：将这张卡从手卡特殊召唤。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关联，则将其以表侧表示特殊召唤到自己场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 效果②的发动条件：对方的回合。
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方。
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果②的发动准备：检查对方场上是否有空位以及是否能特殊召唤衍生物。
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有可用于特殊召唤怪兽的空位。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以在对方场上特殊召唤特定属性、种族、等级和攻守的衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,8,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP,1-tp) end
	-- 设置连锁处理中的操作信息为产生1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁处理中的操作信息为在对方场上特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,0)
end
-- 效果②的效果处理：在对方场上特殊召唤「氮氧衍生物」。
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否仍有可用的怪兽区域空位。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0
		-- 若无法特殊召唤该衍生物，则不进行处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,8,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP,1-tp) then return end
	-- 创建「氮氧衍生物」的卡片数据。
	local token=Duel.CreateToken(tp,id+o)
	-- 尝试将衍生物以表侧表示特殊召唤到对方场上。
	if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP) then
		-- 这衍生物不能作为连接素材。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		token:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理。
	Duel.SpecialSummonComplete()
end
-- 效果③的发动条件：对方主要阶段。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前所处的阶段。
	local ph=Duel.GetCurrentPhase()
	-- 检查当前是否为对方回合的主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()==1-tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤条件：场上表侧表示的「氮氧衍生物」。
function s.dfilter(c)
	return c:IsCode(id+o) and c:IsFaceup()
end
-- 过滤条件：用于寻找与目标卡片相邻（前、后、左、右）区域存在的卡片。
function s.sfilter(c,p,seq,loc)
	local sseq=c:GetSequence()
	if c:IsControler(1-p) then
		return loc==LOCATION_MZONE and c:IsLocation(LOCATION_MZONE)
			and (sseq==5 and seq==3 or sseq==6 and seq==1)
	end
	if c:IsLocation(LOCATION_SZONE) then
		return sseq<5 and (sseq==seq or loc==LOCATION_SZONE and math.abs(sseq-seq)==1)
	end
	if sseq<5 then
		return sseq==seq or loc==LOCATION_MZONE and math.abs(sseq-seq)==1
	else
		return loc==LOCATION_MZONE and (sseq==5 and seq==1 or sseq==6 and seq==3)
	end
end
-- 效果③的发动准备：选择场上1只「氮氧衍生物」作为对象，并确定需要破坏的相邻区域卡片。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.dfilter(chkc) end
	-- 检查场上是否存在可以作为效果对象的「氮氧衍生物」。
	if chk==0 then return Duel.IsExistingTarget(s.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只「氮氧衍生物」作为效果的对象。
	local tc=Duel.SelectTarget(tp,s.dfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
	-- 获取该衍生物前面、后面、相邻区域存在的其他卡片。
	local g=Duel.GetMatchingGroup(s.sfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tc:GetControler(),tc:GetSequence(),tc:GetLocation())
	g:AddCard(tc)
	-- 设置连锁处理中的操作信息为破坏该衍生物及其相邻区域的所有卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果③的效果处理：破坏作为对象的衍生物以及其相邻区域的所有卡片。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「氮氧衍生物」。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 重新获取该衍生物前面、后面、相邻区域存在的其他卡片。
		local g=Duel.GetMatchingGroup(s.sfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,tc,tc:GetControler(),tc:GetSequence(),tc:GetLocation())
		g:AddCard(tc)
		-- 因效果将这些卡片全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
