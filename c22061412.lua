--E・HERO The シャイニング
-- 效果：
-- 名字带有「元素英雄」的怪兽＋光属性怪兽
-- 这张卡不用融合召唤不能特殊召唤。这张卡的攻击力上升从游戏中除外的自己的名字带有「元素英雄」的怪兽数量×300的数值。这张卡从场上送去墓地时，可以选择从游戏中除外的最多2只自己的名字带有「元素英雄」的怪兽加入手卡。
function c22061412.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡设定融合召唤手续，融合素材为名字带有「元素英雄」的怪兽和光属性怪兽各1只（通过过滤条件分别检查系列字段0x3008与光属性）。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x3008),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_LIGHT),true)
	-- 这张卡从场上送去墓地时，可以选择从游戏中除外的最多2只自己的名字带有「元素英雄」的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22061412,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c22061412.thcon)
	e2:SetTarget(c22061412.thtg)
	e2:SetOperation(c22061412.thop)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力上升从游戏中除外的自己的名字带有「元素英雄」的怪兽数量×300的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c22061412.atkup)
	c:RegisterEffect(e3)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定值设为aux.fuslimit，使得只有融合召唤（SUMMON_TYPE_FUSION）才能特殊召唤这张卡，其他特殊召唤方式均被禁止。
	e4:SetValue(aux.fuslimit)
	c:RegisterEffect(e4)
end
c22061412.material_setcode=0x8
-- 定义攻击力上升的计数过滤器：筛选出除外区表侧表示、名字带有「元素英雄」的怪兽卡。
function c22061412.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力上升值：统计这张卡控制者除外区中满足atkfilter的怪兽数量，再乘以300作为上升数值。
function c22061412.atkup(e,c)
	-- 返回统计到的除外区元素英雄怪兽数量×300，作为EFFECT_UPDATE_ATTACK的增幅值。
	return Duel.GetMatchingGroupCount(c22061412.atkfilter,c:GetControler(),LOCATION_REMOVED,0,nil)*300
end
-- 判定这张卡被送去墓地前是否位于场上，只有从场上（怪兽区）被送去墓地时，才满足该诱发效果的发动条件。
function c22061412.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义可回收目标的过滤器：自己的除外区表侧表示、名字带有「元素英雄」的怪兽，且当前能够被加入手卡。
function c22061412.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：先验证连锁中的对象是否合法，再检查自己除外区存在至少1只可回收的怪兽，接着提示玩家选择1～2只并登记为效果对象，同时设置操作信息为加入手卡。
function c22061412.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c22061412.filter(chkc) end
	-- 在发动合法性检查时，确认自己的除外区至少存在1只满足filter条件的怪兽，否则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c22061412.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向当前玩家发出选择提示（HINTMSG_ATOHAND），用于选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从自己的除外区选择1～2只满足filter条件（且可成为对象）的怪兽，并把这些卡设置为本次连锁的效果对象。
	local g=Duel.SelectTarget(tp,c22061412.filter,tp,LOCATION_REMOVED,0,1,2,nil)
	-- 登记操作信息，声明本次连锁的效果将把已选择的对象卡加入手卡（CATEGORY_TOHAND），目标组为g，数量为g:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理阶段：从连锁信息中取得对象卡组，过滤出仍与该效果关联的卡，将它们加入其持有者的手卡；不关联的卡不予处理。
function c22061412.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的效果对象卡组（即发动时被选择为对象的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍与效果关联的对象卡送入其持有者的手卡，移动原因是效果处理（REASON_EFFECT）。
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
