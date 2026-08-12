--占術姫ビブリオムーサ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡被解放送去墓地的场合才能发动。这张卡里侧守备表示特殊召唤。
-- ②：这张卡反转的场合才能发动。从卡组把「占术姬 书本缪斯」以外的1只「占术姬」怪兽和1张仪式魔法卡加入手卡。
-- ③：只要这张卡在怪兽区域存在，自己场上的仪式怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册①②③效果及抗性
function s.initial_effect(c)
	-- ①：这张卡被解放送去墓地的场合才能发动。这张卡里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡反转的场合才能发动。从卡组把「占术姬 书本缪斯」以外的1只「占术姬」怪兽和1张仪式魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，自己场上的仪式怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.imetg)
	-- 设置不受对方卡片效果破坏的影响
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置不能成为对方卡片效果的对象
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
-- 检测这张卡是否因被解放而送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_RELEASE)
end
-- ①效果（里侧守备表示特殊召唤）的发动准备与合法性检测
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，且这张卡是否可以以里侧守备表示特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置连锁信息，表明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的实际处理：将自身里侧守备表示特殊召唤，并向对方确认
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e)
		-- 将这张卡以里侧守备表示特殊召唤到自己场上
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 让对方玩家确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,c)
	end
end
-- 过滤卡组中「占术姬 书本缪斯」以外的「占术姬」怪兽，且卡组中还存在可检索的仪式魔法卡
function s.thfilter(c,tp)
	return not c:IsCode(id)
		and c:IsSetCard(0xcc) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand()
		-- 检查卡组中是否存在除当前选定卡片以外的仪式魔法卡
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,c)
end
-- 过滤仪式魔法卡
function s.thfilter2(c)
	return bit.band(c:GetType(),0x82)==0x82 and c:IsAbleToHand()
end
-- ②效果（检索怪兽和仪式魔法）的发动准备与合法性检测
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「占术姬」怪兽和仪式魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置连锁信息，表明此效果包含从卡组将卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：从卡组将1只「占术姬」怪兽和1张仪式魔法卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只「占术姬 书本缪斯」以外的「占术姬」怪兽
	local g1=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g1:GetCount()>0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张仪式魔法卡（排除已选的怪兽卡）
		local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,g1:GetFirst())
		g1:Merge(g2)
		-- 将选中的两张卡加入玩家手牌
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g1)
	end
end
-- 过滤自己场上的仪式怪兽，使其获得抗性
function s.imetg(e,c)
	return c:IsType(TYPE_RITUAL)
end
