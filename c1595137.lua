--Evolved Daneen
-- 效果：
-- 「返祖小龙 丹宁」+恐龙族怪兽
-- 这张卡特殊召唤的场合：可以从卡组把1张「GMX」卡加入手卡。「遂进龙 丹宁」的这个效果1回合只能使用1次。
-- 自己用「GMX」卡的效果翻卡的场合：可以根据这张卡在何处存在发动以下效果（「遂进龙 丹宁」的每个效果1回合各能使用1次）。
-- ●场上：回复1500基本分。
-- ●墓地：这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册融合召唤手续，注册特殊召唤成功时的检索「GMX」卡的诱发选发效果，以及注册自己翻卡时在场上发动的回复LP效果，和在墓地发动的特殊召唤自身的诱发选发效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续：使用「返祖小龙 丹宁」（卡密码：29927283）与1只恐龙族怪兽作为融合素材。
	aux.AddFusionProcCodeFun(c,29927283,aux.FilterBoolFunction(Card.IsRace,RACE_DINOSAUR),1,true,true)
	-- 这张卡特殊召唤的场合：可以从卡组把1张「GMX」卡加入手卡。「遂进龙 丹宁」的这个效果1回合只能使用1次。
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
	-- 自己用「GMX」卡的效果翻卡的场合：可以根据这张卡在何处存在发动以下效果（「遂进龙 丹宁」的每个效果1回合各能使用1次）。●场上：回复1500基本分。●墓地：这张卡特殊召唤。
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
-- 过滤条件：属于「GMX」卡片且可以加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1dd) and c:IsAbleToHand()
end
-- 检索效果的发动准备与检查：在效果发动时，检查自己卡组中是否存在满足条件的「GMX」卡片。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查自己卡组中是否存在至少1张可以加入手卡的「GMX」卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：包含从卡组将卡片加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组中选择1张「GMX」卡加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选择1只满足过滤条件的「GMX」卡片。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 通过效果将选中的卡片加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示（确认）已加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断翻卡联动效果的发动条件是否满足：触发联动事件的玩家为自己本身。
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp
end
-- 生命值回复效果的发动准备与检查：在效果发动时，将回复目标玩家设定为自己，回复数值设定为1500点。
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁效果的目标玩家设定为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁效果的作用参数（回复量）设定为1500。
	Duel.SetTargetParam(1500)
	-- 设置连锁操作信息：包含自己回复1500点生命值的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1500)
end
-- 生命值回复效果的处理：使目标玩家回复指定的生命值。
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动时设定的目标玩家以及对应的生命值回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以卡片效果使目标玩家回复指定数值的生命值。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 特殊召唤效果的发动准备与检查：在效果发动时，检查自己场上主要的怪兽区域是否有空位，且这张卡在墓地中是否可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查自己场上主要的怪兽区域是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：包含特殊召唤这张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：如果这张卡与触发的连锁相关联，且不受墓地针对效果影响，则将这张卡特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否与当前连锁相关联，且不受「王家长眠之谷」的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
