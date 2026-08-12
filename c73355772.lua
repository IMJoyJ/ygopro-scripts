--教導の雷霆フルルドリス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从手卡特殊召唤的场合才能发动。从卡组把1张「教导」陷阱卡在自己场上盖放。这个效果盖放的卡只要攻击力2500以上的融合·同调·超量·连接怪兽的其中任意种在对方场上存在，在盖放的回合也能发动。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡特殊召唤的场合才能发动。从卡组把1张「教导」陷阱卡在自己场上盖放。这个效果盖放的卡只要攻击力2500以上的融合·同调·超量·连接怪兽的其中任意种在对方场上存在，在盖放的回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：从额外卡组特殊召唤的怪兽
function s.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果①的发动条件：自己或对方的主要阶段，且场上存在从额外卡组特殊召唤的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段
	return Duel.IsMainPhase()
		-- 检查双方场上是否存在至少1只从额外卡组特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果①的发动准备与合法性检查（怪兽区域有空位且自身可以特殊召唤）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：将手牌中的这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：这张卡是从手牌特殊召唤成功的场合
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤条件：卡组中可以盖放的「教导」陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x145) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果②的发动准备与合法性检查（魔法与陷阱区域有空位且卡组有可盖放的卡）
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于盖放魔法·陷阱卡的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己卡组是否存在满足条件的「教导」陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②的处理：从卡组选1张「教导」陷阱卡在场上盖放，并赋予满足条件时在盖放回合发动的效果
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 若魔法与陷阱区域没有空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「教导」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功将选中的卡片在场上盖放
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡只要攻击力2500以上的融合·同调·超量·连接怪兽的其中任意种在对方场上存在，在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"适用「教导的雷霆 弗勒德莉丝」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(s.actcon)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：对方场上表侧表示、攻击力2500以上且是融合·同调·超量·连接怪兽的怪兽
function s.cfilter2(c)
	return c:IsFaceup() and c:IsAttackAbove(2500) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 盖放回合发动的条件判断函数
function s.actcon(e)
	-- 检查对方场上是否存在满足条件的攻击力2500以上的融合·同调·超量·连接怪兽
	return Duel.IsExistingMatchingCard(s.cfilter2,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
