--深淵竜アルバ・レナトゥス
-- 效果：
-- 「阿不思的落胤」＋龙族怪兽1只以上
-- 这张卡不能作为融合素材。这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把自己·对方的怪兽区域的上记的卡送去墓地的场合可以从额外卡组特殊召唤。
-- ①：这张卡在同1次的战斗阶段中可以向怪兽作出最多有作为这张卡的融合素材的怪兽数量的攻击。
-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1张「融合」通常魔法卡加入手卡。
function c3410461.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为68468459的怪兽和1到127只龙族怪兽作为融合素材
	aux.AddFusionProcCodeFunRep(c,68468459,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),1,127,true,true)
	-- 添加接触融合特殊召唤规则，通过将自己或对方场上的怪兽送去墓地来特殊召唤
	aux.AddContactFusionProcedure(c,c3410461.cfilter,LOCATION_MZONE,LOCATION_MZONE,Duel.SendtoGrave,REASON_COST)
	-- 这张卡不能用融合召唤以外的方式特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为必须通过融合召唤
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- 这张卡不能作为融合素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤成功时，可以向怪兽作出最多有作为这张卡的融合素材的怪兽数量的攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c3410461.atkop)
	c:RegisterEffect(e2)
	-- 这张卡被送去墓地时，记录一个标记，用于后续效果发动条件
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c3410461.regop)
	c:RegisterEffect(e3)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1张「融合」通常魔法卡加入手卡
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
-- 融合召唤时检查融合素材是否满足条件：至少包含1张阿不思的落胤或至少包含1只龙族怪兽
function c3410461.branded_fusion_check(tp,sg,fc)
	-- 如果融合素材数量少于2张，或者融合素材中包含1张阿不思的落胤和1只龙族怪兽，则满足条件
	return #sg<2 or aux.gffcheck(sg,Card.IsFusionCode,68468459,Card.IsRace,RACE_DRAGON)
end
-- 接触融合的素材过滤函数，判断怪兽是否可以作为代价送去墓地
function c3410461.cfilter(c,fc)
	return c:IsAbleToGraveAsCost() and (c:IsControler(fc:GetControler()) or c:IsFaceup())
end
-- 特殊召唤成功时，根据融合素材数量增加攻击次数
function c3410461.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 增加攻击次数的效果，攻击次数等于融合素材数量减1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(c:GetMaterialCount()-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 被送去墓地时，记录一个标记，用于后续效果发动条件
function c3410461.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(3410461,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果发动条件：该卡在被送去墓地的回合的结束阶段才能发动
function c3410461.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(3410461)>0
end
-- 检索卡组中「融合」通常魔法卡的过滤函数
function c3410461.thfilter(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x46) and c:IsAbleToHand()
end
-- 设置效果目标：从卡组检索1张「融合」通常魔法卡加入手牌
function c3410461.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件：卡组中是否存在至少1张「融合」通常魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3410461.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 发动效果时，选择1张「融合」通常魔法卡加入手牌并确认
function c3410461.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡组中满足条件的1张「融合」通常魔法卡
	local g=Duel.SelectMatchingCard(tp,c3410461.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
