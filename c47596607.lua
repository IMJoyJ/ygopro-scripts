--摩天楼2－ヒーローシティ
-- 效果：
-- 1回合1次，自己的主要阶段时，选择被战斗破坏送去自己墓地的1只名字带有「元素英雄」的怪兽才能发动。选择的怪兽从墓地特殊召唤。
function c47596607.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：1回合1次，自己的主要阶段时，选择被战斗破坏送去自己墓地的1只名字带有「元素英雄」的怪兽才能发动。选择的怪兽从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47596607,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c47596607.sptg)
	e2:SetOperation(c47596607.spop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的卡片组：名字带有「元素英雄」且因战斗破坏而进入墓地的怪兽
function c47596607.filter(c,e,tp)
	return c:IsSetCard(0x3008) and bit.band(c:GetReason(),REASON_BATTLE)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断效果是否可以发动：场上存在空位且自己墓地存在符合条件的怪兽
function c47596607.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47596607.filter(chkc,e,tp) end
	-- 判断效果是否可以发动：场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断效果是否可以发动：自己墓地存在符合条件的怪兽
		and Duel.IsExistingTarget(c47596607.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽：从自己墓地选择1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c47596607.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动：将选中的怪兽从墓地特殊召唤到场上
function c47596607.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
