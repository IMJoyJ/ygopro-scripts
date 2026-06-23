--銀河眼の時源竜
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，场上有龙族超量怪兽存在的场合才能发动。这张卡从手卡往自己或对方的场上特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合发动。这张卡的原本持有者从自身卡组把1张「时空」魔法·陷阱卡加入手卡。
-- ③：自己或对方的龙族超量怪兽的攻击宣言时发动。把场上的这张卡作为那只怪兽的超量素材。
local s,id,o=GetID()
-- 创建并注册三个效果，分别对应①②③效果
function s.initial_effect(c)
	-- ①：自己·对方回合，场上有龙族超量怪兽存在的场合才能发动。这张卡从手卡往自己或对方的场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合发动。这张卡的原本持有者从自身卡组把1张「时空」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：自己或对方的龙族超量怪兽的攻击宣言时发动。把场上的这张卡作为那只怪兽的超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"变成超量素材"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.mttg)
	e4:SetOperation(s.mtop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否存在龙族超量怪兽
function s.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 判断是否满足①效果的发动条件：场上有龙族超量怪兽存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足①效果的发动条件：场上有龙族超量怪兽存在
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 设置①效果的目标：特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断①效果是否可以发动：自己场上是否有空位且该卡可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断①效果是否可以发动：对方场上是否有空位且该卡可以特殊召唤
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) end
	-- 设置①效果的连锁操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数：根据选择将该卡特殊召唤到自己或对方场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or (not c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)) then return end
	-- 判断自己场上是否有空位且该卡可以特殊召唤
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 判断对方场上是否有空位且该卡可以特殊召唤
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	-- 让玩家选择将该卡特殊召唤到自己或对方场上
	local toplayer=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,3),tp},  --"往自己场上特殊召唤"
		{b2,aux.Stringid(id,4),1-tp})  --"往对方场上特殊召唤"
	if toplayer~=nil then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,toplayer,false,false,POS_FACEUP)
	else
		-- 判断是否两个场上都没有空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then
			-- 若两个场上都没有空位，则将该卡送入墓地
			Duel.SendtoGrave(c,REASON_RULE)
		end
	end
end
-- 过滤函数，用于检索「时空」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x1b4) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置②效果的目标：检索卡组中的「时空」魔法·陷阱卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local hp=e:GetHandler():GetOwner()
	if chk==0 then return true end
	-- 设置②效果的连锁操作信息：将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,hp,LOCATION_DECK)
end
-- ②效果的处理函数：检索并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local hp=e:GetHandler():GetOwner()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「时空」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(hp,s.thfilter,hp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到该卡
		Duel.ConfirmCards(1-hp,g)
	end
end
-- 设置③效果的目标：攻击宣言时将该卡作为超量素材
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击怪兽
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsType(TYPE_XYZ) and at:IsOnField() and at:IsRace(RACE_DRAGON) end
end
-- ③效果的处理函数：将该卡叠放至攻击怪兽上
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击怪兽
	local at=Duel.GetAttacker()
	if c:IsRelateToEffect(e) and c:IsCanOverlay()
		and at:IsRelateToBattle() and not at:IsImmuneToEffect(e) then
		-- 将该卡叠放至攻击怪兽上
		Duel.Overlay(at,Group.FromCards(c))
	end
end
