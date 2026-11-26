--見えざる手ガイガス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：抽卡阶段以外让对方手卡有卡加入的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从对方卡组上面把3张卡翻开。可以从那之中选1只怪兽在自己场上特殊召唤。剩余回到卡组。
-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册①对方在抽卡阶段以外入手卡片时手卡特召的诱发效果、②己方主要阶段翻对方卡组顶3张并抢先特召1只怪兽的起动效果，以及③双方进行战斗时相互战破抗性的永续效果
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：抽卡阶段以外让对方手卡有卡加入的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己主要阶段才能发动。从对方卡组上面把3张卡翻开。可以从那之中选1只怪兽在自己场上特殊召唤。剩余回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤当前控制者为指定玩家tp的卡片
function s.cfilter(c,tp)
	return c:IsControler(tp)
end
-- 检查①效果发动条件：当前不是抽卡阶段，且本次加入手卡事件中存在加入对方手卡的卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段不为抽卡阶段，且事件卡片组eg中至少有1张卡进入了对方手卡
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 发动前确认己方怪兽区有空位且手卡的此卡可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方怪兽区是否至少有1个可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记将此卡自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若此卡仍在当前连锁中，将其从手卡表侧表示特殊召唤到己方场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将此卡以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③战破抗性对象过滤函数：匹配此卡自身以及正与此卡进行战斗的对方怪兽
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- ②效果发动前确认对方卡组至少有3张卡
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方卡组剩余卡片数量是否大于2（即至少3张）
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>2 end
end
-- 过滤可特殊召唤到己方场上的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果处理：翻开对方卡组顶3张卡，若己方场上有空位且其中存在可特召怪兽则可选择1只特召到己方场上，之后洗切对方卡组
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 翻开并向双方确认对方卡组最上面的3张卡
	Duel.ConfirmDecktop(1-tp,3)
	-- 获取对方卡组最上面刚翻开的3张卡
	local g=Duel.GetDecktopGroup(1-tp,3)
	-- 检查己方怪兽区是否至少有1个可用空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:IsExists(s.spfilter,1,nil,e,tp)
		-- 询问己方玩家是否从翻开的卡中特殊召唤1只怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 向己方发送从翻开的对方卡组卡片中选择要特殊召唤的怪兽的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选中的对方怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 洗切对方卡组，将剩余翻开的卡回到对方卡组
	Duel.ShuffleDeck(1-tp)
end
