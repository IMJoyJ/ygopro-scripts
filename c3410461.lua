--深淵竜アルバ・レナトゥス
-- 效果：
-- 「阿不思的落胤」＋龙族怪兽1只以上
-- 这张卡不能作为融合素材。这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把自己·对方的怪兽区域的上记的卡送去墓地的场合可以从额外卡组特殊召唤。
-- ①：这张卡在同1次的战斗阶段中可以向怪兽作出最多有作为这张卡的融合素材的怪兽数量的攻击。
-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1张「融合」通常魔法卡加入手卡。
function c3410461.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册融合召唤手续：融合素材包含卡号68468459（「阿不思的落胤」）1只，加上满足龙族条件的怪兽1至127只。
	aux.AddFusionProcCodeFunRep(c,68468459,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),1,127,true,true)
	-- 为这张卡注册接触融合手续：无需融合魔法，从双方怪兽区选择满足cfilter条件的怪兽作为素材，将其送入墓地（REASON_COST）来从额外卡组特殊召唤这张卡。
	aux.AddContactFusionProcedure(c,c3410461.cfilter,LOCATION_MZONE,LOCATION_MZONE,Duel.SendtoGrave,REASON_COST)
	-- 这张卡用融合召唤以及以下方法才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定函数为aux.fuslimit，即仅允许通过融合召唤方式特殊召唤这张卡，防止其他非正规召唤方式出场。
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- 这张卡不能作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡在同1次的战斗阶段中可以向怪兽作出最多有作为这张卡的融合素材的怪兽数量的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c3410461.atkop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c3410461.regop)
	c:RegisterEffect(e3)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1张「融合」通常魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(3410461,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(c3410461.thcon)
	e4:SetTarget(c3410461.thtg)
	e4:SetOperation(c3410461.thop)
	c:RegisterEffect(e4)
end
-- 定义素材检查函数：校验一组融合素材是否满足“「阿不思的落胤」＋龙族怪兽”的组合要求；素材少于2张时不作非法判定，否则必须同时包含卡号68468459的「阿不思的落胤」和龙族怪兽。
function c3410461.branded_fusion_check(tp,sg,fc)
	-- 若素材组数量小于2则合法，否则用aux.gffcheck检查素材组中是否同时存在卡号68468459的怪兽和龙族怪兽，以确认融合素材组合合法。
	return #sg<2 or aux.gffcheck(sg,Card.IsFusionCode,68468459,Card.IsRace,RACE_DRAGON)
end
-- 定义接触融合素材过滤条件：素材必须能在作为COST时被送去墓地，并且是该卡控制者控制的怪兽或表侧表示的怪兽（即己方怪兽任意表示形式，对方怪兽须表侧表示）。
function c3410461.cfilter(c,fc)
	return c:IsAbleToGraveAsCost() and (c:IsControler(fc:GetControler()) or c:IsFaceup())
end
-- 特殊召唤成功时的处理：根据作为融合素材的怪兽数量，为这张卡赋予额外攻击怪兽次数（素材数量-1），实现同一战斗阶段最多攻击素材数量次的怪兽效果；该效果在卡片离场等标准时机重置。
function c3410461.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：这张卡在同1次的战斗阶段中可以向怪兽作出最多有作为这张卡的融合素材的怪兽数量的攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(c:GetMaterialCount()-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 这张卡被送去墓地时的处理：为本张卡注册一个标志3410461，持续到本回合结束阶段，用于记录“这张卡在本回合被送去墓地”这一事实，作为②效果的发动条件。
function c3410461.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(3410461,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ②效果的发动条件：检查这张卡是否带有标志3410461，即本回合是否被送去墓地，且当前为结束阶段，满足才可发动。
function c3410461.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(3410461)>0
end
-- 定义检索过滤条件：目标是卡名含有「融合」字段（0x46）的通常魔法卡（类型符合TYPE_SPELL判定），并且能够加入手牌。
function c3410461.thfilter(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x46) and c:IsAbleToHand()
end
-- 设置②效果发动的目标条件：在发动时判断卡组中是否存在满足thfilter的检索对象；存在则通过，并登记后续从卡组加入手牌的操作信息。
function c3410461.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0为发动前的合法性检查：检索卡组，确认存在至少1张满足thfilter条件的「融合」通常魔法卡，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c3410461.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：该效果处理时会将1张卡从卡组加入持有者的手牌，属于检索效果（CATEGORY_TOHAND+CATEGORY_SEARCH）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组选择1张满足thfilter条件的「融合」通常魔法卡加入手牌，并向对方玩家展示，然后结束处理。
function c3410461.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，要求玩家选择一张要加入手牌的卡（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张满足thfilter条件的「融合」通常魔法卡（必须正好选择1张），临时存入g。
	local g=Duel.SelectMatchingCard(tp,c3410461.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将所选卡片加入其持有者的手牌，原因记录为效果处理（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家确认，保证信息公开。
		Duel.ConfirmCards(1-tp,tc)
	end
end
