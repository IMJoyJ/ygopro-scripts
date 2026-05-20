--統制訓練
-- 效果：
-- 选择对方场上表侧表示存在的1只5星以下的怪兽发动。场上表侧表示存在的持有那以外的等级的怪兽全部破坏。
function c85352446.initial_effect(c)
	-- 选择对方场上表侧表示存在的1只5星以下的怪兽发动。场上表侧表示存在的持有那以外的等级的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK,0x11e0)
	e1:SetTarget(c85352446.target)
	e1:SetOperation(c85352446.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：用于筛选对方场上表侧表示的5星以下、且场上存在其他不同等级怪兽的怪兽
function c85352446.filter(c)
	-- 检查卡片是否为表侧表示、5星以下，且场上存在至少1只该卡以外的、持有不同等级的怪兽
	return c:IsLevelBelow(5) and c:IsFaceup() and Duel.IsExistingMatchingCard(c85352446.filter2,0,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetLevel())
end
-- 过滤函数：用于筛选场上表侧表示、等级在1以上且与指定等级不同的怪兽
function c85352446.filter2(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(0) and not c:IsLevel(lv)
end
-- 效果发动时的目标选择与处理函数
function c85352446.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c85352446.filter(chkc) end
	-- 在发动阶段，检查对方场上是否存在满足条件的、可作为效果对象的表侧表示5星以下怪兽
	if chk==0 then return Duel.IsExistingTarget(c85352446.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只满足条件的表侧表示5星以下怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c85352446.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 获取场上除选择的怪兽以外、持有不同等级的所有表侧表示怪兽组
	local dg=Duel.GetMatchingGroup(c85352446.filter2,0,LOCATION_MZONE,LOCATION_MZONE,nil,g:GetFirst():GetLevel())
	-- 设置连锁的操作信息，表明此效果将破坏上述获取的不同等级的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果处理的激活函数
function c85352446.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 获取场上除该对象怪兽以外、持有不同等级的所有表侧表示怪兽组
		local dg=Duel.GetMatchingGroup(c85352446.filter2,0,LOCATION_MZONE,LOCATION_MZONE,tc,tc:GetLevel())
		-- 因效果将这些不同等级的怪兽全部破坏
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
