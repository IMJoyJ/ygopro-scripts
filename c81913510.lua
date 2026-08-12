--NEX
-- 效果：
-- 把自己场上表侧表示存在的1只名字带有「新空间侠」的怪兽送去墓地，当作和送去墓地的卡同名卡使用的1只4星怪兽从额外卡组特殊召唤。
function c81913510.initial_effect(c)
	-- 把自己场上表侧表示存在的1只名字带有「新空间侠」的怪兽送去墓地，当作和送去墓地的卡同名卡使用的1只4星怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c81913510.target)
	e1:SetOperation(c81913510.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「新空间侠」怪兽，且额外卡组存在可特殊召唤的同名怪兽
function c81913510.filter1(c,e,tp)
	local code=c:GetCode()
	return c:IsFaceup() and c:IsSetCard(0x1f)
		-- 检查额外卡组是否存在至少1张与该怪兽同名且可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c81913510.filter2,tp,LOCATION_EXTRA,0,1,nil,code,e,tp,c)
end
-- 过滤条件：额外卡组中与送去墓地的怪兽同名、可以特殊召唤，且在送去墓地怪兽离场后有可用额外怪兽区域的怪兽
function c81913510.filter2(c,code,e,tp,mc)
	-- 判断卡片是否与指定卡号同名、是否能无视召唤条件特殊召唤，以及在原怪兽离场后是否有足够的额外怪兽区域
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的目标选择与处理：检查发动条件、选择要送去墓地的「新空间侠」怪兽作为对象，并设置操作信息
function c81913510.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c81913510.filter1(chkc,e,tp) end
	-- 在发动阶段，检查自己场上是否存在符合条件的「新空间侠」怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c81913510.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只符合条件的「新空间侠」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c81913510.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：将选中的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置当前连锁的操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：将作为对象的怪兽送去墓地，并从额外卡组特殊召唤同名怪兽
function c81913510.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象（即要送去墓地的「新空间侠」怪兽）
	local tc1=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍受此效果影响，并将其因效果送去墓地
	if tc1:IsRelateToEffect(e) and Duel.SendtoGrave(tc1,REASON_EFFECT)~=0 then
		local code=tc1:GetCode()
		-- 从额外卡组中获取第一张与送去墓地的怪兽同名且满足特殊召唤条件的怪兽
		local tc2=Duel.GetFirstMatchingCard(c81913510.filter2,tp,LOCATION_EXTRA,0,nil,code,e,tp,nil)
		-- 如果存在符合条件的怪兽，则将其无视召唤条件以表侧表示特殊召唤到自己场上
		if tc2 and Duel.SpecialSummon(tc2,0,tp,tp,true,false,POS_FACEUP)~=0 then
			tc2:CompleteProcedure()
		end
	end
end
