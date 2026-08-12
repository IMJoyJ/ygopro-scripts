--SRドミノバタフライ
-- 效果：
-- ←8 【灵摆】 8→
-- 「疾行机人 多米诺蝴蝶」的②的灵摆效果1回合只能使用1次。
-- ①：自己不是风属性怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：从手卡丢弃1只风属性怪兽，以除外的1只自己的风属性怪兽为对象才能发动。那只怪兽加入手卡。
-- 【怪兽效果】
-- 把这张卡作为同调素材的场合，不是龙族·机械族的风属性怪兽的同调召唤不能使用。从额外卡组特殊召唤的这张卡被同调召唤使用的场合除外。
function c28151978.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是风属性怪兽不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c28151978.splimit)
	c:RegisterEffect(e1)
	-- ②：从手卡丢弃1只风属性怪兽，以除外的1只自己的风属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28151978,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,28151978)
	e2:SetCost(c28151978.thcost)
	e2:SetTarget(c28151978.thtg)
	e2:SetOperation(c28151978.thop)
	c:RegisterEffect(e2)
	-- 把这张卡作为同调素材的场合，不是龙族·机械族的风属性怪兽的同调召唤不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3:SetValue(c28151978.synlimit)
	c:RegisterEffect(e3)
	-- 从额外卡组特殊召唤的这张卡被同调召唤使用的场合除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e4:SetValue(LOCATION_REMOVED)
	e4:SetCondition(c28151978.rmcon)
	c:RegisterEffect(e4)
end
-- 判断是否为非风属性怪兽且为灵摆召唤类型，若是则禁止其特殊召唤
function c28151978.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsAttribute(ATTRIBUTE_WIND) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 筛选手卡中可丢弃的风属性怪兽
function c28151978.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDiscardable()
end
-- 检查手卡是否存在风属性怪兽并将其丢弃作为效果的代价
function c28151978.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在至少1张风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28151978.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡丢弃1张风属性怪兽
	Duel.DiscardHand(tp,c28151978.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选除外区中满足条件的风属性怪兽（可加入手卡）
function c28151978.thfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标，选择除外区中的风属性怪兽作为效果对象
function c28151978.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c28151978.thfilter(chkc) end
	-- 检查除外区是否存在至少1张满足条件的风属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c28151978.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外区中的一张风属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c28151978.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果操作信息，指定将一张卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果操作，将选定的除外怪兽送入手牌
function c28151978.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判断是否为非风属性或非龙族/机械族怪兽，若是则不能作为同调素材
function c28151978.synlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_WIND) or not c:IsRace(RACE_DRAGON+RACE_MACHINE)
end
-- 判断此卡是否为从额外卡组特殊召唤并通过同调素材方式使用的场合
function c28151978.rmcon(e)
	local c=e:GetHandler()
	return c:IsSummonLocation(LOCATION_EXTRA)
		and bit.band(c:GetReason(),REASON_MATERIAL+REASON_SYNCHRO)==REASON_MATERIAL+REASON_SYNCHRO
end
