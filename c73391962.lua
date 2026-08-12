--告死聖徒ルシエラーゴ
-- 效果：
-- 幻想魔族怪兽＋魔法师族·光属性怪兽
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从卡组把1张「蓟花」卡或「罪宝」卡加入手卡。
-- ②：对方场上的怪兽的攻击力·守备力下降自己场上的「蓟花」怪兽数量×500。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组把1张「罪宝」魔法卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、融合召唤成功时检索「蓟花」或「罪宝」卡的效果、降低对方怪兽攻防的永续效果、以及被破坏时检索「罪宝」魔法卡的效果。
function s.initial_effect(c)
	-- 设置融合召唤素材为1只幻想魔族怪兽和1只满足s.mfilter过滤条件（光属性·魔法师族）的怪兽。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ILLUSION),s.mfilter,true)
	c:EnableReviveLimit()
	-- ①：这张卡融合召唤的场合才能发动。从卡组把1张「蓟花」卡或「罪宝」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：对方场上的怪兽的攻击力·守备力下降自己场上的「蓟花」怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组把1张「罪宝」魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.thcon2)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	c:RegisterEffect(e4)
end
-- 融合素材过滤条件：光属性且是魔法师族的怪兽。
function s.mfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)
end
-- 效果①的发动条件：这张卡是融合召唤成功的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检索卡片过滤条件：卡名含有「蓟花」或「罪宝」且能加入手卡的卡。
function s.thfilter(c)
	return c:IsSetCard(0x1bc,0x19e) and c:IsAbleToHand()
end
-- 效果①的发动准备（Target阶段）：检查卡组中是否存在可检索的卡，并向双方玩家宣告将卡组中的卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「蓟花」卡或「罪宝」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation阶段）：从卡组选择1张「蓟花」卡或「罪宝」卡加入手卡，并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「蓟花」卡或「罪宝」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上表侧表示的「蓟花」怪兽。
function s.atkfilter(c)
	return c:IsSetCard(0x1bc) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 计算攻击力/守备力下降的数值：自己场上表侧表示的「蓟花」怪兽数量乘以-500。
function s.val(e,c)
	local tp=e:GetHandlerPlayer()
	-- 获取自己场上所有表侧表示的「蓟花」怪兽。
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	return g:GetCount()*(-500)
end
-- 效果③的发动条件：这张卡被战斗或效果破坏。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 检索卡片过滤条件：卡名含有「罪宝」的魔法卡且能加入手卡。
function s.thfilter2(c)
	return c:IsSetCard(0x19e) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果③的发动准备（Target阶段）：检查卡组中是否存在可检索的「罪宝」魔法卡，并向双方玩家宣告将卡组中的卡加入手卡的操作信息。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「罪宝」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理（Operation阶段）：从卡组选择1张「罪宝」魔法卡加入手卡，并给对方确认。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「罪宝」魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
