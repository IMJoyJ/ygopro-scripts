--暁世竜ダニアン
-- 效果：
-- 「返祖小龙 丹宁」+恐龙族怪兽
-- 这张卡特殊召唤的场合：可以从卡组把1张「GMX」卡加入手卡。「遂进龙 丹宁」的这个效果1回合只能使用1次。
-- 自己用「GMX」卡的效果翻卡的场合：可以根据这张卡在何处存在发动以下效果（「遂进龙 丹宁」的每个效果1回合各能使用1次）。
-- ●场上：回复1500基本分。
-- ●墓地：这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，启用融合召唤限制并设置融合素材为「返祖小龙 丹宁」和1只恐龙族怪兽
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号29927283的怪兽和1只恐龙族怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,29927283,aux.FilterBoolFunction(Card.IsRace,RACE_DINOSAUR),1,true,true)
	-- 创建一个诱发效果，当此卡特殊召唤成功时发动，检索1张「GMX」卡加入手牌
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 创建一个诱发效果，当自己用「GMX」卡的效果翻卡时发动，根据此卡所在位置回复基本分或特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动效果"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.accon)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.accon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选卡组中属于「GMX」系列且能加入手牌的卡片
function s.thfilter(c)
	return c:IsSetCard(0x1dd) and c:IsAbleToHand()
end
-- 设置检索效果的目标，检查卡组中是否存在满足条件的卡片
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将把1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作，选择并把符合条件的卡加入手牌并确认给对手
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对手确认所选卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否为己方使用「GMX」卡的效果翻卡的场合
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp
end
-- 设置回复效果的目标，设定回复1500基本分
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作的目标参数为1500
	Duel.SetTargetParam(1500)
	-- 设置操作信息，表示将回复1500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1500)
end
-- 执行回复效果，使目标玩家回复指定数值的基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复基本分的操作
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 设置墓地特殊召唤效果的目标，检查是否有足够的召唤位置并满足召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤此卡到场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行墓地特殊召唤操作，将此卡特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否与当前连锁相关且未受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
