--スターダスト・アサルト・ウォリアー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「星尘强袭战士」的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤成功时，自己场上没有其他怪兽存在的场合以自己墓地1只「废品」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c97792247.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 「星尘强袭战士」的①的效果1回合只能使用1次。①：这张卡同调召唤成功时，自己场上没有其他怪兽存在的场合以自己墓地1只「废品」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97792247,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,97792247)
	e1:SetCondition(c97792247.spcon)
	e1:SetTarget(c97792247.sptg)
	e1:SetOperation(c97792247.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 判定发动条件：这张卡同调召唤成功，且自己场上没有其他怪兽存在
function c97792247.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		-- 检查自己场上是否存在除这张卡以外的其他怪兽
		and not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤条件：自己墓地中可以特殊召唤的「废品」怪兽
function c97792247.spfilter(c,e,tp)
	return c:IsSetCard(0x43) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判定效果发动的有效性，并进行取对象处理
function c97792247.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c97792247.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的「废品」怪兽
		and Duel.IsExistingTarget(c97792247.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「废品」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c97792247.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：包含特殊召唤分类，数量为1，对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将作为对象的「废品」怪兽特殊召唤
function c97792247.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
