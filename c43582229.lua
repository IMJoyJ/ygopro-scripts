--氷結界の晶壁
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡的发动时，可以以自己墓地1只4星以下的「冰结界」怪兽为对象。那个场合，那只怪兽特殊召唤。
-- ②：只要这张卡在魔法与陷阱区域存在并在自己场上有「冰结界」怪兽3只以上存在，自己场上的「冰结界」怪兽不受从额外卡组特殊召唤的对方怪兽发动的效果影响。
function c43582229.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡的发动时，可以以自己墓地1只4星以下的「冰结界」怪兽为对象。那个场合，那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,43582229+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c43582229.target)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在并在自己场上有「冰结界」怪兽3只以上存在，自己场上的「冰结界」怪兽不受从额外卡组特殊召唤的对方怪兽发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置②效果的适用范围条件，只对所属字段为「冰结界」的怪兽适用
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2f))
	e2:SetCondition(c43582229.condition)
	e2:SetValue(c43582229.efilter)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可作为①效果对象的怪兽：等级在4星以下、属于「冰结界」字段且能够被特殊召唤
function c43582229.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x2f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理卡的发动时的目标选择：可空发，若自己怪兽区有空位且墓地有符合条件的怪兽且玩家选择适用对应效果，则取1只为对象并设置特殊召唤操作信息，否则重置效果属性为空发
function c43582229.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c43582229.filter(chkc,e,tp) end
	if chk==0 then return true end
	-- 检查自己主要怪兽区是否还有至少1个可用空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可成为对象的4星以下「冰结界」怪兽
		and Duel.IsExistingTarget(c43582229.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问发动玩家是否要在发动这张卡时特殊召唤墓地怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(43582229,0)) then  --"是否把墓地怪兽特殊召唤？"
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c43582229.activate)
		-- 向发动玩家发送选择要特殊召唤的卡片提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让发动玩家从自己墓地选择1只符合条件的4星以下「冰结界」怪兽作为本次连锁的对象
		local g=Duel.SelectTarget(tp,c43582229.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 登记本次连锁包含将对象怪兽特殊召唤的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 执行①效果处理：检查对象怪兽是否仍与效果保持关联，是则将其以表侧表示特殊召唤到自己场上
function c43582229.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选中的墓地对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上可用于计数②效果条件的怪兽：表侧表示且属于「冰结界」字段
function c43582229.imfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 检查②效果的适用条件：自己怪兽区是否存在至少3只表侧表示的「冰结界」怪兽
function c43582229.condition(e)
	-- 判定控制者怪兽区是否存在至少3只表侧表示的「冰结界」怪兽
	return Duel.IsExistingMatchingCard(c43582229.imfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,3,nil)
end
-- 判断免疫的效果条件：对方玩家在怪兽区发动的、且持有者是从额外卡组召唤或特殊召唤出场的怪兽的效果
function c43582229.efilter(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
		and te:GetOwnerPlayer()==1-e:GetHandlerPlayer()
		and te:GetActivateLocation()==LOCATION_MZONE and tc:IsSummonLocation(LOCATION_EXTRA)
end
