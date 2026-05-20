--E・HERO ブレイヴ・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋4星以下的效果怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡的攻击力上升自己墓地的「新空间侠」怪兽以及「英雄」怪兽数量×100。
-- ②：这张卡战斗破坏对方怪兽时才能发动。把有「元素英雄 新宇侠」的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
function c64655485.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为「元素英雄 新宇侠」和1只满足过滤条件（4星以下的效果怪兽）的怪兽。
	aux.AddFusionProcCodeFun(c,89943723,c64655485.ffilter,1,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过融合召唤的方式特殊召唤。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升自己墓地的「新空间侠」怪兽以及「英雄」怪兽数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c64655485.atkval)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。把有「元素英雄 新宇侠」的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64655485,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动条件为这张卡战斗破坏对方怪兽。
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c64655485.thtg)
	e3:SetOperation(c64655485.thop)
	c:RegisterEffect(e3)
end
c64655485.material_setcode=0x8
-- 融合素材过滤函数：等级4以下且在场上/墓地作为融合素材时是效果怪兽。
function c64655485.ffilter(c)
	return c:IsLevelBelow(4) and c:IsFusionType(TYPE_EFFECT)
end
-- 攻击力上升过滤函数：属于「英雄」或「新空间侠」系列且是怪兽卡。
function c64655485.atkfilter(c)
	return c:IsSetCard(0x8,0x1f) and c:IsType(TYPE_MONSTER)
end
-- 攻击力上升数值计算函数：获取自己墓地满足过滤条件的怪兽数量并乘以100。
function c64655485.atkval(e,c)
	-- 返回自己墓地中「新空间侠」及「英雄」怪兽的数量乘以100的数值。
	return Duel.GetMatchingGroupCount(c64655485.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*100
end
-- 检索卡片过滤函数：记述有「元素英雄 新宇侠」卡名的魔法·陷阱卡，且能加入手卡。
function c64655485.thfilter(c)
	-- 过滤条件：卡片文本记述有「元素英雄 新宇侠」卡号，且是魔法或陷阱卡，并且可以加入手卡。
	return aux.IsCodeListed(c,89943723) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索效果的发动准备（Target）：检查卡组中是否存在满足条件的卡，并设置将卡组的1张卡加入手卡的操作信息。
function c64655485.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时的可行性检测：判断自己卡组中是否存在至少1张满足过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c64655485.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统宣告本次效果处理包含“将卡组的1张卡加入手卡”的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的效果处理（Operation）：让玩家从卡组选择1张满足条件的卡加入手卡，并给对方确认。
function c64655485.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端向玩家提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,c64655485.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
