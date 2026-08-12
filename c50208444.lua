--精霊世妃 ドリアード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，不能对应这些效果的发动让魔法·陷阱·怪兽的效果发动。
-- ①：这张卡在手卡存在，自己墓地的怪兽的属性是3种类以上的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽和这张卡特殊召唤。
-- ②：自己墓地的怪兽的属性是3种类以上的场合才能发动。相同属性的怪兽不在自己的场上·墓地存在的1只怪兽从卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（手卡发动的起动效果，取自己墓地1只怪兽为对象，与这张卡一起特殊召唤，1回合1次）和②效果（场上发动的起动效果，从卡组特殊召唤1只怪兽，1回合1次）
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡存在，自己墓地的怪兽的属性是3种类以上的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽和这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己墓地的怪兽的属性是3种类以上的场合才能发动。相同属性的怪兽不在自己的场上·墓地存在的1只怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 发动条件：检索自己墓地的全部怪兽，其属性种类在3种以上时才能发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己墓地中所有怪兽卡组成的卡组
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetClassCount(Card.GetAttribute)>=3
end
-- 特殊召唤过滤条件：该卡可以被特殊召唤（不无视召唤条件和苏生限制）
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的对象设定：先校验连锁对象是否在自己墓地且可特殊召唤；再判定发动条件：未受「青眼精灵龙」效果影响、自己主要怪兽区有2个以上空格、这张卡可以特殊召唤，且自己墓地存在1只可特殊召唤并可作为对象的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 并且自己主要怪兽区可用的空格数大于1（需要能同时特殊召唤2只怪兽）
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且自己墓地存在至少1只满足特殊召唤条件且能成为效果对象的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示消息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足特殊召唤条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(c)
	-- 设置操作信息：本次连锁确定要把2只怪兽（对象怪兽和这张卡）特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
	-- 设置连锁限制：不能对应这个效果的发动让魔法·陷阱·怪兽的效果发动
	Duel.SetChainLimit(aux.FALSE)
end
-- ①效果处理：取得对象怪兽，若这张卡和对象怪兽都与连锁关联、对象不受王家长眠之谷影响、两者都可以特殊召唤、未受「青眼精灵龙」效果影响且主要怪兽区有2个以上空格，则将两只怪兽一起以表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的效果对象（自己墓地选择的1只怪兽）
	local tc=Duel.GetFirstTarget()
	-- 若这张卡与对象怪兽仍与当前连锁关联，且对象怪兽不受王家长眠之谷的影响
	if c:IsRelateToChain() and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		local g=Group.FromCards(c,tc)
		-- 将这张卡和对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 属性过滤条件：卡在自己场上表侧表示存在或在自己墓地存在，且是指定属性的怪兽
function s.attfilter(c,att)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAttribute(att)
end
-- ②效果的特殊召唤过滤条件：该卡可以特殊召唤，且自己的场上·墓地不存在与其相同属性的怪兽
function s.spfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且自己的场上·墓地不存在与该卡相同属性的怪兽
		and not Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c:GetAttribute())
end
-- ②效果的发动条件判定：自己主要怪兽区有1个以上空格，且卡组中存在满足条件的可特殊召唤的怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：自己主要怪兽区可用的空格数大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中存在至少1只满足条件（可特殊召唤且属性在自己场上·墓地不存在相同属性怪兽）的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁确定要从卡组特殊召唤1只怪兽（对象在效果处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置连锁限制：不能对应这个效果的发动让魔法·陷阱·怪兽的效果发动
	Duel.SetChainLimit(aux.FALSE)
end
-- ②效果处理：若主要怪兽区没有空格则中断处理；否则提示并从卡组选择1只满足条件的怪兽，将其以表侧表示特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己主要怪兽区没有可用空格则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示消息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽（可特殊召唤且属性在自己场上·墓地没有相同属性的怪兽）
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
