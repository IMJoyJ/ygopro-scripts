--ダブルヒーローアタック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有需以「元素英雄 新宇侠」为融合素材的融合怪兽存在的场合，以自己墓地1只「英雄」融合怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。
function c73239437.initial_effect(c)
	-- 将「元素英雄 新宇侠」的卡片密码注册到该卡的关联卡片列表中
	aux.AddCodeList(c,89943723)
	-- 将「元素英雄」系列编码注册到该卡的关联怪兽系列列表中
	aux.AddSetNameMonsterList(c,0x3008)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有需以「元素英雄 新宇侠」为融合素材的融合怪兽存在的场合，以自己墓地1只「英雄」融合怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,73239437+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c73239437.condition)
	e1:SetTarget(c73239437.target)
	e1:SetOperation(c73239437.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且以「元素英雄 新宇侠」为融合素材的融合怪兽
function c73239437.cfilter(c)
	-- 检查卡片是否表侧表示、是融合怪兽，且其融合素材列表中包含「元素英雄 新宇侠」
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,89943723)
end
-- 发动条件：检查自己场上是否存在满足条件的融合怪兽
function c73239437.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示且以「元素英雄 新宇侠」为融合素材的融合怪兽
	return Duel.IsExistingMatchingCard(c73239437.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：自己墓地可以特殊召唤的「英雄」融合怪兽
function c73239437.filter(c,e,tp)
	return c:IsSetCard(0x8) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果发动时的目标选择与合法性检测
function c73239437.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c73239437.filter(chkc,e,tp) end
	-- 在发动效果时，首先检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1只可以作为对象的「英雄」融合怪兽
		and Duel.IsExistingTarget(c73239437.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「英雄」融合怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73239437.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含特殊召唤1只目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的墓地怪兽无视召唤条件特殊召唤
function c73239437.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，若自己场上已无空余的怪兽区域，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽无视召唤条件以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
