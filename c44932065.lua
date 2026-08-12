--捕食植物ビブリスプ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡被送去墓地的场合才能发动。从卡组把「捕食植物 腺毛草胡蜂」以外的1只「捕食植物」怪兽加入手卡。
-- ②：这张卡在墓地存在，场上的怪兽有捕食指示物放置中的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（被送去墓地时诱发选发、延迟处理的卡组检索加入手卡效果，1回合1次）和②效果（墓地存在的起动效果，将自身特殊召唤，1回合1次）
function c44932065.initial_effect(c)
	-- ①：这张卡被送去墓地的场合才能发动。从卡组把「捕食植物 腺毛草胡蜂」以外的1只「捕食植物」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44932065,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,44932065)
	e1:SetTarget(c44932065.thtg)
	e1:SetOperation(c44932065.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，场上的怪兽有捕食指示物放置中的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44932065,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,44932065+o)
	e2:SetCondition(c44932065.spcon)
	e2:SetTarget(c44932065.sptg)
	e2:SetOperation(c44932065.spop)
	c:RegisterEffect(e2)
end
c44932065.mentioned_counter={
	[0x1041]=true,
}
-- 过滤函数：筛选「捕食植物」字段的、可以加入手卡的怪兽，且不能是「捕食植物 腺毛草胡蜂」本身
function c44932065.thfilter(c)
	return c:IsSetCard(0x10f3) and c:IsType(TYPE_MONSTER) and not c:IsCode(44932065) and c:IsAbleToHand()
end
-- ①效果的对象检查与操作信息设定：确认卡组存在可检索的怪兽，并声明本次连锁将从卡组把1张卡加入手卡
function c44932065.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只满足条件的「捕食植物」怪兽（能否发动的判定）
	if chk==0 then return Duel.IsExistingMatchingCard(c44932065.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本连锁将从卡组把1张卡加入手卡（供王家长眠之谷等检测）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：让玩家从卡组选择1只满足条件的「捕食植物」怪兽，将其加入手卡，并给对方确认
function c44932065.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1只满足条件的「捕食植物」怪兽（「捕食植物 腺毛草胡蜂」以外）
	local g=Duel.SelectMatchingCard(tp,c44932065.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡以效果的原因加入持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：筛选正面表示且放置有捕食指示物的怪兽
function c44932065.cfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- ②效果的发动条件：这张卡在墓地存在，且双方场上存在放置有捕食指示物的怪兽
function c44932065.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方主要怪兽区域是否存在至少1只正面表示且放置有捕食指示物的怪兽
	return Duel.IsExistingMatchingCard(c44932065.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ②效果的对象检查：确认自己主要怪兽区域有空位且这张卡可以特殊召唤
function c44932065.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本连锁将把这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：这张卡与效果关联时将这张卡特殊召唤，成功后登记离场时除外的永续效果
function c44932065.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与该效果关联，并把这张卡以正面表示特殊召唤到自己场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
