--古生代化石騎士 スカルキング
-- 效果：
-- 岩石族怪兽＋7星以上的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：对方回合，以对方墓地1只怪兽为对象才能发动。选自己1张手卡丢弃，作为对象的怪兽在自己场上特殊召唤。
function c96897184.initial_effect(c)
	-- 在卡片中注册关联卡名「化石融合」
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 设置融合素材为岩石族怪兽和满足特定过滤条件的怪兽各1只
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),c96897184.matfilter,true)
	-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制条件为只能通过「化石融合」的效果特殊召唤
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ①：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：对方回合，以对方墓地1只怪兽为对象才能发动。选自己1张手卡丢弃，作为对象的怪兽在自己场上特殊召唤。这个卡名的③的效果1回合只能使用1次。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(96897184,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,96897184)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetCondition(c96897184.spcon)
	e4:SetTarget(c96897184.sptg)
	e4:SetOperation(c96897184.spop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤条件：等级7以上的怪兽
function c96897184.matfilter(c)
	return c:IsLevelAbove(7) and c:IsFusionType(TYPE_MONSTER)
end
-- 效果③的发动条件判定函数
function c96897184.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 特殊召唤目标怪兽的过滤条件：可以被特殊召唤
function c96897184.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备（Target）函数
function c96897184.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c96897184.spfilter(chkc,e,tp) end
	-- 在发动效果时，检查自己手卡数量是否大于0，且自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查对方墓地是否存在可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c96897184.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只满足特殊召唤条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c96897184.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置连锁操作信息，表示该效果包含特殊召唤选中的怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 效果③的效果处理（Operation）函数
function c96897184.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 丢弃自己1张手卡，并检查作为对象的怪兽是否仍与该效果相关联
	if Duel.DiscardHand(tp,nil,1,1,REASON_DISCARD+REASON_EFFECT,nil)>0 and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽在自己场上以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
