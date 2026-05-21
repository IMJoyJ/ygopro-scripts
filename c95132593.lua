--見えざる手ガイガス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：抽卡阶段以外让对方手卡有卡加入的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从对方卡组上面把3张卡翻开。可以从那之中选1只怪兽在自己场上特殊召唤。剩余回到卡组。
-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 初始化函数，注册卡片的效果
function s.initial_effect(c)
	-- ①：抽卡阶段以外让对方手卡有卡加入的场合才能发动。这张卡从手卡特殊召唤。
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
	-- ②：自己主要阶段才能发动。从对方卡组上面把3张卡翻开。可以从那之中选1只怪兽在自己场上特殊召唤。剩余回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤加入手牌的卡片是否属于指定玩家的辅助函数
function s.cfilter(c,tp)
	return c:IsControler(tp)
end
-- 效果①的发动条件判定函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前不是抽卡阶段，且有对方手牌的卡加入
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 效果①的发动准备与合法性检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的执行函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③战斗不破坏的适用对象判定函数
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 效果②的发动准备与合法性检测函数
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定对方卡组上方的卡片数量是否至少有3张
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>2 end
end
-- 过滤翻开的卡片中是否包含可以特殊召唤的怪兽的辅助函数
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的执行函数
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认对方卡组最上方的3张卡
	Duel.ConfirmDecktop(1-tp,3)
	-- 获取对方卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(1-tp,3)
	-- 判定自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:IsExists(s.spfilter,1,nil,e,tp)
		-- 询问玩家是否选择进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 洗切对方的卡组
	Duel.ShuffleDeck(1-tp)
end
