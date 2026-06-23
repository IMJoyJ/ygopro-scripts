--幻影騎士団ディケイクローク
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，把手卡1张其他的「幻影骑士团」卡给对方观看才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「幻影骑士团」怪兽加入手卡。
-- ③：把墓地的这张卡除外，以自己场上1只超量怪兽为对象才能发动。那只超量怪兽在这个回合可以作为和自身的阶级相同数值的等级的怪兽来成为超量召唤的素材。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，把手卡1张其他的「幻影骑士团」卡给对方观看才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「幻影骑士团」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外，以自己场上1只超量怪兽为对象才能发动。那只超量怪兽在这个回合可以作为和自身的阶级相同数值的等级的怪兽来成为超量召唤的素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"赋予超量等级"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id+o*2)
	-- 设置效果③（墓地除外赋予超量等级）的发动代价为将墓地的这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.xyztg)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
end
-- 过滤手牌中「幻影骑士团」卡片的非公开状态条件
function s.spcfilter(c)
	return c:IsSetCard(0x10db) and not c:IsPublic()
end
-- 效果①（手卡特殊召唤）的发动代价与展示卡片函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动代价检查的第一阶段，判断手牌中是否存在除了这张卡以外的「幻影骑士团」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 向当前玩家提示选择给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家在手牌中选择1张除这张卡以外的「幻影骑士团」卡片
	local cg=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 向对方玩家展示选择的「幻影骑士团」卡片
	Duel.ConfirmCards(1-tp,cg)
	-- 洗切玩家的手卡
	Duel.ShuffleHand(tp)
end
-- 效果①（手卡特殊召唤）的发动判定与效果分类设置函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动判定的第一阶段，检查自己场上是否存在可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的连锁操作信息，为特殊召唤手牌中的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①（手卡特殊召唤）的效果处理主函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤卡组中「幻影骑士团」怪兽的检索条件
function s.thfilter(c)
	return c:IsSetCard(0x10db) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②（召唤·特殊召唤检索怪兽）的发动判定与效果分类设置函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动判定的第一阶段，检查卡组中是否存在可以加入手牌的「幻影骑士团」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的连锁操作信息，为从卡组检索卡片
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②（召唤·特殊召唤检索怪兽）的效果处理主函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家在卡组中选择1只「幻影骑士团」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌 of the怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤场上表侧表示超量怪兽的条件
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果③（墓地除外赋予超量等级）的发动判定与效果目标设置函数
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.xyzfilter(chkc) end
	-- 在发动判定的第一阶段，检查自己场上是否存在可以作为效果对象的表侧表示超量怪兽
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向当前玩家提示选择效果作用的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上的1只超量怪兽作为效果对象，并将其注册为连锁对象
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果③（墓地除外赋予超量等级）的效果处理主函数
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果指向的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 那只超量怪兽在这个回合可以作为和自身的阶级相同数值的等级的怪兽来成为超量召唤的素材。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))  --"「幻影骑士团 衰亡斗篷」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_XYZ_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(s.xyzlv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 设置怪兽进行超量召唤时，将其视为与自身的阶级相同数值的等级
function s.xyzlv(e,c,rc)
	return c:GetRank()
end
