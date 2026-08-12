--E・HERO The シャイニング
-- 效果：
-- 名字带有「元素英雄」的怪兽＋光属性怪兽
-- 这张卡不用融合召唤不能特殊召唤。这张卡的攻击力上升从游戏中除外的自己的名字带有「元素英雄」的怪兽数量×300的数值。这张卡从场上送去墓地时，可以选择从游戏中除外的最多2只自己的名字带有「元素英雄」的怪兽加入手卡。
function c22061412.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用1只名字带有「元素英雄」的怪兽和1只光属性怪兽作为融合素材
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
	-- 设置此效果为不能用融合召唤以外的方式召唤的特殊召唤条件
	e4:SetValue(aux.fuslimit)
	c:RegisterEffect(e4)
end
c22061412.material_setcode=0x8
-- 定义用于计算攻击力的过滤函数，筛选场上正面表示的名字带有「元素英雄」的怪兽
function c22061412.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER)
end
-- 定义攻击力计算函数，返回除外区中名字带有「元素英雄」的怪兽数量乘以300的值
function c22061412.atkup(e,c)
	-- 获取除外区中满足过滤条件的怪兽数量并乘以300作为攻击力提升值
	return Duel.GetMatchingGroupCount(c22061412.atkfilter,c:GetControler(),LOCATION_REMOVED,0,nil)*300
end
-- 设置效果发动条件，确保该卡是从场上送去墓地时触发
function c22061412.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义用于选择目标的过滤函数，筛选除外区中正面表示的名字带有「元素英雄」的怪兽且能加入手牌
function c22061412.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标选择函数，判断是否能选择1到2只除外区中的名字带有「元素英雄」的怪兽作为目标
function c22061412.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c22061412.filter(chkc) end
	-- 检查是否满足选择目标的条件，即除外区中是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c22061412.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1到2只除外区中的名字带有「元素英雄」的怪兽作为目标
	local g=Duel.SelectTarget(tp,c22061412.filter,tp,LOCATION_REMOVED,0,1,2,nil)
	-- 设置连锁操作信息，指定将选择的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 设置效果处理函数，将符合条件的目标怪兽加入手牌
function c22061412.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将符合条件的目标怪兽以效果原因送入手牌
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
