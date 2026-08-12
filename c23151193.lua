--断罪のディアベルスター
-- 效果：
-- 这个卡名在规则上也当作「罪宝」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把魔法卡和陷阱卡各1张除外才能发动。这张卡从手卡·墓地特殊召唤。
-- ②：自己·对方回合，把基本分支付一半，以对方场上1张卡为对象才能发动。那张卡破坏。那之后，场上有其他的「迪亚贝尔」怪兽卡存在的场合，可以从额外卡组把1只幻想魔族·魔法师族同调怪兽调整特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地把魔法卡和陷阱卡各1张除外才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把基本分支付一半，以对方场上1张卡为对象才能发动。那张卡破坏。那之后，场上有其他的「迪亚贝尔」怪兽卡存在的场合，可以从额外卡组把1只幻想魔族·魔法师族同调怪兽调整特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 魔法卡过滤器，用于检索手卡或墓地中的魔法卡
function s.spcostfilter1(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_SPELL)
end
-- 陷阱卡过滤器，用于检索手卡或墓地中的陷阱卡
function s.spcostfilter2(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_TRAP)
end
-- 判断是否满足①效果的费用条件，即手卡或墓地各存在1张魔法卡和陷阱卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡或墓地是否存在魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter1,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,e:GetHandler())
		-- 判断手卡或墓地是否存在陷阱卡
		and Duel.IsExistingMatchingCard(s.spcostfilter2,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张魔法卡进行除外
	local sg=Duel.SelectMatchingCard(tp,s.spcostfilter1,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,e:GetHandler())
	-- 选择1张陷阱卡进行除外
	local sg2=Duel.SelectMatchingCard(tp,s.spcostfilter2,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选中的魔法卡和陷阱卡除外作为费用
	Duel.Remove(sg+sg2,POS_FACEUP,REASON_COST)
end
-- 判断①效果是否可以发动，即是否有足够的召唤位置并能特殊召唤此卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数，将此卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍然存在于场上并满足特殊召唤条件
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的费用处理函数，支付一半基本分
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半基本分作为费用
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- ②效果的目标选择函数，选择对方场上的1张卡作为破坏对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判断对方场上是否存在可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表示将破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 同调怪兽调整过滤器，用于检索额外卡组中符合条件的幻想魔族·魔法师族同调调整
function s.spfilter(c,e,tp)
	return c:IsAllTypes(TYPE_SYNCHRO+TYPE_MONSTER+TYPE_TUNER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER)
		-- 判断是否有足够的召唤位置来特殊召唤该同调调整
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 迪亚贝尔怪兽过滤器，用于判断场上的迪亚贝尔怪兽是否存在
function s.spconfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x19b) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- ②效果的处理函数，破坏对方卡并可能特殊召唤同调调整
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然存在于场上并成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 判断场上有其他迪亚贝尔怪兽存在
		and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,aux.ExceptThisCard(e))
		-- 判断额外卡组中是否存在符合条件的同调调整
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		-- 询问玩家是否发动特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组中选择1只符合条件的同调调整
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的同调调整特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
