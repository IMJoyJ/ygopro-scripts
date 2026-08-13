--アロマージ－マジョラム
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己的植物族怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。那之后，自己回复500基本分。
-- ②：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己的植物族怪兽的战斗发生的对自己的战斗伤害变成0。
-- ③：自己基本分回复的场合，以最多有自己场上的「芳香」怪兽数量的对方墓地的卡为对象发动。那些卡除外。
function c40663548.initial_effect(c)
	-- ①：自己的植物族怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。那之后，自己回复500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40663548,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,40663548)
	e1:SetCondition(c40663548.spcon)
	e1:SetTarget(c40663548.sptg)
	e1:SetOperation(c40663548.spop)
	c:RegisterEffect(e1)
	-- ②：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己的植物族怪兽的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c40663548.bdcon)
	-- 设置该效果的适用对象为自己的植物族怪兽，即只有植物族怪兽才能享受此战斗伤害减免效果。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PLANT))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己基本分回复的场合，以最多有自己场上的「芳香」怪兽数量的对方墓地的卡为对象发动。那些卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40663548,1))  --"对方墓地的卡除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_RECOVER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,40663549)
	e3:SetCondition(c40663548.rmcon)
	e3:SetTarget(c40663548.rmtg)
	e3:SetOperation(c40663548.rmop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断被战斗破坏的怪兽是植物族，且其之前控制者是发动玩家自己，用于①的触发条件。
function c40663548.cfilter(c,tp)
	return c:IsRace(RACE_PLANT) and c:IsPreviousControler(tp)
end
-- ①的触发条件：本次被战斗破坏的怪兽组中存在至少1只满足自己植物族怪兽条件的怪兽。
function c40663548.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c40663548.cfilter,1,nil,tp)
end
-- ①发动合法性检查：自己主要怪兽区有空位，且这张卡在手牌可以被玩家tp特殊召唤。
function c40663548.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在空余的主要怪兽区域，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，登记本次效果将特殊召唤这张卡，供其他卡/时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息，登记本次效果将让自己回复500基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- ①效果处理：先将这张卡特殊召唤，若特殊召唤成功则再回复500LP。
function c40663548.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡仍与效果关联且特殊召唤成功，即成功以表侧表示特殊召唤到场上。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，使特殊召唤和回复LP作为不同时点处理，避免错过时点。
		Duel.BreakEffect()
		-- 让tp玩家回复500基本分，回复原因视为效果（若被‘回复变成伤害’等效果替代则实际回复值为0）。
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end
-- ②的永续效果条件：自己的基本分高于对方。
function c40663548.bdcon(e)
	local tp=e:GetHandlerPlayer()
	-- 比较双方LP，返回自己LP是否大于对方LP。
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
-- ③的触发条件：本次回复基本分的玩家是自己。
function c40663548.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 过滤函数：判断怪兽为表侧表示且卡名含有「芳香」字段，用于统计自己场上的芳香怪兽数量。
function c40663548.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc9)
end
-- ③的发动与目标选择：若指定对象则要求是对方墓地可除外的卡；发动时无需其他条件，计算自己场上芳香怪兽数量，并选择对方墓地1至该数量张可除外的卡作为对象。
function c40663548.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	-- 获取自己场上的表侧表示「芳香」怪兽数量，作为③可除外对方墓地卡的数量上限。
	local ct=Duel.GetMatchingGroupCount(c40663548.ctfilter,tp,LOCATION_MZONE,0,nil)
	if ct>0 then
		-- 向玩家显示选择卡片的提示，提示内容为“请选择要除外的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从对方墓地选择1到ct张可除外的卡作为效果对象。
		local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,ct,nil)
		-- 设置操作信息，登记本次效果将除外选择的对象卡。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	end
end
-- ③效果处理：将仍与效果关联的对象卡全部除外。
function c40663548.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡组，并筛选出仍然与效果关联的卡（未离场或未被无效）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将筛选出的卡以表侧表示从墓地除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
