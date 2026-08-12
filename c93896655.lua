--聖天樹の幼精
-- 效果：
-- 4星以下的植物族怪兽1只
-- ①：这张卡用「圣种之地灵」为素材在额外怪兽区域连接召唤的场合才能发动。从卡组把1张「圣蔓」魔法·陷阱卡加入手卡。
-- ②：这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
-- ③：1回合1次，自己因战斗·效果受到伤害的场合才能发动。自己基本分回复那个数值，从额外卡组把1只「圣蔓」怪兽特殊召唤。
function c93896655.initial_effect(c)
	-- 设置连接召唤手续，需要1只满足过滤条件的怪兽作为素材
	aux.AddLinkProcedure(c,c93896655.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：这张卡用「圣种之地灵」为素材在额外怪兽区域连接召唤的场合才能发动。从卡组把1张「圣蔓」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93896655,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c93896655.thcon)
	e1:SetTarget(c93896655.thtg)
	e1:SetOperation(c93896655.thop)
	c:RegisterEffect(e1)
	-- 用「圣种之地灵」为素材
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c93896655.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己因战斗·效果受到伤害的场合才能发动。自己基本分回复那个数值，从额外卡组把1只「圣蔓」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(93896655,1))  --"回复并特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c93896655.spcon)
	e4:SetTarget(c93896655.sptg)
	e4:SetOperation(c93896655.spop)
	c:RegisterEffect(e4)
end
-- 过滤连接素材：4星以下的植物族怪兽
function c93896655.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_PLANT)
end
-- 检查连接素材中是否存在「圣种之地灵」，并为效果1设置对应的Label值
function c93896655.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,27520594) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 检查效果1的发动条件：连接召唤成功、在额外怪兽区域且使用了「圣种之地灵」作为素材
function c93896655.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetSequence()>4 and e:GetLabel()==1
end
-- 过滤卡组中可以加入手牌的「圣蔓」魔法·陷阱卡
function c93896655.thfilter(c)
	return c:IsSetCard(0x1158) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果1的发动准备：检查卡组中是否存在可检索的卡，并设置操作信息
function c93896655.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「圣蔓」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c93896655.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果1的效果处理：从卡组选择1张「圣蔓」魔法·陷阱卡加入手牌并给对方确认
function c93896655.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「圣蔓」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c93896655.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤额外卡组中可以特殊召唤的「圣蔓」怪兽
function c93896655.spfilter(c,e,tp)
	-- 检查该卡是否为「圣蔓」怪兽、是否可以特殊召唤，以及额外卡组特殊召唤的可用区域是否大于0
	return c:IsSetCard(0x1158) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 检查效果3的发动条件：自己因战斗或效果受到伤害
function c93896655.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 效果3的发动准备：检查额外卡组是否存在可特殊召唤的「圣蔓」怪兽，并设置特殊召唤的操作信息
function c93896655.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在至少1张满足过滤条件的「圣蔓」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c93896655.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果3的效果处理：自己基本分回复受到的伤害数值，并从额外卡组特殊召唤1只「圣蔓」怪兽
function c93896655.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试回复与受到的伤害相同的基本分，若成功回复则继续处理
	if Duel.Recover(tp,ev,REASON_EFFECT)~=0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1张满足过滤条件的「圣蔓」怪兽
		local g=Duel.SelectMatchingCard(tp,c93896655.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
